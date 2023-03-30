require 'open3'
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
