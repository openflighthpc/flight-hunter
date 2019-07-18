require 'socket'
require 'csv'
@config = []
File.open('config.txt').each_line do |line|
	line.chomp!
	next if line.empty? || line =~ /#{'#'}/		# Load config.txt into script
	@config.push(line)
end
csvname = @config[0]

if not File.file?(csvname)
	puts "Specified CSV file doesn't exist. Creating..."
	CSV.open(csvname, 'w')
	puts "Created CSV file named #{csvname}."
end

@nodes = CSV.read(csvname) # Load array to store host:MAC pairs in

trap "SIGINT" do
	puts "\nExiting abruptly..."
	CSV.open(csvname, 'w+') { |csv| @nodes.each { |elem| csv << elem } }
	puts "Node list written to \'#{csvname}\'."
	exit 130
end

server = TCPServer.open(2000) # start listening over port 2000

def check_for_duplicate(host,mac)
	for row in @nodes
		if [host,mac] == row
			return "both"
		elsif host == row[0]
			return ["host",row[1]]
		elsif mac == row[1]
			return ["mac",row[0]]
		else
			false
		end
	end
end

def dupe_handler(host,mac)
	dupe_check = check_for_duplicate(host,mac)
	if dupe_check == "both"
		puts "This exact host/MAC pair already exists in the CSV."
	elsif dupe_check == false
	elsif dupe_check[0] == "host"
		puts "A node already exists with the name \"#{host}\" under address \"#{dupe_check[1]}\". Please choose something else."
		
	elsif dupe_check[0] == "mac"
		puts "A node already exists with the address \"#{mac}\". It is named \"#{dupe_check[1]}\"."
		
	end	
	puts "Node added\nHostname: #{host}\nMAC address: #{mac}\n"
	@nodes.push([host, mac])
end

loop do # Can receive multiple consecutive clients
	puts 'Waiting for client connection...'
	client = server.accept
	while (line = client.gets)
		mac, host = line.split(' ') # Split line into array containing MAC and hostname, using whitespace delimiter
		puts "Node found. Hostname = \"#{host}\", MAC address = \"#{mac}\". Would you like to save this host as #{host} or enter a new name? ('y' to change, anything else for no): "
		if gets.chomp == 'y'
			puts 'Enter new name: '
			host = gets.chomp
			while host == ""
				puts "You must enter a text value for the name. Try again: "
				host = gets.chomp
			end
			dupe_handler(host, mac)
		else
			dupe_handler(host, mac)

		end
	end
	client.close
	puts 'Enter \'q\' to quit, enter anything else to continue listening... '
	if gets.chomp == 'q'
		break
	else
		next
	end
end
	
CSV.open(csvname, 'w+') { |csv| @nodes.each { |elem| csv << elem } }
puts "Node list written to \'#{csvname}\'."
