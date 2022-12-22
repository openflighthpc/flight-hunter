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
    class Interactive < Command
      def run
        @buffer = NodeList.load(Config.node_buffer)
        raise "No nodes in buffer" if @buffer.nodes.empty?
        @parsed = NodeList.load(Config.node_list)

        choices = to_choices(@buffer.nodes)
        defaults = []
        @original = []
        @continue = true

        while @continue
          answers = prompt.ordered_multi_select(
            "Select nodes:",
            choices,
            edit_labels: true,
            quiet: true,
            default: defaults,
            help: "(Scroll for more nodes)",
            show_help: :start,
            per_page: 10,
            original: @original
          )

          if !answers.is_a?(Hash)
            @continue = false
            next
          end

          choices = answers[:choices].map { |c| { c.name => c.value } }.reduce({}, :merge)
          @original = answers[:choices].dup

          reserved = []
          @parsed.nodes.each { |n| reserved << n.label }
          choices.each { |c| reserved << c[1].label }

          name = prompt.ask("Choose label:", quiet: true) do |q|
            q.validate ->(input) { !reserved.include?(input) }, "Label already exists"
          end

          new_node = answers[:active_choice].value.tap do |n|
            n.label = name
          end

          new_key = { "#{answers[:active_choice]} (#{name})" => new_node }

          insertable_index = choices.find_index { |k,_| k == answers[:active_choice].name }

          left_half = choices.reject do |c|
            choices.find_index { |k,_| k == c } >= insertable_index
          end

          right_half = choices.reject do |c|
            choices.find_index { |k,_| k == c } <= insertable_index
          end

          choices.delete(answers[:active_choice].name)
          choices = left_half.merge(new_key).merge(right_half)
          #choices = new_key.merge(mutable_choices)

          defaults << new_key.keys.first
        end

        existing = @parsed.nodes.select { |old| answers.any? { |n| old.id == n.id } }
        @parsed.delete(existing)
        @parsed.nodes.concat(answers)
        @buffer.delete(answers)

        if @parsed.save && @buffer.save
          puts "Nodes saved to parsed node list:"

          t = Table.new
          t.headers('ID', 'Label', 'Hostname', 'IP', 'Groups')
          answers.each do |n|
            t.row(n.id, n.label, n.hostname, n.ip, n.groups&.join(", "))
          end
          t.emit
        end
      end

      private

      def to_choices(nodes)
        nodes.map do |n|
          name = [n.hostname.to_s, n.ip].reject(&:empty?).join(" - ")
          { "#{name}" => n }
        end.reduce({}, :merge)
      end

      def prompt
        @prompt ||= TTY::Prompt.new(help_color: :yellow)
      end
    end
  end
end
