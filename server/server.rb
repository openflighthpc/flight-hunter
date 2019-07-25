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
require 'csv'
require 'yaml'
require 'optparse'


ignoredupes = false
OptionParser.new do |opts|
	opts.banner = "Usage: server.rb [options]"

	opts.on('-d','--duplicates', "Don't add duplicate addresses to the queue") do |duplicates|
		ignoredupes = true
	end
end.parse!

config = YAML.load_file('config.yaml')
csvname = config['csvname']
port = config['port']

if not File.file?(csvname)
	puts "Specified CSV file doesn't exist. Creating..."
	CSV.open(csvname, 'w')
	puts "Created CSV file named #{csvname}."
end

@nodes = CSV.read(csvname)
trap "SIGINT" do
	puts "\nExiting abruptly..."
	@nodes.each do |row|
		puts row
	end
	CSV.open(csvname, 'w+') { |csv| @nodes.each { |elem| csv << elem } }
	puts "Node list written to \'#{csvname}\'."
	exit 130
end

def name_exists(input)
	while @nodes.map {|row| row[0] }.include? input 		
		puts "This name already exists. Try again."
		input = gets.chomp.gsub(/[^0-9a-z]/i, '')
	end
	input
end

server = TCPServer.open(port) 

queue = Queue.new

Thread.new do 
	@this_session = []
	loop do
		client = server.accept
		while line = client.gets
			host,mac = line.split(' ')
			if @this_session.include?([host,mac])
			elsif @nodes.include?([host,mac]) && !ignoredupes
				queue << [host,mac,'newname']
				@this_session.push([host,mac])
			elsif @nodes.include? ([host,mac]) && ignoredupes
				queue << [host,mac,'ignoreverbose']
				@this_session.push([host,mac])
			else
				queue << [host,mac, nil]
				@this_session.push([host,mac])
			end			
		end
		client.close
	end
end

waiting = false
loop do
	while queue.empty?
		if waiting == false
			puts "Waiting for client connection... "
			waiting = true
		end
	end
	node = queue.pop

	if node[2] == 'newname'
		node.pop
		puts "Node found. Hostname = \"#{node[0]}\", MAC address = \"#{node[1]}\". This exact hostname/MAC address combination already exists in the node list. If you would like to rename the pre-existing node, type the new name below. Otherwise, press enter."
		input = gets.chomp.gsub(/[^0-9a-z]/i, '')
		if input == ''
		else
			input = name_exists(input)
			@nodes.each do |element|
				if element[0] == node[0]
					element[0] = input
				end
			end
		end
	elsif node[2] == 'ignoreverbose'
		puts "Node found. Hostname = \"#{node[0]}\", MAC address = \"#{node[1]}\". This exact hostname/MAC address combination already exists in the node list. Ignoring... "
	elsif node[2] == nil
		node.pop
		puts "Node found. Hostname = \"#{node[0]}\", MAC address = \"#{node[1]}\"."
		if @nodes.map {|row| row[0] }.include?(node[0])
			puts "A node with this name already exists in the node list under address #{node[1]}. If you would like to choose a new name, type it below. Otherwise, press enter to ignore this node."
			input = gets.chomp.gsub(/[^0-9a-z]/i, '')
			if input == ''
				puts "Ignoring... "
			else
				input = name_exists(input)
				node[0] = input
				@nodes.push(node)
			end
		elsif @nodes.map {|row| row[1] }.include?(node[1])
			puts "A node already exists with the address #{node[1]}. It is called #{@nodes.rassoc(node[1])[0]}. If you would like to rename the pre-existing node, type the new name below. Otherwise, press enter."
			input = gets.chomp.gsub(/[^0-9a-z]/i, '')
			if input == ''
				puts "Ignoring... "
			else
				input = name_exists(input)
				@nodes.each do |element|
					if element[1] == node[1]
						element[0] = input
					end
				end
			end
		else
			puts "What would you like the node to be saved as? (default: #{node[0]}). "
			input = gets.chomp.gsub(/[^0-9a-z]/i, '')
			if input == ''
			else
				input = name_exists(input)
				node[0] = input	
			end
			@nodes.push(node)
		end
	end
	puts 'Enter \'q\' to quit, enter anything else to continue... '
	if gets.chomp == 'q'
		break
	else
	end
	waiting = false
end

CSV.open(csvname, 'w+') { |csv| @nodes.each { |elem| csv << elem } }
puts "Node list written to \'#{csvname}\'."
