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
      def list_nodes(list_file,plain=false, group=nil, show=nil )
        list = YAML.load(File.read(list_file)) || {}
        if list.nil? || list.empty?
          puts "The list is empty."
        else
          if group != nil
            groups = (group or "" ).split(",")
            groups.each do |g| 
              plain ? list_group_plain(list, g) : list_group_table(list, g)
            end
          else
            plain ? list_group_plain(list, group) : list_group_table(list, group)
          end
            
        end
      end

    private
  
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
                        
                        "#{memo}\n| #{id} | #{list[id]["hostname"]} | #{list[id]["ip"] || "unknown"} |#{if list[id]["group"] == nil or list[id]["group"] == [] then "none" else list[id]["group"] end }  | #{list[id].length > 1} |"
                end
                puts TTY::Markdown.parse(all)
      end

    end
  end
end
