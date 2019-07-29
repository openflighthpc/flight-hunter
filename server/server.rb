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
		options[:mode] = 'r'
	end
	opts.on('-e', '--edit', 'Edit a client from the saved list') do 
		options[:mode] = 'e'
	end	
	opts.on('-h','--help','display this screen') do
		puts opts
		exit
	end
end.parse!()

config = YAML.load_file('config.yaml')
nodelist_file = config['nodelist']
not_processed_file = config['not_processed_list']
port = config['port']

[nodelist_file,not_processed_file].each do |file|
	if not File.file?(file)
		puts "\nSpecified file \"#{file}\" doesn't exist. Creating..."
		File.open(file,'w') {}
		puts "Created YAML file named \"#{file}\"."
	end
end

def read_yaml(file_name)
	file = File.open(file_name,'r')
	file.sync = true
	data = file.read
	file.close
	return data
end


@not_processed = YAML.load(read_yaml(not_processed_file),{})
@nodelist = YAML.load(read_yaml(nodelist_file),{})


case options[:mode]
when 'f'
	server = TCPServer.open(port)
	Thread.new do
		loop do
			client = server.accept
			while line = client.gets
				host,mac = line.split(' ')
				case options[:ignoredupes]
				when true
					if @nodelist.key?(mac) || @not_processed.key?(mac)
					else
						@not_processed[mac] = host
					end
				when false
					@not_processed[mac] = host
				end
			end
		end
		client.close
	end
	puts "Press enter at any time to close.\n"
	while gets.chomp
		puts "\nExiting..."
		File.open(not_processed_file,'w+') { |file| file.write(@not_processed.to_yaml)}
		puts "Found nodes written to \'#{not_processed_file}\'. They need processing."
		exit 130
	end

when 'a'
	prefix,length,start = ARGV

	@not_processed.each do |mac,hname|
		@nodelist[mac] = prefix + start
		start = start.succ
	end
	File.open(nodelist_file,'w+') {|file| file.write(@nodelist.to_yaml)}
	File.open(not_processed_file,'w+')

when 'm'
	@not_processed.each do |mac,hname|
		puts "Enter name for MAC \"#{mac}\": "
		input = gets.chomp
		@nodelist[mac] = input
	end
	File.open(nodelist_file,'w+') {|file| file.write(@nodelist.to_yaml)}
	File.open(not_processed_file,'w+')
	puts "#{not_processed_file} emptied; processed nodes written to #{nodelist_file}."

when 'l'	
	begin
		puts "MAC address\t   Name\n"
		puts "------------------------"
		@nodelist.each do |mac,hname|
			puts "#{mac}: #{hname}"
		end
	rescue NoMethodError => e
		puts "The node list is empty."
	end
when 'r'
	mac = ARGV[0]
	@nodelist.delete(@nodelist.key(mac))
	File.open(nodelist_file,'w+') {|file| file.write(@nodelist.to_yaml)}
	puts mac.to_s + ' : ' + @nodelist[mac] + " deleted."

when 'e'
	mac, newname = ARGV
	if [mac,newname] & [nil,"", " "] != []
		puts "You have left out at least one required argument."
	else		
		@nodelist[mac] = newname
		File.open(nodelist_file,'a+') {|file| file.write(@nodelist.to_yaml)}
		puts "#{mac} renamed to #{newname}"
	end
end
