#==============================================================================
# Copyright (C) 2022-present Alces Flight Ltd.
#
# This file is part of Flight Hunter.
#
# This program and the accompanying materials are made available under
# the terms of the Eclipse Public License 2.0 which is available at
# <https://www.eclipse.org/legal/epl-2.0>, or alternative license
# terms made available by Alces Flight Ltd - please direct inquiries
# about licensing to licensing@alces-flight.com.
#
# Flight Hunter is distributed in the hope that it will be useful, but
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, EITHER EXPRESS OR
# IMPLIED INCLUDING, WITHOUT LIMITATION, ANY WARRANTIES OR CONDITIONS
# OF TITLE, NON-INFRINGEMENT, MERCHANTABILITY OR FITNESS FOR A
# PARTICULAR PURPOSE. See the Eclipse Public License 2.0 for more
# details.
#
# You should have received a copy of the Eclipse Public License 2.0
# along with Flight Hunter. If not, see:
#
#  https://opensource.org/licenses/EPL-2.0
#
# For more information on Flight Hunter, please visit:
# https://github.com/openflighthpc/flight-hunter
#==============================================================================
require_relative 'profile_cli'

module Hunter
  class Node
    def to_h
      {
        'id' => id,
        'hostname' => hostname,
        'label' => label,
        'ip' => ip,
        'content' => content,
        'groups' => groups,
        'presets' => presets
      }
    end

    def add_groups(new_groups)
      @groups.concat(new_groups).uniq!
    end

    def remove_groups(to_remove)
      @groups = @groups - to_remove
    end

    def pretty_presets
      presets.map { |k,v| "#{k}: '#{v}'" }.join("\n")
    end

    def pretty_groups
      groups.join(", ")
    end

    def to_table_row(buffer: false)
      case buffer
      when true
        [Paint[id, :cyan], hostname, ip, pretty_groups, pretty_presets]
      when false
        [Paint[id, :cyan], hostname, ip, pretty_groups, label]
      end
    end

    def groups
      @groups.sort
    end

    def filepath
      File.join(node_list.dir, "#{id}.yaml") if node_list
    end

    def save
      File.open(filepath, 'w+') { |f| f.write(YAML.dump(to_h)) }
      apply_identity(Config.auto_apply) if @auto_apply
    end

    def delete_source
      File.delete(filepath)
    end

    def preset_label
      @label || @presets["label"]
    end

    def auto_label(used_names: NodeList.load(Config.node_list).nodes.map(&:label), default_prefix: nil, default_start: nil, default_hostnames: "long")
      prefix = @presets["prefix"] || default_prefix
      hostname = case default_hostnames
                 when "long"
                   @hostname
                 when "short"
                   @hostname.split(".").first
                 when "blank"
                   ""
                 end
      return hostname unless prefix

      start = Config.prefix_starts[prefix] || default_start || Config.default_start
      i = start.to_i
      padding = '0' * [(start.length - i.to_s.length), 0].max
      name = prefix + padding + i.to_s
      while used_names.include?(name) do
        i += 1
        padding = '0' * [(start.length - i.to_s.length), 0].max
        name = prefix + padding + i.to_s
      end
      name
    end

    attr_reader :id, :ip, :content, :hostname, :presets
    attr_accessor :label, :node_list, :auto_apply

    def initialize(id:, hostname:, label: nil, ip:, content:, groups: [], presets: {}, node_list: nil, auto_apply: false)
      @id = id
      @hostname = hostname
      @label = label
      @ip = ip
      @content = content
      @groups = groups || []
      presets = presets.map { |k,v| { k => v.to_s } }.reduce({}, :merge)
      @presets = presets.reject { |k,v| v.empty? }
      @node_list = node_list
      @auto_apply = auto_apply
    end

    private

    def apply_identity(rules)
      identity = rules&.find { |rule, _| label.match(Regexp.new(rule)) }

      return unless identity

      puts <<~OUT.chomp
      Node #{label} matches auto-apply rule '#{identity[0]}: #{identity[1]}'
      OUT

      ProfileCLI.apply(label, identity[1])
    end
  end
end
