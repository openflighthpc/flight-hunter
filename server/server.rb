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

def read_config
	config = YAML.load_file('config.yaml')
	@csvname = config['csvname']
	@port = config['port']
end
read_config

if not File.file?(@csvname)
	puts "Specified CSV file doesn't exist. Creating..."
	CSV.open(@csvname, 'w')
	puts "Created CSV file named #{@csvname}."
end

@nodes = CSV.read(@csvname) # Load array to store host:MAC pairs in

trap "SIGINT" do
	puts "\nExiting abruptly..."
	CSV.open(@csvname, 'w+') { |csv| @nodes.each { |elem| csv << elem } }
	puts "Node list written to \'#{@csvname}\'."
	exit 130
end

server = TCPServer.open(@port) # start listening over port specified in config

def check_for_duplicate(host,mac)
	for row in @nodes
		if [host,mac] == row
			return ["both","both"]
		elsif host == row[0]
			return ["host",row[1]]
		elsif mac == row[1]
			return ["mac",row[0]]
		else
			false
		end
	end
end

def dupe_handler(host,mac)
	dupe_check = check_for_duplicate(host,mac)
	if dupe_check[0] == "both"
		puts "This exact host/MAC pair already exists in the CSV."
	elsif dupe_check[0] == "host"
		puts "A node already exists with the name \"#{host}\" under address \"#{dupe_check[1]}\". Please choose something else."
	elsif dupe_check[0] == "mac"
		puts "A node already exists with the address \"#{mac}\". It is named \"#{dupe_check[1]}\"."
	else
		puts "Node added\nHostname: #{host}\nMAC address: #{mac}\n"
		@nodes.push([host, mac])
	end
end

queue = Queue.new

logger = Thread.new do
	loop do
		client = server.accept
		while line = client.gets
			queue << line
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
	value = queue.pop
	mac,host = value.split(' ')
	puts "Node found. Hostname = \"#{host}\", MAC address = \"#{mac}\". How would you like this node to be saved? (default: #{host})."
	puts 'Enter name: '
	input = gets.chomp
	unless input == ""
		host = input
	end
	dupe_handler(host, mac)

	puts 'Enter \'q\' to quit, enter anything else to continue... '
	if gets.chomp == 'q'
		break
	else
	end
	waiting = false
end

CSV.open(@csvname, 'w+') { |csv| @node.each { |elem| csv << elem } }
puts "Node list written to \'#{@csvname}\'."
