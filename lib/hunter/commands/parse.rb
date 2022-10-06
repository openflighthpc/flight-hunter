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
require 'yaml'

require_relative '../command'
require_relative '../config'

module Hunter
  module Commands
    class Parse < Command
      def run
        buffer = NodeList.load(Config.node_buffer)
        raise "No nodes in buffer" if buffer.nodes.empty?
        parsed = NodeList.load(Config.node_list)
        
        choices = to_choices(buffer.nodes)

        kept = prompt.multi_select("Select the nodes that you wish to save:", choices)
        existing = kept.select { |n| parsed.nodes.any? { |o| o.id == n.id } }
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
        parsed.nodes.concat(final)
        if parsed.save
          puts "Nodes saved to parsed node list."
        end
      end

      private

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
