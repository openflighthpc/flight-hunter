#!/usr/bin/env ruby
# frozen_string_literal: true

#==============================================================================
# Copyright (C) 2019-present Alces Flight Ltd.
#
# This file is part of Hunter.
#
# This program and the accompanying materials are made available under
# the terms of the Eclipse Public License 2.0 which is available at
# <https://www.eclipse.org/legal/epl-2.0>, or alternative license
# terms made available by Alces Flight Ltd - please direct inquiries
# about licensing to licensing@alces-flight.com.
#
# Hunter is distributed in the hope that it will be useful, but
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, EITHER EXPRESS OR
# IMPLIED INCLUDING, WITHOUT LIMITATION, ANY WARRANTIES OR CONDITIONS
# OF TITLE, NON-INFRINGEMENT, MERCHANTABILITY OR FITNESS FOR A
# PARTICULAR PURPOSE. See the Eclipse Public License 2.0 for more
# details.
#
# You should have received a copy of the Eclipse Public License 2.0
# along with Hunter. If not, see:
#
#  https://opensource.org/licenses/EPL-2.0
#
# For more information on Hunter, please visit:
# https://github.com/openflighthpc/hunter
#===============================================================================
require 'tty-markdown'

module FlightHunter
	module Server
		class ListNodes
			def list_nodes(list_file)
				list = YAML.load(File.read(list_file)) || {}
				if list.nil? || list.empty?
					puts "The list is empty."
				else
					table = <<~TABLE.chomp
						| MAC address | Name | Has payload? |
						|-------------|------|--------------|
					TABLE

					all = list.reduce(table) do |memo, (mac,vals)|
						"#{memo}\n| #{mac} | #{list[mac]["hostname"]} | #{list[mac].length > 1} |"
					end
					puts TTY::Markdown.parse(all)
				end
			end
		end
	end
end
