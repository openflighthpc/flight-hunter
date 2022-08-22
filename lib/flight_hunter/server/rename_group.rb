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
    class RenameGroup
      def rename_group(list_file, old_name, new_name)
      	list = YAML.load(File.read(list_file))
				counter = 0
				list.each do |id,vals|
					if i = (list[id]["group"] or [] ).index(old_name)
						if (list[id]["group"] or []).include?(new_name)
							list[id]["group"][i] = nil
							list[id]["group"].compact!
						else
							list[id]["group"][i] = new_name
						end
						counter+=1
					end
				end


				File.write(list_file,list.to_yaml)
				puts "Group \'#{old_name}\' renamed to \'#{new_name}\' for #{counter} nodes" 
			end
    end
  end
end
