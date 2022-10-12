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
    class ModifyGroups < Command
      def run
        buffer = @options.buffer
        list_file = buffer ? Config.node_buffer : Config.node_list
        list = NodeList.load(list_file)

        to_add = @options.add&.split(",") || []
        to_remove = @options.remove&.split(",") || []

        nodes = 
          case @options.regex
          when true
            list.match(Regexp.new(args[0]))
          when false
            [list.find(id: args[0])]
          end
        
        raise "No nodes in list '#{list.name}' match pattern '#{args[0]}'" unless nodes.any?

        nodes.each do |n|
          n.add_groups(to_add)
          n.remove_groups(to_remove)
        end

        list.save

        puts "Node(s) updated successfully:"
        
        t = Table.new
        t.headers('ID', 'Hostname', 'Groups')
        nodes.each do |n|
          t.row(n.id, n.hostname, n.groups.join(", "))
        end
        t.emit
      end
    end
  end
end
