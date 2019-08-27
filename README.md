# Hunter

A tool for tracking MAC addresses of nodes in a cluster.

## Overview

Hunter facilitates a communication between a two machines,
allowing one machine running the client script to send it's hostname
and MAC address to another machine running the server script.

## Installation

For installation instructions see INSTALL.md

## Configuration

Both the client and server utilities are built as an all-in-one package with Flight Hunter. The only configuration that needs to be done is setting the IP and port on the client and server machines. If using the pre-installed image, this can be done by changing the `hunter_ip` environment variable in your PXE config file. 

## Operation

The commands' syntax is as follows:
```
dump-buffer
help
hunt [allow-existing]
list-buffer
list-parsed
modify-client-port PORT
modify-ip IP
modify-mac CURRENT_MAC NEW_MAC
modify-name CURRENT_NAME NEW_NAME
modify-server-port PORT
parse-automatic PREFIX LENGTH START_INT
parse-manual
remove-mac MAC
remove-name NAME
send [--file FILE_PATH]
show-node NODE_NAME
```

The `hunt` command starts the server script and begins listening for clients executing the send script. When a client is found, it will be saved to the buffer list file stored at `var/flight-hunter/server/buffer.yaml`. The buffer can then be processed with either `parse-manual` or `parse-automatic`. The optional argument `[allow-existing]` lets the `hunt` script accept new clients with names that already exist in either the buffer or parsed nodelists.

The `send` command tells the `client` script to connect to a currently running `server` script, using the IP and port specified in the client's `config.yaml` file as the target. If the target exists, a connection will be attempted. If the server refuses the connection, an error will be thrown. The optional argument `[--file FILE_PATH]` allows a text-based payload to be attached to the TCP packet. Use an explicit file path when specifying the payload path.

The `modify-ip` and `modify-[server,client]-port` are each used to change parts of the client/server config files. They change the IP and ports communicated over by the client and server scripts.

The `list-buffer` and `list-parsed` commands output a markdown formatted table of all nodes in the buffer and parsed lists, respectively.

The `show-node` command will show the markdown formatted entry of one particular node using its name as the key, as well as printing the payload associated with it (if there is one).

The `parse-manual` command will process the buffer list in order of reception, and prompt the user to input a name for each node to be saved as in the parsed node list. Once all nodes have been named, the list will be written and the buffer emptied.

The `parse-automatic` command will parse each node in the buffer iteratively. It takes three subsequent arguments: `PREFIX`, `LENGTH`, and `START`. The `PREFIX` argument defines a string of characters that the all nodes' names will begin with. The `LENGTH` argument defines how long the integer suffix will be, and the `START` argument defines where the integer suffix will start counting from. For example: the command `bin/hunter.rb parse-automatic node 3 001` on a list of three arbitrary nodes will produce the nodelist:

```
7E-8F-89-4F-47-9F: node001
0E-CC-B1-F2-23-DD: node002
59-D2-AE-26-D6-BA: node003
```

The `modify-mac` and `modify-name` commands change either the MAC or name of a node in the parsed list. 

The `remove-mac` and `remove-name` commands remove a node from the parsed list using either a MAC address or name as removal key, respectively.

The `dump-buffer` command simply empties the node buffer.


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

Flight Hunter is licensed under a [Creative Commons Attribution-ShareAlike 4.0 International License](http://creativecommons.org/licenses/by-sa/4.0/).

Based on a work at [https://github.com/openflighthpc/flight-hunter](https://github.com/openflighthpc/flight-hunter).

This content and the accompanying materials are made available available
under the terms of the Creative Commons Attribution-ShareAlike 4.0
International License which is available at [https://creativecommons.org/licenses/by-sa/4.0/](https://creativecommons.org/licenses/by-sa/4.0/),
or alternative license terms made available by Alces Flight Ltd -
please direct inquiries about licensing to
[licensing@alces-flight.com](mailto:licensing@alces-flight.com).

Flight Hunter is distributed in the hope that it will be useful, but
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, EITHER EXPRESS OR
IMPLIED INCLUDING, WITHOUT LIMITATION, ANY WARRANTIES OR CONDITIONS OF
TITLE, NON-INFRINGEMENT, MERCHANTABILITY OR FITNESS FOR A PARTICULAR
PURPOSE. See the [Creative Commons Attribution-ShareAlike 4.0
International License](https://creativecommons.org/licenses/by-sa/4.0/) for more
details.

