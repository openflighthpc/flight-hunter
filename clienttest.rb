require 'macaddr'
require 'socket'

hostname = '10.13.13.103'
port = 2000

server = TCPSocket.open(hostname,port)

server.puts(Mac.addr)

server.close
