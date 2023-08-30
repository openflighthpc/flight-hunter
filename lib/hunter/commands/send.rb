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
require_relative '../udp_moose'

module Hunter
  module Commands
    class SendPayload < Command
      include Hunter::Collector

      def run
        port = @options.port || Config.port&.to_i
        raise "No port provided!" if !port

        data = prepare_payload

        host = @options.server || Config.target_host
        raise "No target server provided!" unless host
        
        max_host = @options.max_server || Config.max_target&.to_i || 1

        timeout = @options.timeout || Config.timeout&.to_i || 10

        pidpath = ENV['flight_HUNTER_pidfile']

        unless pidpath.nil?
          piddir, pidfile = pidpath.yield_self do |s|
            [File.dirname(s), s.split('/').pop]
          end

          pf = PidFile.new(
            piddir: piddir,
            pidfile: pidfile
          )
        end

        # Give Flight Service a chance to fetch the PID file
        sleep(1)

        # do not open conflict socket when send to self
        socket = @options.socket || UDPMoose.new(port)
        request_id = socket.send(data.to_json, host, port, max_host, timeout)
        socket.get_responses(request_id) do |responses|
          raise "send request timeout" if responses.empty?
          responses.each do |server_ip|
            puts "Successful transmission to: #{server_ip}"
          end
        end

      end

      private

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
          groups: @options.groups&.empty? ? Config.presets["groups"] : @options.groups,
          auth_key: auth_key
        }
      end
    end
  end
end
