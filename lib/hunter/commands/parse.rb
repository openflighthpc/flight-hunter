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
require 'tty-prompt'

require_relative '../command'
require_relative '../config'

module Hunter
  module Commands
    class Parse < Command
      def run
        @buffer = NodeList.load(Config.node_buffer)
        raise "No nodes in buffer" if @buffer.nodes.empty?
        @parsed = NodeList.load(Config.node_list)

        labels = generate_labels

        final =
          case @options.auto
          when true
            automatic_parse(labels)
          when false
            manual_parse(labels)
          end

        final.each_with_index do |node, idx|
          node.label = labels[idx] 
        end
        
        existing_labels = final.map(&:label).select { |l| @parsed.include_label?(l) }
        if existing_labels.any?
          raise <<~ERROR
          The following labels already exist in the parsed list:
          #{existing_labels.join("\n")}
          ERROR
        end

        existing = @parsed.nodes.select { |old| final.any? { |n| old.id == n.id } }
        @parsed.delete(existing)
        @parsed.nodes.concat(final)
        @buffer.delete(final)

        if @parsed.save && @buffer.save
          puts "Nodes saved to parsed node list:"

          t = Table.new
          t.headers('ID', 'Label', 'Hostname', 'IP', 'Groups')
          final.each do |n|
            t.row(n.id, n.label, n.hostname, n.ip, n.groups&.join(", "))
          end
          t.emit
        end
      end

      private

      def check_label_range(list, start)
        if list.nodes.length > 10 ** start.length - start.to_i
          raise "The number of nodes to process is greater than the number "\
                "of names possible with the given PREFIX and START."
        end
      end

      def generate_labels
        if auto_labels?
          prefix = @options.prefix
          start = @options.start

          [].tap do |arr|
            @buffer.nodes.length.times do |idx|
              iteration = start.to_i + idx
              padding = '0' * (start.length - iteration.to_s.length).abs
              count = padding + iteration.to_s
              arr << prefix + count
            end
          end
        else
          @buffer.nodes.map(&:hostname)
        end
      end

      def auto_labels?
        if @options.prefix && @options.start
          true
        elsif @options.prefix.nil? != @options.start.nil?
          raise 'Please specify both a PREFIX *and* a START value or omit both.'
        else
          false
        end
      end

      def manual_parse(labels)
        choices = to_choices(@buffer.nodes)
        
        max = nil
        if @options.start
          max = 10 ** @options.start.length - @options.start.to_i
        end

        kept = prompt.ordered_multi_select(
          "Select the nodes that you wish to save:",
          choices,
          help: "(Scroll for more nodes)",
          show_help: :always,
          per_page: 10,
          max: max
        )
        existing = kept.select { |n| @parsed.nodes.any? { |o| o.id == n.id } }
        overwrite = []
        if existing.any?
          choices = to_choices(existing)
          overwrite << prompt.multi_select(
            "The following nodes already exist in the parsed list."\
            "Please confirm the nodes you wish to overwrite.",
            choices
          )
        end

        final = existing.any? ? kept & overwrite : kept
        return final
      end

      def automatic_parse(labels)
        check_label_range(@buffer, @options.start)
        existing = @parsed.nodes.select { |pn| @buffer.nodes.any? { |bn| pn.id == bn.id } }
        if !@options.allow_existing && existing.any?
          raise "The following IDs already exist in the parsed list:\n"\
                "#{existing.map(&:id).join("\n")}"
        end
        @buffer.nodes
      end

      def to_choices(nodes)
        nodes.map do |n|
          { "#{n.hostname} (#{n.ip})".to_sym => n }
        end.reduce({}, :merge)
      end

      def prompt
        @prompt ||= TTY::Prompt.new(help_color: :yellow)
      end
    end
  end
end
