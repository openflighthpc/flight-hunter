# #==============================================================================
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

require 'socket'
require 'yaml'
require 'json'
require 'net/http'

require_relative '../command'
require_relative '../collector'

module Hunter
  module Commands
    class SendPayload < Command
      include Hunter::Collector

      def run
        port = @options.port || Config.port.to_s
        raise "No port provided!" if !port

        data = prepare_payload

        case @options.broadcast
        when true
          # UDP datagram to user provided broadcast address
          address = @options.broadcast_address || Config.broadcast_address
          socket = UDPSocket.new
          socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true)
          socket.send(data.to_json, 0, address, port)
        when false
          # TCP datagram to specific host
          host = @options.server || Config.target_host
          raise "No target_host provided!" if !host

          uri = URI::HTTPS.build(host: host, port: port)

          http = Net::HTTP.new(uri.host, uri.port)
          request = Net::HTTP::Post.new(
            uri,
            'Content-Type' => 'application/json'
          )

          request.body = data.to_json

          until send_request(http, request)&.code == '200' || !retry_interval
            sleep(retry_interval)
          end
        end
      end

      private

      def retry_interval
        @retry_interval ||= begin
          ri = Config.retry_interval || @options.retry_interval
          return nil unless ri
          if !ri.match(/^\d+(\.\d+)?$/)
            puts "Warning! Invalid value detected for --retry_interval. It has now been set to " + [5.0, ri.to_f].max + "."
          elsif ri.to_f < 5.0
            puts "Warning! The value for --retry_interval is too small. It has now been set to " + [5.0, ri.to_f].max + "."
          end
          [5.0, ri.to_f].max
        end
      end

      def send_request(http, request)
        begin
          response = http.request(request)
          response.value
          puts "Successful transmission"
          return response
        rescue Errno::ECONNREFUSED => e
          msg = "The server is unavailable\n" + e.message
        rescue Net::HTTPServerException => e
          if response.code == "401"
            msg = "Authentication key mismatch"
          else
            msg = "Unknown HTTP error"
          end
        end
        if retry_interval
          puts msg
        else
          raise msg
        end
      end

      def prepare_payload
        auth_key = @options.auth || Config.auth_key.to_s

        syshostid = `hostid`.chomp
        hostid = begin
                    sysinfo = File.read('/proc/cmdline').split.map do |a|
                      a.split('=')
                    end.select { |a| a.length == 2}.to_h
                    sysinfo['SYSUUID'] || syshostid
                  rescue
                    syshostid
                  end

        cmd = @options.command || Config.content_command
        if cmd.nil?
          content = Collector.collect.to_yaml
        else
          content = `#{cmd}`.chomp
        end

        hostname = Socket.gethostname

        {
          hostid: hostid,
          hostname: hostname,
          content: content,
          label: @options.label || Config.presets["label"],
          prefix: @options.prefix || Config.presets["prefix"],
          groups: @options.groups.empty? ? Config.presets["groups"] : @options.groups,
          auth_key: auth_key
        }
      end
    end
  end
end
