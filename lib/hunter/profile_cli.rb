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

require 'logger'
require 'flight/subprocess'
require 'fileutils'

module Hunter
  class ProfileCLI
    class << self

      private

      def flight_profile
        Config.profile_command.tap do |c|
          raise "Profile command is not defined" if !c
        end
      end
    end

    def initialize(*cmd, user: nil, stdin: nil, timeout: 30, env: {})
      @timeout = timeout
      @cmd = cmd
      @user = user
      @stdin = stdin
      @env = {
        'PATH' => Config.command_path,
      }.merge(env)
    end

    def run(&block)
      process = Flight::Subprocess::Local.new(
        env: @env,
        logger: logger,
        timeout: @timeout
      )
      result = process.run(@cmd, @stdin, &block)
      parse_result(result)
      result
    end

    private

    def parse_result(result)
      if result.exitstatus == 0 && expect_json_response?
        begin
          unless result.stdout.nil? || result.stdout.strip == ''
            result.stdout = JSON.parse(result.stdout)
          end
        rescue JSON::ParserError
          result.exitstatus = 128
        end
      end
    end

    def expect_json_response?
      @cmd.any? { |i| i.strip == '--json' }
    end

    def logger
      @logger ||= Logger.new(
        profile_log_path,
        0,
        1024 * 1024 * 1024 # restart log after ~1GB
      )
    end

    def profile_log_path
      dir = File.join(Config.root, 'var', 'log')
      FileUtils.mkdir_p(dir)
      File.join(dir, 'profile.log')
    end
  end
end
