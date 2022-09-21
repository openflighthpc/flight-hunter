#!/usr/bin/env ruby
# frozen_string_literal: true

#==============================================================================
# Copyright (C) 2019-present Alces Flight Ltd.
#
# This file is part of Hunter.
#
# This program and the accompanying materials are made available under
# the terms of the Eclipse Public License 2.0 which is available at
# <https://www.eclipse.org/legal/epl-2.0>, or alternative license
# terms made available by Alces Flight Ltd - please direct inquiries
# about licensing to licensing@alces-flight.com.
#
# Hunter is distributed in the hope that it will be useful, but
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, EITHER EXPRESS OR
# IMPLIED INCLUDING, WITHOUT LIMITATION, ANY WARRANTIES OR CONDITIONS
# OF TITLE, NON-INFRINGEMENT, MERCHANTABILITY OR FITNESS FOR A
# PARTICULAR PURPOSE. See the Eclipse Public License 2.0 for more
# details.
#
# You should have received a copy of the Eclipse Public License 2.0
# along with Hunter. If not, see:
#
#  https://opensource.org/licenses/EPL-2.0
#
# For more information on Hunter, please visit:
# https://github.com/openflighthpc/hunter
#===============================================================================

module FlightHunter
	module Server
		class SearchHostname
			def search(list,val)
				list.each do |key,value|
					if value["hostname"] == val
						return true
					end
				end
				false
			end
		end

		class Hunt
			def hunt(port, buffer_file, parsed_file,allow_existing)
				buffer = YAML.load(File.read(buffer_file)) || {}
				parsed = YAML.load(File.read(parsed_file)) || {}
				search_hostname = SearchHostname.new
				server = TCPServer.open(port)
				Thread.new do
					loop do
						client = server.accept
						id,host,fileContent = client.read.unpack("Z*Z*Z*")
						vals = {"hostname"=> host,"ip" => (client.peeraddr[2] || 'unknown'),"payload" => fileContent}.reject { |k,v| v==''}
						if !allow_existing
							if buffer.key?(id)
								puts "This ID already exists in the unprocessed list. Ignoring..."
							elsif search_hostname.search(buffer,host)
								puts "This hostname already exists in the unprocessed list. Ignoring..."
							elsif parsed.key?(id)
								puts "This ID already exists in the processed list. Ignoring..."
							elsif search_hostname.search(parsed,host)
								puts "This hostname already exists in the processed list. Ignoring..."
							else
								buffer[id] = vals
								puts "Found node. ID: #{id}, name: #{host}"
							end
						else
							if buffer.key?(id)
								buffer[id] = vals
								puts "This ID already existed in the unprocessed list, but its name has been overwritten to the new one."
							elsif search_hostname.search(buffer,host)
								buffer[id] = vals
								puts "Found node. ID: #{id}, name: #{host}"
								puts "Node added, but please note that the name of this node already exists in the unprocessed
								list. It will be renamed during parsing anyway, but is useful to keep in mind."						
							elsif parsed.key?(id)
								buffer[id] = vals
								puts "Node added, but please note that this ID address already exists in the parsed parsed."
							elsif search_hostname.search(parsed,host)
								buffer[id] = vals
								puts "Node added, but please note that a node with this hostname already exists in the parsed list."
							else
								buffer[id] = vals
								puts "Found node. ID: #{id}, name: #{host}"
							end
						end						
					end
					client.close
				end
				puts "Hunter running on #{server.addr[3]}:#{server.addr[1]} Ctrl+c to stop\n"
                                trap "SIGINT" do
					puts "\nExiting..."
					File.write(buffer_file, buffer.to_yaml)
					puts "Found nodes written to \'#{buffer_file}\'. They need processing."
					exit 130
				end
				while true do
					sleep 1
				end
			end
			
		end		
  end
end
