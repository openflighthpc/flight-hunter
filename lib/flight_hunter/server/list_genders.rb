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
		class ListGenders
			def list_genders(list_file)
				list = YAML.load(File.read(list_file)) || {}
				if list.nil? || list.empty?
					puts "The list is empty."
				else
					print_genders(sort_groups(list))
				end
			end

		private
			# sorts our normal list by groups into a hash
			def sort_groups(list)
				groups = Hash.new
				list.each do |id,vals|
					unless list[id]["group"] == nil
						list[id]["group"].each do |group|
							if groups.key?(group)# if already there, add node name
								groups[group].push(list[id]["hostname"])
							else # add group as key and node name to that
								groups[group] = Array.new(1, list[id]["hostname"])
							end
						end
					end 	
				end
				return groups
			end

			def print_genders(groups)
				#p groups
				printout = ""
				groups.each do |group,nodes|
					message = ""
					nodes.each do |node|
						message = message + node + "," # display as comma separated
					end
					message.chomp!(",") #remove spare final comma
					printout = printout + message + " " + group + "\n"		#add to overall print
				end
        if printout == "" then puts "No genders to be listed." end
				print printout
			end
			
	
			def list_plain(list)
				list.each do |id,vals|
					puts "#{id},#{list[id]["hostname"]},#{list[id]["ip"] || "unknown"},#{ list[id]["group"] || "none"} ,#{list[id].length > 1}"
				end
			end
	
			def list_table(list)
				table = <<~TABLE.chomp
					| ID       | Name    | Last Known IP | Groups |  Has payload? |
					|----------|---------|---------------|--------|--------------|
				TABLE

				all = list.reduce(table) do |memo, (id,vals)|
					"#{memo}\n| #{id} | #{list[id]["hostname"]} | #{list[id]["ip"] || "unknown"} |#{list[id]["group"] || "none" }  | #{list[id].length > 1} |"
				end
				puts TTY::Markdown.parse(all)
			end

			 def list_group_plain(list, group_name)
                                list.each do |id,vals|
					if group_name == nil
						puts "#{id},#{list[id]["hostname"]},#{list[id]["ip"] || "unknown"},#{ list[id]["group"] || "none"} ,#{list[id].length > 1}"
					else
						if list[id]["group"] == nil
							if group_name == "nil"
								 puts "#{id},#{list[id]["hostname"]},#{list[id]["ip"] || "unknown"},#{ list[id]["group"] || "none"} ,#{list[id].length > 1}"
							end
						elsif list[id]["group"].include?(group_name)
							puts "#{id},#{list[id]["hostname"]},#{list[id]["ip"] || "unknown"},#{ list[id]["group"] || "none"} ,#{list[id].length > 1}"
						end
					end
                                end

                        end

                        def list_group_table(list, group_name)
                                table = <<~TABLE.chomp
                                        | ID       | Name    | Last Known IP | Group |  Has payload? |
                                        |----------|---------|---------------|-------|--------------|
                                TABLE

                                list.each do |id, vals|
					if group_name == nil
						break
					else
						if list[id]["group"] == nil
							unless group_name == "nil"
								list.delete(id)
							end
						else 
							unless list[id]["group"].include?(group_name)
								list.delete(id)
							end
						end
					end
                                end
                                all = list.reduce(table) do |memo, (id,vals)|
                                        "#{memo}\n| #{id} | #{list[id]["hostname"]} | #{list[id]["ip"] || "unknown"} |#{list[id]["group"] || "none" }  | #{list[id].length > 1} |"
                                end
                                puts TTY::Markdown.parse(all)
                        end
		end
	end
end
