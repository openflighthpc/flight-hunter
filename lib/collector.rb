#!/usr/bin/env ruby
#==============================================================================
## Copyright (C) 2019-present Alces Flight Ltd.
##
## This file is part of Hunter.
##
## This program and the accompanying materials are made available under
## the terms of the Eclipse Public License 2.0 which is available at
## <https://www.eclipse.org/legal/epl-2.0>, or alternative license
## terms made available by Alces Flight Ltd - please direct inquiries
## about licensing to licensing@alces-flight.com.
##
## Hunter is distributed in the hope that it will be useful, but
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, EITHER EXPRESS OR
## IMPLIED INCLUDING, WITHOUT LIMITATION, ANY WARRANTIES OR CONDITIONS
## OF TITLE, NON-INFRINGEMENT, MERCHANTABILITY OR FITNESS FOR A
## PARTICULAR PURPOSE. See the Eclipse Public License 2.0 for more
## details.
##
## You should have received a copy of the Eclipse Public License 2.0
## along with Hunter. If not, see:
##
##  https://opensource.org/licenses/EPL-2.0
##
## For more information on Hunter, please visit:
## https://github.com/openflighthpc/hunter
##===============================================================================
#

module BasicCollector
  def self::collect
    payload={}

    #pickup possible things we like from the kernel cmdline
    cmdline = ::File::read('/proc/cmdline').split.map { |a| h=a.split('='); [h.first,h.last] if h.size == 2}.compact.to_h

    payload[:sysuuid] = cmdline['SYSUUID']
    payload[:bootif] = cmdline['BOOTIF']

    #quick go at network interfaces
    nets={}
    begin
      ::Dir::entries('/sys/class/net').reject! {|x| x =~ /\.|\.\.|lo/i }.sort.each { |net|
        nets[net] = ::File::read("/sys/class/net/#{net}/address").chomp rescue "unknown"
      }
    rescue
  
    end

    payload[:nets]=nets.compact

    #and at disks
    disks={}
    begin
      ::Dir::entries('/sys/class/block').reject! {|x| x =~ /\.|\.\./i }.sort.each { |disk|
        if ::Dir::exist? "/sys/class/block/#{disk}/device"
          disks[disk]=::File::read("/sys/class/block/#{disk}/size").chomp rescue nil
        end
    }
    rescue

    end

    payload[:disks]=disks.compact

    #finally best we can do somewhat dodgy attempt to pick up BMC info
    addr=`ipmitool lan print 1 | grep -e "IP Address" | grep -vi "Source"| awk '{ print $4 }'`.chomp rescue nil
    payload[:bmcip]= addr unless addr.to_s.empty? 
    mac=`ipmitool lan print 1 | grep 'MAC Address' | awk '{ print $4 }'`.chomp rescue nil
    payload[:bmcmac]= mac unless mac.to_s.empty?

    payload.compact
  end
end

