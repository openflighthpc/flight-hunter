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


options = {}
options[:ignoredupes] = true

OptionParser.new do |opts|
	opts.banner = "Usage: server.rb [options] [arguments]"
	opts.on('-f','--find','Listen over TCP for incoming clients, save them to a local file for processing.') do
		options[:mode] = 'f'
	end
	opts.on('-a','--automatic','Parse saved clients and name them automatically.') do 
		options[:mode] = 'a'
	end
	opts.on('-d','--ignoredupes','testing') do
		options[:ignoredupes] = false
	end
	opts.on('-m', '--manual', 'Parsed saved clients and name them manually') do 
		options[:mode] = 'm'
	end
	opts.on('-l', '--list', 'List nodes in saved list') do 
		options[:mode] = 'l'
	end
	opts.on('-r', '--remove', 'Delete a client from the saved list') do 
		options[:mode] = 'd'
	end
	opts.on('-e', '--edit', 'Edit a client from the saved list') do 
		options[:mode] = 'e'
	end	
	opts.on('-h','--help','display this screen') do
		puts opts
		exit
	end
end.parse!(into: options)
puts options

config = YAML.load_file('config.yaml')
nodelist_file = config['nodelist']
not_processed_file = config['unprocessed_list']
port = config['port']

[nodelist_file,not_processed_file].each do |file|
	if not File.file?(file)
		puts "\nSpecified file \"#{file}\" doesn't exist. Creating..."
		CSV.open(file,'w')
		puts "Created CSV file named \"#{file}\"."
	end
end

@not_processed = CSV.read(not_processed_file)
@nodelist = CSV.read(nodelist_file)


case options[:mode]
when 'f'
	trap "SIGINT" do
		puts "\nExiting abruptly..."
		CSV.open(not_processed_file,'w+') { |csv| @unprocessed_list.each { |elem| csv << elem } }
		puts "Found nodes written to \'#{unprocessed_list}\'. They need processing."
		exit 130
	end
	server = TCPServer.open(port)
	puts "Press Ctrl-C at any time to exit."
	loop do
		client = server.accept
		while line = client.gets
			host,mac = line.split(' ')
			case options[:ignoredupes]
			when true
				if (@nodelist.map {|row| row[1]} | @not_processed.map {|row| row[1] }).include?(mac)

				else
					@unprocessed_list.push([host,mac])
				end
			when false
				@unprocessed_list.push([host,mac])
			end
		end
		client.close
	end
when 'a'
	prefix,length,start = ARGV
	puts "prefix: #{prefix}, #{prefix.class}"
	puts "length: #{length}, #{length.class}"
	puts "start: #{start}, #{start.class}"

	@not_processed.each do |node|
		new_node = [ prefix + start, node[1]]
		start = start.succ
		@nodelist.push(new_node)
		
	end
	CSV.open(nodelist_file,'a+') {|csv| @nodelist.each { |elem| csv << elem} }
	CSV.open(not_processed_file,'w+')
when 'l'	
	puts "Name\tMAC address\n"
	puts "-------------------"
	@nodelist.each do |node|
		puts "#{node[0]}\t#{node[1]}"
	end
when 'd'
	
when 'e'
end
