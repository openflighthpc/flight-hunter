# frozen_string_literal: true

require 'socket'
require 'json'

class UDPMoose
  attr_reader :buffers, :requests

  def initialize(port = 0, ingress = false)
    @udp_socket = UDPSocket.new
    @udp_socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true)
    @udp_socket.bind('0.0.0.0', port)

    @ingress = ingress

    @requests = {}
    @buffers = {}

    @receive_lock = UDPMooseLock.new

    @receives = []

    listener
    timer
  end

  #
  # client methods
  #
  #
  #

  # user send request
  def send(body, server_ip_range, server_port, max_connection = 1, max_timeout = 10)
    # build the request
    request_id = ((Time.now.to_f * 1000).to_i.to_s + body).hash.to_s
    request = UDPMooseRequest.new(request_id, body, server_ip_range, server_port, max_connection, max_timeout)

    @requests[request_id] = request

    Thread.new do
      # enqueue the initial handshake request connection
      request.enqueue_by_connection_key(request_id)

      # loop until request end
      while request.requesting?

        connection = request.dequeue
        @udp_socket.send(connection.payload, 0, connection.server_ip, request.server_port)

        request.lock_request
        request.wait_request if request.idle? && request.requesting?
        request.unlock_request

      end
    end

    # return the request id for user access in the future
    request_id
  end

  def get_responses(request_id)
    request = @requests[request_id]
    request.lock_response
    request.wait_response if request.requesting?
    request.unlock_response

    responses = [].tap do |arr|
      request.connections.each do |key, connection|
        arr << connection.server_ip if connection.closed? && key != request_id
      end
    end

    yield responses if block_given?
  end

  #
  # server methods
  #
  #
  #

  def receive
    loop do
      lock_receive
      wait_receive if @receives.empty?
      unlock_receive

      if block_given?
        buffer = @receives.shift
        yield buffer.client_ip, buffer.buffer
      end
    end
  end

  private

  # create a thread for listening to the income packets
  def listener
    Thread.new do
      loop do
        msg, addr = @udp_socket.recvfrom(64_000) # thread blocked until new packet recieved
        hash_msg = JSON.parse(msg)

        # handshake request received
        if @ingress && hash_msg['type'] == 'stu'

          @buffers[hash_msg['id']] ||= UDPMooseBuffer.new(hash_msg['total'], addr[2], addr[1])
          jack(hash_msg['id']) unless @buffers[hash_msg['id']]&.packet&.> 0

        # body fragment received
        elsif hash_msg['type'] == 'request'

          buffer = @buffers[hash_msg['id']]

          if hash_msg['packet'] + 1 == buffer&.join!(hash_msg['packet'], hash_msg['content']) && !buffer.completed?
            response(hash_msg['id'])
          elsif buffer&.completed?
            ivan(hash_msg['id'])
            @receives << buffer if buffer.enqueue?
            continue_receive unless @receives.empty?
          end

        # handwave response from client received
        elsif hash_msg['type'] == 'bye'

          # remove the buffer
          @buffers&.delete(hash_msg['id'])

        # handshake response received
        elsif hash_msg['type'] == 'jack'

          request = @requests[hash_msg['id']]
          # connection can be created

          request&.lock_request
          if request&.create_connection(addr[2])

            request.enqueue_by_connection_key(addr[2])
            request.continue_request

          end
          request&.unlock_request

        # body response received
        elsif hash_msg['type'] == 'response'

          request = @requests[hash_msg['id']]
          connection = request&.connections&.[](addr[2])

          if connection&.match_packet?(hash_msg['packet'].to_i - 1)

            request.lock_request

            connection.next_packet
            request.enqueue_by_connection_key(addr[2])

            request.continue_request
            request.unlock_request

          end

        # handwave request from server received
        elsif hash_msg['type'] == 'ivan'

          request = @requests[hash_msg['id']]

          if request

            request.lock_request
            if request.complete_connection(addr[2]) && !request.requesting?
              request.continue_request
              request.continue_response
            end
            request.unlock_request

            bye(hash_msg['id'], addr[2], addr[1])

          end

        end
      end
    end
  end

  # create a thread to check requests timeout
  def timer
    Thread.new do
      loop do
        @requests.each_value do |request|
          request.lock_request
          request.check_timeout
          request.continue_request unless request.idle? && request.requesting?
          request.continue_response unless request.requesting?
          request.unlock_request
        end

        sleep(1)
      end
    end
  end

  def jack(request_id)
    buffer = @buffers[request_id]
    payload = {
      type: 'jack',
      id: request_id
    }.to_json

    @udp_socket.send(payload, 0, buffer.client_ip, buffer.client_port)
  end

  def response(request_id)
    buffer = @buffers[request_id]
    payload = {
      type: 'response',
      id: request_id,
      packet: buffer.packet
    }.to_json

    @udp_socket.send(payload, 0, buffer.client_ip, buffer.client_port)
  end

  def ivan(request_id)
    buffer = @buffers[request_id]
    payload = {
      type: 'ivan',
      id: request_id
    }.to_json

    @udp_socket.send(payload, 0, buffer.client_ip, buffer.client_port)
  end

  def bye(request_id, server_ip, server_port)
    @buffers[request_id]
    payload = {
      type: 'bye',
      id: request_id
    }.to_json

    @udp_socket.send(payload, 0, server_ip, server_port)
  end

  #
  # server thread lock methods
  #
  #
  #

  def lock_receive
    @receive_lock.lock
  end

  def unlock_receive
    @receive_lock.unlock
  end

  def wait_receive
    @receive_lock.wait
  end

  def continue_receive
    @receive_lock.continue
  end

  #
  # private classes
  #
  #
  #

  class UDPMooseLock
    def initialize
      @mutex = Mutex.new
      @condition = ConditionVariable.new
      @waiting = false
    end

    def lock
      @mutex.lock
    end

    def unlock
      @mutex.unlock
    end

    def wait
      @waiting = true
      @condition.wait(@mutex)
    end

    def continue
      return unless @waiting

      @waiting = false
      @condition.signal
    end
  end

  class UDPMooseRequest
    attr_reader :server_port, :connections

    def initialize(id, body, server_ip_range, server_port, max_connection, max_timeout)
      @request_lock = UDPMooseLock.new
      @response_lock = UDPMooseLock.new

      @id = id
      @body_fragments = split_body(body)
      @connections = {}
      @connections[@id] = UDPMooseHandShakeConnection.new(@id, @body_fragments, server_ip_range)
      @server_port = server_port

      @queue = []

      @max_connection = max_connection

      @timestamp = Time.now.to_f
      @handshake_timestamp = @timestamp
      @max_timeout = max_timeout
    end

    #
    # thread control methods
    #
    #
    #

    def lock_request
      @request_lock.lock
    end

    def unlock_request
      @request_lock.unlock
    end

    def wait_request
      @request_lock.wait
    end

    def continue_request
      @request_lock.continue
    end

    def lock_response
      @response_lock.lock
    end

    def unlock_response
      @response_lock.unlock
    end

    def wait_response
      @response_lock.wait
    end

    def continue_response
      @response_lock.continue
    end

    #
    # request queue management methods
    #
    #
    #

    # enqueue the connection to be executed
    def enqueue_by_connection_key(connection_id)
      @queue << @connections[connection_id]
    end

    # fetch the next connection to be executed and update the timestamp
    def dequeue
      connection = @queue.shift
      @timestamp = Time.now.to_f if idle?
      connection
    end

    # check if the queue is empty
    def idle?
      @queue.empty?
    end

    #
    # connection life cycle management
    #
    #
    #

    def create_connection(server_ip)
      if connections[@id].connecting? && !@connections[server_ip]

        @connections[server_ip] = UDPMooseRequestConnection.new(@id, @body_fragments, server_ip)

        # close handshake connection if handshake finished
        @connections[@id].close if @connections.length - 1 == @max_connection

        return @connections[server_ip]

      end

      nil
    end

    def complete_connection(server_ip)
      @connections[server_ip]&.close
    end

    # check timeout status to retry or terminate the connections
    def check_timeout
      current_timestamp = Time.now.to_f

      # neither reached the limitation of maximum connections nor handshake timeout
      if @connections[@id].connecting? && current_timestamp - @handshake_timestamp <= @max_timeout
        enqueue_by_connection_key(@id)

      # some connections established
      elsif @connections.length > 1
        @connections[@id].close

      # no connection established
      else
        @connections[@id].timeout
      end

      if requesting? && current_timestamp - @timestamp > 1 && current_timestamp - @timestamp <= @max_timeout

        @connections.each do |key, _connection|
          enqueue_by_connection_key(key) if !key == @id && @connection.connecting?
        end

      elsif requesting? && current_timestamp - @timestamp > @max_timeout

        @connections.each_value do |connection|
          # the closed connections won't be transferred to timeout connections, see UDPMooseConnection#close and UDPMooseConnection#timeout
          connection.timeout if connection.connecting?
        end

      end
    end

    # check if any connecting connection remains
    def requesting?
      @connections.each_value do |connection|
        return true if connection.connecting?
      end

      false
    end

    private

    # split a long string into an array of string fragments regarding the packet_limit
    def split_body(body, packet_limit = 60_000)
      body_fragments = []

      i = 15_000 # index of string character
      temp_string = body[0...15_000]
      temp_bytesize = temp_string.bytesize
      while i < body.length

        if temp_bytesize + body[i].bytesize <= packet_limit
          temp_string << body[i]
          temp_bytesize += body[i].bytesize
        else
          body_fragments << temp_string
          j = i + 14_999
          temp_string = body[i..j]
          temp_bytesize = temp_string.bytesize
          i = j
        end

        i += 1

      end

      body_fragments << temp_string
    end
  end

  class UDPMooseConnection
    attr_reader :server_ip

    def initialize(id, body_fragments, server_ip)
      @id = id
      @body_fragments = body_fragments
      @server_ip = server_ip
      @status = 0
    end

    def connecting?
      @status.zero?
    end

    def close
      return unless connecting?

      @status = 1
    end

    def closed?
      @status == 1
    end

    def timeout
      return unless connecting?

      @status = 2
    end

    def timeout?
      @status == 2
    end
  end

  class UDPMooseHandShakeConnection < UDPMooseConnection
    def payload
      {
        type: 'stu',
        id: @id,
        total: @body_fragments.length
      }.to_json
    end
  end

  class UDPMooseRequestConnection < UDPMooseConnection
    def initialize(id, body_fragments, server_ip)
      super(id, body_fragments, server_ip)
      @packet = 0
    end

    def payload
      {
        type: 'request',
        id: @id,
        packet: @packet,
        content: @body_fragments[@packet]
      }.to_json
    end

    def next_packet
      @packet += 1
    end

    def match_packet?(packet)
      packet == @packet
    end
  end

  class UDPMooseBuffer
    attr_reader :packet, :client_ip, :client_port, :buffer

    def initialize(total, client_ip, client_port)
      @total = total
      @packet = 0
      @buffer = ''
      @client_ip = client_ip
      @client_port = client_port
      @enqueued = false
    end

    def join!(packet, content)
      if @packet == packet && !completed?
        @buffer += content
        @packet += 1
      end

      @packet
    end

    def completed?
      @packet == @total
    end

    def enqueue?
      return false if @enqueued

      @enqueued = true
    end
  end
end
