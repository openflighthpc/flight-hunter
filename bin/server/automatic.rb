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

def automatic(config,prefix,length,start)	
	nodelist = YAML.load(read_yaml('server/' + config['nodelist'])) || {}
	not_processed_list = YAML.load(read_yaml('server/' + config['not_processed_list'])) || {}
	length = length.to_i
	existing = []
	to_add = {}
	not_processed_list.each do |mac,hname|
		start_val = start.dup
		if start_val.length < length
			start_val.prepend("0"* (length-start_val.length))
		elsif start_val.length > length
			start_val.slice!(0,start_val.length-length)
		end

		newname = prefix+start_val
		if nodelist.key?(mac) || nodelist.has_value?(newname)
			
			if nodelist.key?(mac)			
				existing.push([mac,nodelist[mac]])
			end
			if nodelist.has_value(hname)
				existing.push([nodelist.key(newname),newname])
			end
			existing.uniq!
			existing.each { |element| nodelist.delete(element[0])}
	
		end
		to_add[mac] = newname
		start_val.succ
	end
	if !existing.empty?
		puts "Due to value conflicts, the following pre-existing node entries have been removed:"
		existing.each { |element| puts "#{element[0]}: #{element[1]}"}
	end
	to_add.each {|node| nodelist[node[0]] = node[1]}
	File.open('server/' + config['nodelist'],'w+') {|file| file.write(nodelist.to_yaml)}
	File.open('server/' + config['not_processed_list'],'w+')
	puts "#{config['not_processed_list']} emptied; processed nodes written to #{config['nodelist']}."
end