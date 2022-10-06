# #==============================================================================
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
    class Process < Command
      def run
        buffer = NodeList.load(Config.node_buffer)
        #raise "No nodes in buffer" if buffer.nodes.empty?
        parsed = NodeList.load(Config.node_list)

        start = @options.start
        prefix = @options.prefix

        if @options.prefix.nil? != @options.start.nil?
          raise 'Please specify both a PREFIX *and* a START value or omit both.'
        end

        if buffer.nodes.length > name_range(start)
          raise "The number of nodes to process is greater than the number "\
                "of names possible with the given PREFIX and START."
        end

        existing = parsed.nodes.select { |bn| buffer.nodes.any? { |pn| pn.id == bn.id } }
        if !@options.allow_existing && existing.any?
          raise "The following IDs already exist in the parsed list:\n"\
                "#{existing.map(&:id).join("\n")}"
        end

        parsed.remove_nodes(existing)

        new_nodes = []
        buffer.nodes.each_with_index do |node, idx|
          name =
            case prefix.nil?
            when true
              node.hostname
            when false
              iteration = start.to_i + (idx - 1)
              padding = '0' * (start.length - iteration.to_s.length)
              count = padding + iteration.to_s
              prefix + count
            end

          new_nodes << node.dup.tap { |n| n.hostname = name }
        end

        if parsed.nodes.concat(new_nodes) && parsed.save
          puts "Nodes saved to parsed node list:"

          t = Table.new
          t.headers('ID', 'Hostname', 'Groups')
          new_nodes.each do |n|
            t.row(n.id, n.hostname, n.groups&.join(", "))
          end
          t.emit
          buffer.empty
        end
      end

      private

      def name_range(start)
        return Float::INFINITY if start.nil?
        (10 ** start.length).to_i - start.to_i
      end
    end
  end
end
