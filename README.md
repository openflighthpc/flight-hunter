# Hunter

A tool for tracking MAC addresses of nodes in a cluster.

## Overview

Hunter facilitates a communication between a two machines,
allowing one machine running the client script to send it's hostname
and MAC address to another machine running the server script.

## Installation

For installation instructions see INSTALL.md

## Configuration

The utility has multiple commands for both client and server for configuration.

### Client

`ruby hunter.rb client modify ip $IP`

This command allows the user to modify the IP address specified in the client side `config.yaml` file. Simply replace `$IP` with the desired IP address.

`ruby hunter.rb client modify port $PORT`

Similarly, this command does the same but with the port specified in `config.yaml`.


### Server

The server side script provides similar commands to modify its `config.yaml` file from the command line:

`ruby hunter.rb server modify not_processed $FILE` - change filename of file to store unparsed nodes in.

`ruby hunter.rb server modify nodelist $FILE` - changed filename of file to store parsed nodes in.

`ruby hunter.rb server modify port $PORT` - change port to listen over for node communication.



## Operation

To be completed... 

Hunter operates on a tree-like structure of arguments. They are executed with the following format: 

`ruby hunter.rb [argument1, argument2, ... , argumentN]`

Branches and leaves will be displayed as subheadings below.

### client
The initial argument of `client` filters into the commands available to the client-side script part of Hunter.

#### send

The second argument `send` tells the `client` script to connect to a `server` script, using the IP and port specified in the client's `config.yaml` file as the target. If the target exists, a connection will be attempted. If the server refuses the connection, an error will be thrown.

#### modify
The second argument `modify` allows the user to change an element of the `config.yaml` file from the command line, rather than editing the file manually.

##### ip
The third argument `ip` modifies the target server IP to whatever is written after the `ip` argument. For example:
`ruby hunter.rb client modify ip 192.168.0.1`

##### port
The third argument `port` modifies the port to communicate over. For example:

`ruby hunter.rb client modify ip 192.168.0.1`

### server
The initial argument `server` filters into the commands available to the server-side script part of Hunter.

#### hunt
The second argument `hunt` will open a continuous TCP connection over the port specified in the server-side `config.yaml`, listening for broadcasts from client nodes on the network. When a node is accommodated, it's MAC address and hostname are saved into a `.yaml` file containing all unprocessed nodes in {MAC: Hostname} key,value pairs. The file is specified in the server-side `config.yaml`. The command takes a single switch argument, which, when `true`, does not accept MAC addresses that already exist in either the unprocessed or processed list.

#### list
The second argument `list` will print out a 2-column table of all nodes in one of the two lists, specified by a third argument (`unprocessed` or `nodelist`).

#### parse
The second argument `parse` allows the user to process all nodes in the unprocessed list, appending them to the processed list.

##### manual
The third argument `manual` will step-through the unprocessed list one-by-one, each time prompting the user for a name.

##### automatic
The third argument `automatic` provides a way to speedily process the unprocessed nodes. It takes three subsequent arguments: `prefix`, `length`, and `start`. The `prefix` argument defines a string of characters that the all nodes' names will begin with. The `length` argument defines how long the integer suffix will be, and the `start` argument defines where the integer suffix will start counting from. For example: the command `ruby hunter.rb server parse automatic node 3 001` on a list of three arbitrary nodes will produce the nodelist:

```
7E-8F-89-4F-47-9F: node001
0E-CC-B1-F2-23-DD: node002
59-D2-AE-26-D6-BA: node003
```

#### remove
The second argument `remove` provides a way to remove a node from the processed node list. It takes either a MAC address or a name as a primary key.

##### mac
Parsing `mac` to the `remove` command indicates that the proceeding value will be the MAC address of the node you wish to remove from the nodelist.

##### name
Similarly, parsing `name` indicates that the proceeding value will be the name of the node you wish to remove from the nodelist.

#### modify

Similar to the `client modify` command, the server-side `modify` argument provides a way to modify the server's `config.yaml` file. However, it also holds bonus arguments for modifying pre-existing nodes in either the unprocessed or processed nodelist.

##### not_processed
The third argument `not_processed` modifies the path to the `.yaml` file that stores unprocessed nodes, relative to the `server` root directory.

##### nodelist
The argument `nodelist` modifies the path to the `.yaml` file that stores processed nodes, relative to the `server` root directory.

##### port
The `port` argument modifies the port to listen for communications over.

##### mac
The `mac` argument allows for the saved name of a node to be modified, using the associated MAC address as the primary key. The list to edit must also be specified. For example:

`ruby hunter.rb server modify mac not_processed 7E-8F-89-4F-47-9F newname1`

will change the name of `7E-8F-89-4F-47-9F` to `newname1`, provided it exists in the `not_processed` file.

##### name
The `name` argument does the inverse of the `mac` argument, using the node's name as a primary key to modify the saved MAC address. For example:

`ruby hunter.rb server modify name not_processed node001 7E-8F-89-4F-47-9F`

will changed the MAC address of the node named `node001` to `7E-8F-89-4F-47-9F`, provided it exists in the not_processed file.

# Contributing

Fork the project. Make your feature addition or bug fix. Send a pull
request. Bonus points for topic branches.

Read [CONTRIBUTING.md](CONTRIBUTING.md) for more details.

# Copyright and License

Creative Commons Attribution-ShareAlike 4.0 License, see [LICENSE.txt](LICENSE.txt) for details.

Copyright (C) 2019-present Alces Flight Ltd.

You should have received a copy of the license along with this work.
If not, see <http://creativecommons.org/licenses/by-sa/4.0/>.

![Creative Commons License](https://i.creativecommons.org/l/by-sa/4.0/88x31.png)

Hunter is licensed under a [Creative Commons Attribution-ShareAlike 4.0 International License](http://creativecommons.org/licenses/by-sa/4.0/).

Based on a work at [https://github.com/openflighthpc/hunter](https://github.com/openflighthpc/hunter).

This content and the accompanying materials are made available available
under the terms of the Creative Commons Attribution-ShareAlike 4.0
International License which is available at [https://creativecommons.org/licenses/by-sa/4.0/](https://creativecommons.org/licenses/by-sa/4.0/),
or alternative license terms made available by Alces Flight Ltd -
please direct inquiries about licensing to
[licensing@alces-flight.com](mailto:licensing@alces-flight.com).

Hunter is distributed in the hope that it will be useful, but
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, EITHER EXPRESS OR
IMPLIED INCLUDING, WITHOUT LIMITATION, ANY WARRANTIES OR CONDITIONS OF
TITLE, NON-INFRINGEMENT, MERCHANTABILITY OR FITNESS FOR A PARTICULAR
PURPOSE. See the [Creative Commons Attribution-ShareAlike 4.0
International License](https://creativecommons.org/licenses/by-sa/4.0/) for more
details.


