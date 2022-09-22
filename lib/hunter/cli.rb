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

    command :send do |c|
      cli_syntax(c)
      c.summary = 'Push my identity plus optional payload to server.'
      c.slop.string '-f', '--file', "Specify a payload file"
      c.slop.string '-s', '--server', "Override server hostname"
      c.slop.integer '-p', '--port', "Override server port"
      c.slop.string '--spoof', "Override system hostname"
      c.action Commands, :send_payload
    end
  end
end