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
module FlightHunter
  class Config
    def self.root_dir
      File.expand_path('..', __dir__)
    end

    def self.join_content(*a)
      File.join(root_dir, 'var', 'flight-hunter', *a)
    end

    def self.join_client_content(*a)
      join_content('client', *a)
    end

    def self.join_server_content(*a)
      join_content('server', *a)
    end

    def self.data
      {
        clientport: YAML.load(File.read("#{Config.root_dir}/etc/client-config.yaml"))["port"],
        serverport: YAML.load(File.read("#{Config.root_dir}/etc/server-config.yaml"))["port"],
        ipaddr: YAML.load(File.read("#{Config.root_dir}/etc/client-config.yaml"))["ipaddr"]
      }     
    end
  end
end

$LOAD_PATH.unshift(File.join(FlightHunter::Config.root_dir, 'lib'))

require 'flight_hunter/client/send'
require 'flight_hunter/client/modify_ip'
require 'flight_hunter/client/modify_port'
require 'flight_hunter/server/hunt'
require 'flight_hunter/server/list'
require 'flight_hunter/server/manual'
require 'flight_hunter/server/automatic'
require 'flight_hunter/server/remove_mac'
require 'flight_hunter/server/remove_name'
require 'flight_hunter/server/modify_port'
require 'flight_hunter/server/modify_mac'
require 'flight_hunter/server/modify_name'
require 'flight_hunter/server/dump_buffer'
require 'flight_hunter/server/show_node'

require 'csv'
require 'commander'
require 'yaml'

module FlightHunter
  class CLI
    extend Commander::Delegates

    program :name, 'hunter'
    program :version, '0.0.1'
    program :description, 'MAC collection tool' 
    program :help_paging, false

    buffer = Config.join_server_content('buffer.yaml')
    parsed = Config.join_server_content('parsed.yaml')

    [buffer, parsed].each do |file|
      if not File.file?(file)
        puts "\nSpecified file \"#{ file }\" doesn't exist. Creating..."
        File.write(file,'')
        puts "Created YAML file named \"#{ file }\"."
      end
    end

    command 'send' do |c|
      c.summary = 'Send MAC/hostname plus optional payload to server.'
      c.option '--file FILE', 'Specify a filepath to send.'
      c.action do |args, options|
        ipaddr = Config.data[:ipaddr]
        port = Config.data[:port]
        filepath = options.file if options.file
        Client::Send.new.send_mac(ipaddr,port,filepath)
      end
    end

    command 'modify-ip' do |c|
      c.summary = 'Change IP to open a connection with.'
      c.action do |args, _|
        Client::ModifyIP.new.modify_ip(args[0],File.join(Config.root_dir,'etc','client-config.yaml'))
      end
      puts 
    end

    command 'modify-client-port' do |c|
      c.summary = 'Change port to open a connection over.'
      c.action do |args, _|
        Client::ModifyPort.new.modify_port(File.join(Config.root_dir,'etc','client-config.yaml'),args[0])
      end
    end

    command 'hunt' do |c|
      c.summary = 'Listen for broadcasting clients'
      c.action do |args, _|
        port = Config.data[:port]
        allow_existing = 
          case args[0]
          when 'allow-existing'
            true
          else
            false            
          end
        Server::Hunt.new.hunt(port, buffer, parsed, allow_existing)
      end
    end

    command 'list-buffer' do |c|
      c.summary = 'List the nodes in the buffer.'
      c.action do |args, _|
        Server::ListNodes.new.list_nodes(buffer)
      end
    end

    command 'list-parsed' do |c|
      c.summary = 'List the parsed nodes.'
      c.action do |args, _|
        Server::ListNodes.new.list_nodes(parsed)
      end
    end
    command 'show-node' do |c|
      c.syntax = "#{ program(:name) } NAME"
      c.summary = 'Show the details of a particular node.'
      c.action do |args, _|
        name = args[0]
        Server::ShowNode.new.show_node(parsed, name)
      end
    end

    command 'parse-manual' do |c|
      c.summary = 'Manually process the node buffer.'
      c.action do |args, _|
        Server::ManualParse.new.manual(buffer,parsed)
      end
    end

    command 'parse-automatic' do |c|
      c.syntax = "#{ program(:name) } PREFIX LENGTH START"
      c.summary = 'Automatically process the node buffer.'
      c.action do |args, _|
        prefix,length,start = args
        Server::AutomaticParse.new.automatic(buffer,parsed,prefix,length,start)
      end
    end

    command 'remove-mac' do |c|
      c.syntax = "#{ program(:name) } MAC"
      c.summary = 'Remove a node from the parsed list by MAC.'
      c.action do |args, _|
        mac = args
        Server::RemoveMac.new.remove_mac(parsed,mac)
      end
    end

    command 'remove-name' do |c|
      c.syntax = "#{ program(:name) } NAME"
      c.summary = 'Remove an node from the parsed list by NAME.'
      c.action do |args, _|
        hostname = args
        Server::RemoveName.new.remove_name(parsed,hostname)
      end
    end

    command 'modify-server-port' do |c|
      c.syntax = "#{ program(:name) } PORT"
      c.summary = 'Modify the port to listen over when hunting.'
      c.action do |args, _|
        port = args[0]
        Server::ModifyPort.new.modify_port(File.join(Config.root_dir,'etc','server-config.yaml'), port)
      end
    end

    command 'modify-mac' do |c|
      c.syntax = "#{ program(:name) } OLDMAC NEWMAC"
      c.summary = 'Modify the MAC of a node in the parsed list.'
      c.action do |args, _|
        oldmac, newmac = args
        Server::ModifyMac.new.modify_mac(parsed, oldmac, newmac)
      end
    end

    command 'modify-name' do |c|
      c.syntax = "#{program(:name)} OLDNAME NEWNAME"
      c.summary = 'Modify the name of a node in the parsed list.'
      c.action do |args, _|
        oldname, newname = args
        Server::ModifyName.new.modify_name(parsed, oldname, newname)
      end
    end

    command 'dump-buffer' do |c|
      c.summary = 'Wipe the contents of the node buffer.'
      c.action do |args, _|
        Server::DumpBuffer.new.dump_buffer(buffer)
      end
    end
  end
end

FlightHunter::CLI.run! if $PROGRAM_NAME == __FILE__