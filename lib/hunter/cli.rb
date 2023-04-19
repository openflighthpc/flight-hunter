#==============================================================================
# Copyright (C) 2022-present Alces Flight Ltd.
#
# This file is part of Flight Hunter.
#
# This program and the accompanying materials are made available under
# the terms of the Eclipse Public License 2.0 which is available at
# <https://www.eclipse.org/legal/epl-2.0>, or alternative license
# terms made available by Alces Flight Ltd - please direct inquiries
# about licensing to licensing@alces-flight.com.
#
# Flight Hunter is distributed in the hope that it will be useful, but
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, EITHER EXPRESS OR
# IMPLIED INCLUDING, WITHOUT LIMITATION, ANY WARRANTIES OR CONDITIONS
# OF TITLE, NON-INFRINGEMENT, MERCHANTABILITY OR FITNESS FOR A
# PARTICULAR PURPOSE. See the Eclipse Public License 2.0 for more
# details.
#
# You should have received a copy of the Eclipse Public License 2.0
# along with Flight Hunter. If not, see:
#
#  https://opensource.org/licenses/EPL-2.0
#
# For more information on Flight Hunter, please visit:
# https://github.com/openflighthpc/flight-hunter
#==============================================================================
require_relative 'commands'
require_relative 'version'

require 'tty/reader'
require 'commander'
require 'erb'

module Hunter
  module CLI
    PROGRAM_NAME = ENV.fetch('FLIGHT_PROGRAM_NAME','hunter')

    extend Commander::CLI
    program :application, "Flight Hunter"
    program :name, PROGRAM_NAME
    program :version, "v#{Hunter::VERSION}"
    program :description, 'MAC collection tool'
    program :help_paging, false
    default_command :help

    if [/^xterm/, /rxvt/, /256color/].all? { |regex| ENV['TERM'] !~ regex }
      Paint.mode = 0
    end

    class << self
      def cli_syntax(command, args_str = nil)
        command.syntax = [
          PROGRAM_NAME,
          command.name,
          args_str
        ].compact.join(' ')
      end
    end

    command :hunt do |c|
      cli_syntax(c)
      c.summary = 'Listen for broadcasting clients'
      c.slop.bool '--allow-existing', 'Allow replacement of existing entries'
      c.slop.string '--port', 'Override port'
      c.slop.bool '--include-self', 'Immediately try to send payload to self'
      c.slop.string '--auth', "Override default authentication key"
      c.slop.string '--auto-parse', 'Automatically parse nodes matching this regex'
      c.action Commands, :hunt
    end

    command :autorun do |c|
      cli_syntax(c)
      c.summary = 'Interpret running mode from config or environment'
      c.action do |args, opts|
        case Config.autorun_mode
        when 'hunt'
          Commands::Hunt.new(args, opts).run!
        when 'send'
          Commands::SendPayload.new(args, opts).run!
        else
          raise "Autorun mode provided is invalid."
        end
      end
    end

    command 'dump-buffer' do |c|
      cli_syntax(c)
      c.summary = 'Drop all nodes in the buffer list'
      c.action Commands, :dump_buffer
    end

    command 'list' do |c|
      cli_syntax(c)
      c.summary = 'Show the nodes in the parsed list'
      c.slop.bool '--plain', 'Print in machine-readable manner'
      c.slop.bool '--by-group', 'Group nodes by group'
      c.slop.bool '--buffer', "Use node buffer list instead of parsed"
      c.action Commands, :list
    end

    command :show do |c|
      cli_syntax(c, 'NODE')
      c.summary = 'Show details of node in parsed list by label'
      c.slop.bool '--buffer', "Use node buffer list instead of parsed (use ID instead of label here)"
      c.slop.bool '--plain', "Print in machine-readable format"
      c.action Commands, :show
    end

    command 'remove-node' do |c|
      cli_syntax(c, 'NODE')
      c.summary = 'Remove node from parsed list by label'
      c.slop.bool '--buffer', "Use node buffer list instead of parsed (use ID instead of label here)"
      c.slop.bool '--name', "Specify node by regex on hostname instead of ID"
      c.action Commands, :remove_node
    end

    command 'modify-groups' do |c|
      cli_syntax(c, 'NODE')
      c.summary = 'Add or remove groups from a node by label'
      c.slop.string '--add', 'Comma separated list of groups to add', meta: 'GROUPS'
      c.slop.string '--remove', 'Comma separated list of groups to remove', meta: 'GROUPS'
      c.slop.bool '--buffer', "Use node buffer list instead of parsed (use ID instead of label here)"
      c.slop.bool '--regex', "Match all hostnames with regex NODE"
      c.action Commands, :modify_groups
    end

    command 'modify-label' do |c|
      cli_syntax(c, 'OLD_LABEL NEW_LABEL')
      c.summary = 'Change label of node OLD_LABEL to NEW_LABEL'
      c.action Commands, :modify_label
    end

    command 'rename-group' do |c|
      cli_syntax(c, 'GROUP NEW_NAME')
      c.summary = 'Rename group and keep all nodes it contains'
      c.slop.bool '--buffer', "Use node buffer list instead of parsed"
      c.action Commands, :rename_group
    end

    command :parse do |c|
      cli_syntax(c)
      c.summary = 'Interactively move nodes from buffer to parsed list'
      c.slop.string '--prefix', "Prefix for the generated labels"
      c.slop.string '--start', "Start value for the numeric portion of the labels"
      c.slop.bool '--auto', "Automatically process everything in buffer list"
      c.slop.bool '--allow-existing', 'Allow replacement of existing entries'
      c.slop.bool '--skip-used-index', 'Ignore errors if a label index is already in use'
      c.action Commands, :parse
    end

    command :send do |c|
      cli_syntax(c)
      c.summary = 'Push my identity plus optional additional details to server'
      c.slop.string '-c', '--command', "Command to use to generate sent content"
      c.slop.integer '-p', '--port', "Override server port"
      c.slop.string '-s', '--server', "Override server hostname"
      c.slop.string "--auth", "Override default authentication key"
      c.slop.bool '--broadcast', "Send identity to all nodes on a given subnet"
      c.slop.string "--broadcast-address", "Specify a broadcast address to use if broadcasting"
      c.slop.array "--groups", "Specify a comma-separated list of groups for this node"
      c.slop.string "--label", "Specify a label to use for this node"
      c.slop.string "--prefix", "Specify a prefix to use for this node"
      c.action Commands, :send_payload
    end
  end
end
