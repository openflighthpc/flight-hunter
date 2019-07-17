require 'socket'
server = TCPServer.open(2000)

client = server.accept
while line = client.gets
	puts line
end
client.close

