require 'macaddr'
require 'socket'
require 'yaml'

def read_config
	config = YAML.load_file('config.yaml')
	@ipaddr = config['ipaddr']
	@port = config['port']
end

read_config
mac = Mac.addr
myhostname = Socket.gethostname

server = TCPSocket.open(@ipaddr, @port)

server.puts(mac + ' ' + myhostname)
server.close