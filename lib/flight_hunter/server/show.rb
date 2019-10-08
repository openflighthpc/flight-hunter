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
		class Show
			def show(parsed, name, plain=false)
				list = YAML.load(File.read(parsed)) || {}
				if list.nil? || list.empty?
					puts "The list is empty."
				else
					list.each do |id,vals|
						if vals["hostname"] == name
							if !plain
								table = <<~TABLE.chomp
									| ID          | Name |
									|-------------|------|
									| #{id}       | #{vals["hostname"]} |
								TABLE

								puts TTY::Markdown.parse(table)
								if vals.key?("payload")
									puts vals["payload"]
								else
									puts "#{name} has no payload associated with it."
								end
								return
							else
								puts "#{id}: #{name}"
								puts vals["payload"] rescue false
								return
							end
						end
					end
					puts "Could not find an entry with name #{name}."
				end
			end
		end
	end
end