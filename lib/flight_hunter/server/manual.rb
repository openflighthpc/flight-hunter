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
		class ManualParse
			def manual(buffer_file,parsed_file)
				parsed = YAML.load(File.read(parsed_file)) || {}
				buffer = YAML.load(File.read(buffer_file)) || {}
				existing = []
				hostsearch = SearchHostname.new
				buffer.each do |mac,vals|
					puts "Enter name for MAC \"#{mac}\": "
					input = STDIN.gets.chomp
					if parsed.key?(mac) || hostsearch.search(parsed,input)						
						if parsed.key?(mac)			
							existing.push([mac,parsed[mac]])
						end
						if hostsearch.search(parsed,input)
							parsed.each do |key,value|
								if value["hostname"] == input
									existing.push([key,input])
								end
							end
						end
						existing.uniq!
						puts "Due to value conflicts, the following pre-existing node entries have been removed:"
						existing.each { |element| puts "#{element[0]}: #{element[1]}"}
						existing.each { |element| parsed.delete(element[0])}
					end
					parsed[mac] = {"hostname" => input, "ip" => vals["ip"], "payload" => vals["payload"]}.compact
				end
				File.open(parsed_file,'w+') {|file| file.write(parsed.to_yaml)}
				File.write(buffer_file,'---')
				puts "#{buffer_file} emptied; processed nodes written to #{parsed_file}."
			end
		end
	end
end
