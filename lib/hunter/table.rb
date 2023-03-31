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

require 'tty-table'

module Hunter
  class Table
    def initialize
      @table = TTY::Table.new(header: [''])
      @table.header.fields.clear
      @padding = [0,1]
    end

    def emit
      puts @table.render(
        :unicode,
        {}.tap do |o|
          o[:padding] = @padding unless @padding.nil?
          o[:multiline] = true
        end
      )
    end

    def self.from_nodes(nodes, buffer: false)
      new.tap do |table|
        headers = case buffer
                  when true
                    ['ID', 'Hostname', 'IP', 'MAC', 'Groups', 'Presets']
                  when false
                    ['ID', 'Label', 'Hostname', 'IP', 'MAC', 'Groups']
                  end
        rows = nodes.map { |n| n.to_table_row(buffer: buffer) }

        table.headers(*headers)
        table.rows(*rows)
      end
    end

    def padding(*pads)
      @padding = pads.length == 1 ? pads.first : pads
    end

    def headers(*titles)
      titles.each_with_index do |title, i|
        @table.header[i] = title
      end
    end

    # Add single row from single array
    def row(*vals)
      @table << vals
    end
    
    # Add multiple rows from nested array
    def rows(*vals)
      vals.each do |r|
        @table << r
      end
    end
  end
end

