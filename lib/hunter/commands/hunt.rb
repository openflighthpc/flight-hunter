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

require_relative '../command'
require_relative '../config'
require_relative '../node'
require_relative '../node_list'


module Hunter
  module Commands
    class Hunt < Command
      def run
        buffer = NodeList.load(Config.node_buffer)
        parsed = NodeList.load(Config.node_list)

        port = @options.port || Config.data.fetch(:port)
        server = TCPServer.open(port)

        puts "Hunter running on #{server.addr[3]}:#{server.addr[1]} Ctrl+c to stop\n"
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

        first = true

        loop do
          if first && @options.include_self
            opts = OpenStruct.new(
              port: port,
              server: 'localhost'
            )

            Commands::SendPayload.new(OpenStruct.new, opts).run!
            first = false
          end
          client = server.accept
          hostid, hostname, payload = client.read.unpack("Z*Z*Z*")

          node = {
            "hostname" => hostname,
            "ip" => (client.peeraddr[2] || 'unknown'),
            "payload" => payload
          }.reject { |k,v| v.empty? }

          node = Node.new(
            id: hostid,
            hostname: hostname,
            ip: (client.peeraddr[2] || 'unknown'),
            payload: payload,
            groups: []
          )

          puts <<~EOF
          Found node.
          ID: #{node.id}
          name: #{node.hostname}
          IP: #{node.ip}

          EOF

          if @options.allow_existing
            buffer.nodes.delete_if { |n| n.id == node.id }
            buffer.nodes << node
            puts "Node added to buffer"
          else
            if buffer.has_node?(node.id)
              puts "ID already exists in buffer"
            elsif parsed.has_node?(node.id)
              puts "ID already exists in parsed node list"
            else
              buffer.nodes << node
              puts "Node added to buffer"
            end
          end

          buffer.save
          client.close
        end
      end
    end
  end
end
