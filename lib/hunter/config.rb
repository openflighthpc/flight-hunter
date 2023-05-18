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
require 'xdg'
require 'tty-config'
require 'fileutils'
require 'yaml'

module Hunter
  module Config
    class << self
      HUNTER_DIR_SUFFIX = File.join('flight','hunter')

      def data
        @data ||= TTY::Config.new.tap do |cfg|
          cfg.append_path(File.join(root, 'etc'))
          begin
            cfg.read
          rescue TTY::Config::ReadError
            nil
          end
        end
      end

      def port
        ENV['flight_HUNTER_port'] || data.fetch(:port)
      end

      def include_self
        ENV['flight_HUNTER_include_self'] || data.fetch(:include_self)
      end

      def autorun_mode
        ENV['flight_HUNTER_autorun_mode'] || data.fetch(:autorun_mode)
      end

      def broadcast_address
        ENV['flight_HUNTER_broadcast_address'] || data.fetch(:broadcast_address)
      end

      def target_host
        ENV['flight_HUNTER_target_host'] || data.fetch(:target_host)
      end

      def content_command
        ENV['flight_HUNTER_content_command'] || data.fetch(:content_command)
      end

      def allow_existing
        ENV['flight_HUNTER_allow_existing'] || data.fetch(:allow_existing)
      end
      
      def auth_key
        ENV['flight_HUNTER_auth_key'] || data.fetch(:auth_key)
      end

      def auto_parse
        ENV['flight_HUNTER_auto_parse'] || data.fetch(:auto_parse)
      end

      def short_hostname
        ENV['flight_HUNTER_short_hostname'] || data.fetch(:short_hostname)
      end

      def default_start
        ENV['flight_HUNTER_default_start'] || data.fetch(:default_start) || "01"
      end

      def prefix_starts
        ENV['flight_HUNTER_prefix_starts'] || data.fetch(:prefix_starts)
      end

      def auto_apply
        (ENV['flight_HUNTER_auto_apply'] || data.fetch(:auto_apply)).tap do |h|
          return if h.nil?

          raise "Malformed hash passed to `auto_apply`" unless h.is_a?(Hash)
          bad_exps = h.select { |k,v| !valid_regex?(k) }.keys
          out = <<~OUT.chomp
          The following regular expressions passed to `auto_apply` are invalid:
          #{bad_exps.join("\n")}
          OUT

          raise out if bad_exps.any?
        end
      end

      def presets
        data.fetch(:presets) || {}
      end

      def profile_command
        command =
          ENV['flight_HUNTER_profile_command'] ||
            data.fetch(:profile_command) ||
            File.join(ENV.fetch('flight_ROOT', '/opt/flight'), 'bin/flight profile')
        if !File.file?(File.join(command.split[0]))
          raise "Could not find '#{command.split[0]}'"
        elsif !File.executable?(File.join(command.split[0]))
          raise "#{command.split[0]} is not executable"
        end
        command.split(' ')
      end

      def command_path
        ENV['PATH']
      end

      def node_buffer
        var_dir('buffer')
      end

      def node_list
        var_dir('parsed')
      end

      def save_data
        FileUtils.mkdir_p(File.join(root, 'etc'))
        data.write(force: true)
      end

      def data_writable?
        File.writable?(File.join(root, 'etc'))
      end

      def user_data
        @user_data ||= TTY::Config.new.tap do |cfg|
          xdg_config.all.map do |p|
            File.join(p, _DIR_SUFFIX)
          end.each(&cfg.method(:append_path))
          begin
            cfg.read
          rescue TTY::Config::ReadError
            nil
          end
        end
      end

      def save_user_data
        FileUtils.mkdir_p(
          File.join(
            xdg_config.home,
            HUNTER_DIR_SUFFIX
          )
        )
        user_data.write(force: true)
      end

      def path
        config_path_provider.path ||
          config_path_provider.paths.first
      end

      def root
        @root ||= File.expand_path(File.join(__dir__, '..', '..'))
      end

      private

      def valid_regex?(regex)
        Regexp.new(regex)
      rescue RegexpError => e
        false
      end

      def var_file(*a)
        parent_dir = File.join(root, 'var', *a[0..-2])
        FileUtils.mkdir_p(parent_dir)
        file = File.join(root, 'var', *a)
        FileUtils.touch(file).first
      end

      def var_dir(*a)
        dir = File.join(root, 'var', *a)
        FileUtils.mkdir_p(dir)
        dir
      end

      def xdg_config
        @xdg_config ||= XDG::Config.new
      end

      def xdg_data
        @xdg_data ||= XDG::Data.new
      end

      def xdg_cache
        @xdg_cache ||= XDG::Cache.new
      end
    end
  end
end
