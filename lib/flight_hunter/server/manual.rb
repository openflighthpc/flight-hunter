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
				parsed = YAML.load(File.read(parsed_file))
				buffer = YAML.load(File.read(buffer_file))
				buffer.each do |mac,hname|
					puts "Enter name for MAC \"#{mac}\": "
					input = STDIN.gets.chomp
					if parsed.key?(mac) || parsed.has_value?(input)
						existing = []
						if parsed.key?(mac)			
							existing.push([mac,parsed[mac]])
						end
						if parsed.has_value?(input)
							existing.push([parsed.key(input),input])
						end
						existing.uniq!
						puts "Due to value conflicts, the following pre-existing node entries have been removed:"
						existing.each { |element| puts "#{element[0]}: #{element[1]}"}
						existing.each { |element| parsed.delete(element[0])}
					end
					parsed[mac] = input
				end
				File.open(parsed_file,'w+') {|file| file.write(parsed.to_yaml)}
				File.write(buffer_file,'---')
				puts "#{buffer_file} emptied; processed nodes written to #{parsed_file}."
			end
		end
	end
end