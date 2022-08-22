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

module FlightHunter
  module Server
    class ModifyGroup
      def modify_group(list_file, name, mods)
      	list = YAML.load(File.read(list_file))
        to_change = ""
        list.each do |id,vals|
          if name == vals["hostname"] 
            to_change = id
          end
        end
        changes = (mods or "").split(",")	
				
				oldgroup = list[to_change]["group"]
				message = "Changes made: "
				
				unless (changes or []).empty?
					changes.each do |change|
						unless change.empty? and change.length < 2
							if change[0] == "+"
								if list[to_change]["group"] == nil
									list[to_change]["group"] = Array.new(1,change[1..-1])
									message += "ADDED \'#{change[1..-1]}\', "
								else
									unless list[to_change]["group"].include?(change[1..-1])
										list[to_change]["group"].push(change[1..-1])
										message += "ADDED \'#{change[1..-1]}\', "
									end
								end
							elsif change[0] == "-"
								(list[to_change]["group"] or [] ).delete(change[1..-1])
								message += "REMOVED \'#{change[1..-1]}\', "
							else
								message += "INVALID CHANGE \'#{change}\', "
							end 
						end
					end
				end
				
				File.write(list_file,list.to_yaml)
				puts message
			end
    end
  end
end
