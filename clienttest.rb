require 'macaddr'
require 'socket'
@config = []
File.open('config.txt').each_line do |line|
	line.chomp!
	next if line.empty? || line =~ /#{'#'}/
	@config.push(line)
end

hostname = @config[0]
port = 2000
mac = Mac.addr
myhostname = Socket.gethostname

server = TCPSocket.open(hostname, port)

server.puts(mac + ' ' + myhostname)
server.close
