#==============================================================================
# Copyright (C) 2022-present Alces Flight Ltd.
#
# This file is part of Flight Hunter.
#
# This program and the accompanying materials are made available under
# the terms of the Eclipse Public License 2.0 which is available at
# <https://www.eclipse.org/legal/epl-2.0>, or alternative license
# terms made available by Alces Flight Ltd - please direct inquiries
# about licensing to licensing@alces-flight.com.
#
# Flight Hunter is distributed in the hope that it will be useful, but
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, EITHER EXPRESS OR
# IMPLIED INCLUDING, WITHOUT LIMITATION, ANY WARRANTIES OR CONDITIONS
# OF TITLE, NON-INFRINGEMENT, MERCHANTABILITY OR FITNESS FOR A
# PARTICULAR PURPOSE. See the Eclipse Public License 2.0 for more
# details.
#
# You should have received a copy of the Eclipse Public License 2.0
# along with Flight Hunter. If not, see:
#
#  https://opensource.org/licenses/EPL-2.0
#
# For more information on Flight Hunter, please visit:
# https://github.com/openflighthpc/flight-hunter
#==============================================================================
require 'pidfile'
require 'thwait'

require_relative '../command'
require_relative '../config'
require_relative '../node'
require_relative '../node_list'
require_relative '../profile_cli'


module Hunter
  module Commands
    class Hunt < Command
      def run
        @port = @options.port || Config.port
        @auth_key = @options.auth || Config.auth_key
        @auto_parse = @options.auto_parse || Config.auto_parse || ".^"

        # Fetch auto_apply to raise an error if it's invalid
        Config.auto_apply

        # Validate auto-parse expression
        unless valid_regex?(@auto_parse)
          raise "Invalid regular expression passed to `auto_parse` option"
        end

        raise "No port provided!" if !@port
        raise "Provided port #{@port} is busy" if !`lsof -i:#{@port}`.empty?

        pidpath = ENV['flight_HUNTER_pidfile']

        case pidpath.nil?
        when true
          pf = PidFile.new
        when false
          piddir, pidfile = pidpath.yield_self do |s|
            [File.dirname(s), s.split("/").pop]
          end
          pf = PidFile.new(
            piddir: piddir,
            pidfile: pidfile
          )
        end

        threads = [tcp_thread, udp_thread]
        puts "Hunter running on port #{@port} - Ctrl+C to stop\n"

        if @options.include_self || Config.include_self
          opts = OpenStruct.new(
            port: @port,
            server: Config.target_host || 'localhost',
            auth: @auth_key,
            broadcast: false
          )

          Commands::SendPayload.new(OpenStruct.new, opts).run!
        end

        ThreadsWait.all_waits(*threads)
      end

      private

      def udp_thread
        # UDP socket for broadcasted connections
        Thread.new do
          # Create socket and bind to address
          server = UDPSocket.new
          server.bind('0.0.0.0', @port)

          loop do
            msg, addr_info, rflags, *controls = server.recvmsg
            ip = addr_info.ip_address

            if !valid_json?(msg)
              puts "Malformed packet received from #{ip}"
              next
            end

            data = JSON.parse(msg)
            data.merge!({ 'ip' => ip })

            unless data["auth_key"] == @auth_key
              puts "Unauthorised node attempted to connect"
              next
            end

            process_packet(data: data)
          end
        end
      end

      def tcp_thread
        # TCP socket for targeted connections
        Thread.new do
          server = TCPServer.open(@port)

          loop do
            begin # Handler for connection reset error
              client = server.accept

              headers = {}
              while line = client.gets.split(' ', 2)
                break if line[0] == ""
                headers[line[0].chop] = line[1].strip
              end

              unless headers["Content-Type"] == "application/json"
                # invalid content type
                client.puts "HTTP/1.1 415\r\n"
                puts "Malformed packet received from #{client.peeraddr[2]}"
                next
              end

              data = client.read(headers["Content-Length"].to_i)
              payload = JSON.parse(data)
              payload.merge!({ 'ip' => client.peeraddr[2] || 'unknown' })

              unless payload["auth_key"] == @auth_key
                client.puts "HTTP/1.1 401\r\n"
                puts "Unauthorised node attempted to connect"
                next
              end

              # Node is acceptable
              client.puts "HTTP/1.1 200\r\n"
              client.close

              process_packet(data: payload)
            rescue Errno::ECONNRESET => e
              puts "Caught exception: #{e.message}"
            end
          end
        end
      end

      def process_packet(data:)
        buffer = NodeList.load(Config.node_buffer)
        parsed = NodeList.load(Config.node_list)

        node = Node.new(
          id: data["hostid"],
          hostname: data["hostname"],
          ip: data["ip"],
          content: data["content"],
          groups: data["groups"],
          presets: {
            label: data["label"],
            prefix: data["prefix"]
          }
        )

        puts <<~EOF
        Found node.
        ID: #{node.id}
        Name: #{node.hostname}
        IP: #{node.ip}

        EOF

        dest = buffer
        if node.hostname.match(Regexp.new(@auto_parse))
          dest = parsed
          node.label = node.presets[:label] || node.hostname.split(".").first
        end

        node.node_list = dest

        if @options.allow_existing || Config.allow_existing
          node.auto_apply = dest == parsed
          dest.nodes.delete_if { |n| n.id == node.id }
          dest.nodes << node
          puts "Node added to #{dest.name} node list"
        else
          if buffer.include_id?(node.id)
            puts "ID already exists in buffer"
          elsif parsed.include_id?(node.id)
            puts "ID already exists in parsed node list"
          else
            node.auto_apply = dest == parsed
            dest.nodes << node
            puts "Node added to #{dest.name} node list"
          end
        end

        dest.save
      end

      private

      def valid_regex?(regex)
        Regexp.new(regex.to_s)
      rescue RegexpError => e
        false
      end

      def valid_json?(str)
        result = JSON.parse(str)

        result.is_a?(Hash) || result.is_a?(Array)
      rescue JSON::ParserError, TypeError
        false
      end
    end
  end
end
