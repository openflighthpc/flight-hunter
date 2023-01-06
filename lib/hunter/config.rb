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

      def target_host
        ENV['flight_HUNTER_target_host'] || data.fetch(:target_host)
      end

      def payload_file
        ENV['flight_HUNTER_payload_file'] || data.fetch(:payload_file)
      end

      def allow_existing
        ENV['flight_HUNTER_allow_existing'] || data.fetch(:allow_existing)
      end
      
      def auth_key
        ENV['flight_HUNTER_auth_key'] || data.fetch(:auth_key)
      end

      def node_buffer
        var_file('buffer.yaml')
      end

      def node_list
        var_file('parsed.yaml')
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

      def var_file(*a)
        parent_dir = File.join(root, 'var', *a[0..-2])
        FileUtils.mkdir_p(parent_dir)
        file = File.join(root, 'var', *a)
        FileUtils.touch(file).first
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
