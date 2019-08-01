# Hunter

A tool for tracking MAC addresses of nodes in a cluster.

## Overview

Hunter facilitates a communication between a two machines,
allowing one machine running the client script to send it's hostname
and MAC address to another machine running the server script.

## Installation

To be completed...

## Configuration

To be completed...

## Operation

To be completed...

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
`server.rb` has the optional argument `-d`, or `--duplicates`. When parsed, this stops duplicate mac addresses from even being added to the process queue.
Once the server script is running, client script(s) can be executed on
the client nodes. The server script is multithreaded so that it can accept new incoming client transmissions while it is handling other clients. Incoming transmissions are added to a thread-safe queue, and the queue is processed until empty.
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
If the hostname already exists in the nodelist, the user will be prompted to choose another name.
If the MAC address already exists in the nodelist, the user will have the choice to rename the pre-existing node.

To exit the server script, either press `Ctrl-C` or `q` when prompted
by the script, while there are no clients being handled. All nodes
discovered during the session will be appended to the CSV specified
in the server `config.yaml`. If the specified CSV does not exist,
one will be made. WARNING: If unprocessed clients exist in the queue when the server is interrupted, those clients will not be added to the nodelist and will instead be discarded.

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
