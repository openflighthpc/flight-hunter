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

require_relative 'read_yaml.rb'

def hunt(port, not_processed_file, nodelist_file,allow_existing)
	not_processed = YAML.load(read_yaml(not_processed_file)) || {}
	nodelist = YAML.load(read_yaml(nodelist_file)) || {}

	server = TCPServer.open(port)
	Thread.new do
		loop do
			client = server.accept
			while line = client.gets
				host,mac = line.split(' ')
				if !allow_existing
					if not_processed.key?(mac)
						puts "This MAC address already exists in the unprocessed list. Ignoring..."
					elsif not_processed.has_value?(host)
						puts "This hostname already exists in the unprocessed list. Ignoring..."
					elsif nodelist.key?(mac)
						puts "This MAC address already exists in the processed list. Ignoring..."
					elsif nodelist.has_value?(host)
						puts "This hostname already exists in the processed list. Ignoring..."
					else
						not_processed[mac] = host
						puts "Found node. MAC: #{mac}, name: #{host}"
					end
				else
					if not_processed.key?(mac)
						not_processed[mac] = host
						puts "This MAC already existed in the unprocessed list, but its name has been overwritten to the new one."
					elsif not_processed.has_value?(host)
						not_processed[mac] = host # Add anyway name not guaranteed or required to be unique during staging
						puts "Found node. MAC: #{mac}, name: #{host}"
						puts "Node added, but please note that the name of this node already exists in the unprocessed "+
						"list under #{not_processed.key(host)}. It will be renamed during parsing anyway,"+
						"but is useful to keep in mind."						
					elsif nodelist.key?(mac)
						# add, print warning
						not_processed[mac] = host
						puts "Node added, but please note that this MAC address already exists in the parsed nodelist."
					elsif nodelist.has_value?(host)
						# add, print warning
						not_processed[mac] = host
						puts "Node added, but please note that a node with this hostname already exists in the parsed nodelist."
					else
						not_processed[mac] = host
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
		File.open(not_processed_file,'w+') { |file| file.write(not_processed.to_yaml)}
		puts "Found nodes written to \'#{not_processed_file}\'. They need processing."
		exit 130
	end
end