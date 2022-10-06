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
  class Node
    def to_h
      {
        'id' => id,
        'hostname' => hostname,
        'ip' => ip,
        'payload' => payload,
        'groups' => groups
      }
    end

    def add_groups(new_groups)
      groups.concat(new_groups).uniq!
    end

    def remove_groups(to_remove)
      self.groups = groups - to_remove
    end

    attr_reader :id, :ip, :payload, :groups
    attr_accessor :hostname

    def initialize(id:, hostname:, ip:, payload:, groups:)
      @id = id
      @hostname = hostname
      @ip = ip
      @payload = payload
      @groups = groups || []
    end

    private

    attr_writer :groups
  end
end
