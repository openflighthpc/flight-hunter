require 'socket'
require 'yaml'

module Hunter
  module Collector
    def self.collect
      payload = {}

      cmdline = File.read('/proc/cmdline').split.map do |a|
        a.split('=')
      end.select { |a| a.length == 2 }.to_h

      payload[:sysuuid] = cmdline['SYSUUID']
      payload[:bootif] = cmdline['BOOTIF']

      nets = {}
      begin
        regex = /\.|\.\.|lo/i
        files = Dir.entries('/sys/class/net').reject { |e| e =~ regex }.sort
        files.each do |net|
          nets[net] = begin
                        File.read("/sys/class/net/#{net}/address").chomp
                      rescue
                        "unknown"
                      end
        end
      rescue

      end

      payload[:nets] = nets.compact

      disks = {}
      begin
        regex = /\.|\.\./i
        files = Dir.entries('/sys/class/block').reject! { |e| e =~ regex }.sort
        files.each do |disk|
          if Dir.exist? "/sys/class/block/#{disk}/device"
            disks[disk] = begin
                            File.read("/sys/class/block/#{size}/size").chomp
                          rescue
                            nil
                          end
          end
        end
      rescue

      end

      payload[:disks] = disks.compact

      addr = `ipmitool lan print 1 2> /dev/null \
              | grep -e "IP Address" \
              | grep -vi "Source" \
              | awk '{ print $4 }'`.chomp rescue nil
      payload[:bmcip] = addr unless addr.to_s.empty?
      mac = `ipmitool lan print 1 2> /dev/null \
             | grep 'MAC Address' \
             | awk '{ print $4 }'`.chomp rescue nil
      payload[:bmcmac] = mac unless mac.to_s.empty?

      payload.compact
    end
  end
end
