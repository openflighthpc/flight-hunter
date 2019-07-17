require 'macaddr'
require 'socket'

hostname = '10.13.13.103'
port = 2000
mac = Mac.addr
myhostname = Socket.gethostname

server = TCPSocket.open(hostname, port)

server.puts(mac + ' ' + myhostname)
server.close
