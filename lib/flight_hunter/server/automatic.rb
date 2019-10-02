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
		class AutomaticParse
			def automatic(buffer_file,parsed_file,prefix,length,start)	
				parsed = YAML.load(File.read(parsed_file)) || {}
				buffer = YAML.load(File.read(buffer_file)) || {}				
				hostsearch = SearchHostname.new
				length = length.to_i
				existing = []
				to_add = {}
				start_val = start.dup
				buffer.each do |mac,vals|
					if start_val.length < length
						start_val.prepend("0"* (length-start_val.length))
					elsif start_val.length > length
						start_val.slice!(0,start_val.length-length)
					end

					newname = prefix+start_val
					if parsed.key?(mac) || hostsearch.search(parsed,newname)			
						if parsed.key?(mac)			
							existing.push([mac,parsed[mac]])
						end
						if hostsearch.search(parsed,newname)
							parsed.each do |key,value|
								if value["hostname"] == newname
									existing.push([key,newname])
								end
							end
						end
						existing.uniq!
						existing.each { |element| parsed.delete(element[0])}	
					end
					to_add[mac] = {"hostname" => newname, "ip" => vals["ip"], "payload" => vals["payload"]}.compact
					start_val.succ!
				end
				if !existing.empty?
					puts "Due to value conflicts, the following pre-existing node entries have been removed:"
					existing.each { |element| puts "#{element[0]}: #{element[1]}"}
					existing.each { |element| parsed.delete(element[0])}
				end
				to_add.each {|node| parsed[node[0]] = node[1]}
				File.write(parsed_file,parsed.to_yaml)
				File.write(buffer_file,'---')
				puts "#{buffer_file} emptied; processed nodes written to #{parsed_file}."
			end
		end
	end
end
