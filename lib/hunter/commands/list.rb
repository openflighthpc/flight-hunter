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

require 'yaml'

require_relative '../command'
require_relative '../table'

module Hunter
  module Commands
    class List < Command
      def run
        list_file = @options.buffer ? Config.node_buffer : Config.node_list
        list = NodeList.load(list_file)

        if @options.plain
          list.nodes.each do |n|
            a = [
              n.id,
              n.hostname,
              n.ip,
              n.groups.any? ? n.groups.join("|") : "|",
              n.label,
              n.presets.to_json,
              n.mac
            ]
            puts a.join("\t")
          end
        else
          raise "No nodes to display" if list.nodes.empty?

          case @options.by_group
          when true
            list.nodes(by_group: true).each do |group, nodes|
              puts "Group '#{group}':"
              
              Table.from_nodes(list.nodes, buffer: @options.buffer).emit
            end
          when false
            Table.from_nodes(nodes, buffer: @options.buffer).emit
          end
        end
      end
    end
  end
end
