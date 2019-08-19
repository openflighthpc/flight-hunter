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
		class Hunt
			def hunt(port, buffer_file, parsed_file,allow_existing)
				buffer = YAML.load(File.read(buffer_file)) || {}
				parsed = YAML.load(File.read(parsed_file)) || {}

				server = TCPServer.open(port)
				Thread.new do
					loop do
						client = server.accept
						while line = client.gets
							host,mac = line.split(' ')
							if !allow_existing
								if buffer.key?(mac)
									puts "This MAC address already exists in the unprocessed list. Ignoring..."
								elsif buffer.has_value?(host)
									puts "This hostname already exists in the unprocessed list. Ignoring..."
								elsif parsed.key?(mac)
									puts "This MAC address already exists in the processed list. Ignoring..."
								elsif parsed.has_value?(host)
									puts "This hostname already exists in the processed list. Ignoring..."
								else
									buffer[mac] = host
									puts "Found node. MAC: #{mac}, name: #{host}"
								end
							else
								if buffer.key?(mac)
									buffer[mac] = host
									puts "This MAC already existed in the unprocessed list, but its name has been overwritten to the new one."
								elsif buffer.has_value?(host)
									buffer[mac] = host # Add anyway name not guaranteed or required to be unique during staging
									puts "Found node. MAC: #{mac}, name: #{host}"
									puts "Node added, but please note that the name of this node already exists in the unprocessed "+
									"list under #{buffer.key(host)}. It will be renamed during parsing anyway,"+
									"but is useful to keep in mind."						
								elsif parsed.key?(mac)
									# add, print warning
									buffer[mac] = host
									puts "Node added, but please note that this MAC address already exists in the parsed parsed."
								elsif parsed.has_value?(host)
									# add, print warning
									buffer[mac] = host
									puts "Node added, but please note that a node with this hostname already exists in the parsed parsed."
								else
									buffer[mac] = host
									puts "Found node. MAC: #{mac}, name: #{host}"
								end
							end
						end
					end
					client.close
				end
				puts "Press enter at any time to close.\n"
				while STDIN.gets.chomp
					puts "\nExiting..."
					File.write(buffer_file, buffer.to_yaml)
					puts "Found nodes written to \'#{buffer_file}\'. They need processing."
					exit 130
				end
			end
		end
  end
end