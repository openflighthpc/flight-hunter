require 'socket'
require 'csv'
server = TCPServer.open(2000) # start listening over port 2000

nodes = Hash.new


loop do
	puts "Waiting for client connection..."
	client = server.accept
	while line = client.gets
		mac,host = line.split(" ")
		puts "Node found. Hostname = \"#{host}\", MAC address = \"#{mac}\". Would you like to save this host as #{host} or enter a new name? ('y' to change, anything else for no): "

		if gets.chomp == "y"
			puts "Enter new name: "
			newname = gets.chomp
			nodes[newname] = mac
			puts "\nNode added\nHostname: #{newname}\nMAC address: #{mac}\n"
		else
			nodes[host] = mac
			puts "Node added\nHostname: #{host}\nMAC address: #{mac}\n"

		end
	end
	client.close
	puts "Enter 'q' to quit, enter anything else to continue listening... "
	if gets.chomp == "q"
		break
	else
		next
	end
end

CSV.open("nodelist.csv", "wb") {|csv| nodes.to_a.each {|elem| csv << elem} }