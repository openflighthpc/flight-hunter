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

module Hunter
  module Commands
    class RenameGroup < Command
      def run
        buffer = NodeList.load(Config.node_buffer)
        parsed = NodeList.load(Config.node_list)
        old = args[0]
        new = args[1]

        unless [buffer, parsed].any? { |list| list.nodes.map(&:groups).flatten.uniq.include?(old) }
          raise "Group '#{old}' does not exist in either node list"
        end

        [buffer, parsed].each do |list|
          list.nodes.each do |node|
            node.groups.map! { |g| g == old ? new : g }.uniq!
          end
          list.save
        end

        puts "Group '#{old}' renamed to '#{new}'"
      end
    end
  end
end
