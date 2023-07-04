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

module Hunter
  module Commands
    class RemoveNode < Command
      def run
        buffer = @options.buffer
        list_file = buffer ? Config.node_buffer : Config.node_list
        list = NodeList.load(list_file)

        attribute = @options.match_hostname ? :hostname : search_field(buffer)

        nodes =
          case @options.regex
          when true
            list.select { |n| n.public_send(attribute) =~ Regexp.new(args[0]) }
          when false
            search_terms = args[0].split(',')
            list.select { |n| search_terms.include?(n.public_send(attribute)) }
          end

        unless nodes.any?
          raise <<~OUT.chomp
          No #{attribute}s in list '#{list.name}' found with given pattern(s).
          OUT
        end

        if list.delete(nodes) && list.save
          puts "The following nodes have successfully been removed from list '#{list.name}'"

          Table.from_nodes(nodes, buffer: buffer).emit
        end
      end
    end
  end
end
