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


# ENTRY POINT FOR HUNTER SERVICE

require 'csv'
require 'yaml'
require 'optparse'

Dir["client/*.rb"].each {|file| require_relative file}
Dir["server/*.rb"].each {|file| require_relative file}



case ARGV[0]
when "client"
	config = YAML.load_file('client/config.yaml')
	case ARGV[1]
	when "send"
		ipaddr = config['ipaddr']
		port = config['port']
		send_mac(ipaddr,port)
	when "modify"
		case ARGV[2]
		when "ip"
			modify_ip(ARGV[3],config)
		when "port"
			modify_port(ARGV[3],config)
		end
	end
when "server"
	config = YAML.load_file('server/config.yaml')
	not_processed_file = 'server/' + config['not_processed_list']
	nodelist_file = 'server/' + config['nodelist']
	[nodelist_file,not_processed_file].each do |file|
		if not File.file?(file)
			puts "\nSpecified file \"#{file}\" doesn't exist. Creating..."
			File.open(file,'w') {}
			puts "Created YAML file named \"#{file}\"."
		end
	end	
	not_processed = YAML.load(read_yaml(not_processed_file)) || {}
	nodelist = YAML.load(read_yaml(nodelist_file)) || {}

	case ARGV[1]
	when "hunt"
		port = config['port']
		hunt(port, not_processed_file, nodelist_file,ARGV[2])		
	when "list"
		case ARGV[2]
		when "not_processed"
			list_nodes(not_processed)
		when "nodelist"
			list_nodes(nodelist)
		end

	when "parse"
		case ARGV[2]
		when "manual"
			manual(config)
		when "automatic"
			automatic(config,ARGV[3],ARGV[4],ARGV[5])
		end
	when "remove"
		case ARGV[2]
		when "mac"
			remove_mac(config,ARGV[3],ARGV[4])
		when "name"
			remove_name(config,ARGV[3],ARGV[4])
		end
	when "modify"
		case ARGV[2]
		when "mac"
			modify_mac(config,ARGV[3],ARGV[4],ARGV[5])
		when "name"
			modify_name(config,ARGV[3],ARGV[4],ARGV[5])
		when "not_processed"
			modify_not_processed(config, ARGV[3])
		when "nodelist"
			modify_nodelist(config,ARGV[3])
		when "port"
			modify_port(config,ARGV[3])
		end
	end
end