# Hunter

A tool for tracking MAC addresses of nodes in a cluster.

## Overview

Flight Hunter facilitates a communication between a two machines,
allowing one machine running the client script to send it's hostname
and MAC address to another machine running the server script.

## Installation

For installation instructions see INSTALL.md

## Configuration

Configuration for each script is handled by their respective `config.yaml`
files. The client configuration requires a server hostname and port
to communicate over, while the server configuration requires the
name of the CSV file to store node hostname:MAC pairs in as well as the port to listen over.

## Operation

Once the required configuration is complete, place the client folder on
all nodes to be recorded, and the server folder on the machine that will
be recording nodes.
The server script can be launched by navigating to the `server`
directory and executing:
```ruby
ruby server.rb
```
Once the server script is running, client script(s) can be executed on
the client nodes. (please note: only one client can be handled at a time.)
The client script can be launched by navigating to the 'client'
directory and executing:
```ruby
ruby client.rb
```
The client script sends the hostname and MAC address over a TCP
connection and immediately exits. At this point, the server script
will prompt the user for input, asking what they would like to
save the node as in the nodelist. If the hostname or MAC address already
exists in the nodelist, the user will be told so and the node will not
be added. Once the client has been handled, the server continues
to listen for new client connections.

To exit the server script, either press `Ctrl-C` or `q` when prompted
by the script, while there are no clients being handled. All nodes
discovered during the session will be appended to the CSV specified
in the server `config.yaml`. If the specified CSV does not exist,
one will be made.

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
