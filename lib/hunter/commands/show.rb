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
require_relative '../command'
require_relative '../table'
require_relative './concerns/node_utils'

module Hunter
  module Commands
    class Show < Command
      include NodeUtils

      def run
        node = node_fetcher.scan([args[0]]).first

        raise "No #{node_fetcher.search_field} '#{args[0]}' found in list '#{list.name}'" unless node

        if @options.plain
          a = [
            node.id,
            node.hostname,
            node.ip,
            node.groups.any? ? node.groups.join("|") : "|",
            node.content
          ]
          puts a.join("\t")
        else
          Table.from_nodes([node], buffer: @options.buffer).emit
          puts node.content
        end
      end

      private

      def cli_parser
        @cli_parser ||= CLIParser.new
      end

      def node_fetcher
        @node_fetcher ||= NodeFetcher.new(buffer: @options.buffer)
      end

      def list
        node_fetcher.list
      end
    end
  end
end
