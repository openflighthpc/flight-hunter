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

module Hunter
  class NodeList

    class << self
      def load(filepath)
        filename = filepath.split("/").compact.last
        raise "Node list #{filename} doesn't exist" if !File.file?(filepath)
        new(filepath)
      end
    end

    def include_id?(id)
      nodes.any? { |n| n.id == id }
    end

    def include_label?(label)
      nodes.any? { |n| n.label == label }
    end

    def find(**kwargs)
      nodes.find do |n|
        kwargs.compact.all? do |k, v|
          next unless [:id, :label].include?(k)
          n.send(k) == v if n.respond_to?(k)
        end
      end
    end

    def delete(nodes)
      @nodes = @nodes - nodes
    end

    def match(regex)
      nodes.select { |n| regex.match(n.hostname) }
    end

    def to_yaml
      YAML.dump(nodes.map(&:to_h))
    end

    def empty
      @nodes = []
      save
    end

    def nodes(by_group: false)
      @nodes.tap do |a|
        if by_group
          groups = a.map(&:groups).flatten.uniq.sort.reduce({}) do |h, i|
            h.merge(Hash[i, Array.new])
          end
          a.each do |node|
            node.groups.each { |g| groups[g] << node }
          end
          return groups
        end
        a.sort_by { |n| n.id }
      end
    end


    def name
      filepath.split("/").last.split(".").first
    end

    def save
      File.open(filepath, 'w+') { |f| f.write(to_yaml) }
    end

    attr_reader :filepath
    attr_writer :nodes

    private

    def initialize(filepath)
      @filepath = filepath
      @nodes = [].tap do |l|
        list = YAML.load_file(filepath) || {}
        list.each do |node|
          l << Node.new(
            id: node['id'],
            hostname: node['hostname'],
            label: node['label'],
            ip: node['ip'],
            payload: node['payload'],
            groups: node['groups'],
            presets: node['presets']
          )
        end
      end
    end
  end
end
