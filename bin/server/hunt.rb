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

require 'socket'
require_relative 'read_yaml.rb'

def hunt(port, not_processed_file, nodelist_file,ignore_dupes)
	not_processed = YAML.load(read_yaml(not_processed_file)) || {}
	nodelist = YAML.load(read_yaml(nodelist_file)) || {}

	server = TCPServer.open(port)
	Thread.new do
		loop do
			client = server.accept
			while line = client.gets
				host,mac = line.split(' ')
				if ignore_dupes && (nodelist.key?(mac) || not_processed.key?(mac))
				else
					not_processed[mac] = host
					puts "Found node. MAC: #{mac}, name: #{host}"
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