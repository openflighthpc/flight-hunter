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

require 'macaddr'
require 'socket'

module FlightHunter
	module Client
		class Send
			def send_mac(ipaddr,port,filename=nil)
				mac = Mac.addr
				myhostname = Socket.gethostname
				if filename != nil
					fileContent = File.read(filename)
				end
				payload = [mac,myhostname,fileContent].pack('Z*Z*Z*')
				begin
					server = TCPSocket.open(ipaddr,port)
					server.write(payload)
					server.close
					puts "Successful transmission."
				rescue Errno::ECONNREFUSED => e
					puts "The server is down."
					puts e.message
				end
			end
		end
	end
end