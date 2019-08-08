# Hunter

A tool for tracking MAC addresses of nodes in a cluster.

## Overview

Hunter facilitates a communication between a two machines,
allowing one machine running the client script to send it's hostname
and MAC address to another machine running the server script.

## Installation

For installation instructions see INSTALL.md

## Configuration

Configuration for each script is handled by their respective `config.yaml`
files. The client configuration requires a server hostname and port
to communicate over, while the server configuration requires the# Hunter

A tool for tracking MAC addresses of nodes in a cluster.

## Overview

Hunter facilitates a communication between a two machines,
allowing one machine running the client script to send it's hostname
and MAC address to another machine running the server script.

## Installation

For installation instructions see INSTALL.md

## Configuration

Configuration for each script is handled by their respective `config.yaml`
files. The client configuration requires a server hostname and port
to communicate over, while the server configuration requires the
names of the YAML files to store processed/unprocessed nodes in, plus 
the port to listen over.

## Operation

Once the required configuration is complete, place the client folder on
all nodes to be recorded, and the server folder on the machine that will
be recording nodes.

### Server
The script is executed with `ruby server.rb`, but it has various options and arguments that must be specified at the command line.

The `-f. --find` option has the script listen over the port specified in `config.yaml`, recording all incoming hosts to the `.yaml` file designated by `not_processed_list` in `config.yaml`.

The `-m, --manual` option lets the user process the nodes saved to `not_processed_list` manually. For each node in the list, the user will be prompted to give it a name. Once all nodes in the list have been processed, they will be written to `nodelist`, `not_processed_list` will be formatted, and the script will terminate.

The `-a, --automatic $PREFIX,$LENGTH,$START` option lets the user process the nodes automatically, with a few required arguments. The `$PREFIX` argument requires a string to be used for the beginning of all nodes being processed. The `$LENGTH` argument requires an integer that specifies how many digits the integer counter at the end of the node names will be. The `$START` argument requires an integer of length `$LENGTH` from which to start counting.
For example, the command `ruby server.rb -a node 3 001` for 50 nodes will result in a `nodelist` that resembles the following:
```
---
examplemac1: node001
examplemac2: node002
.
.
examplemac50: node050
---
```

The `-l, --list` option will print a list of all the nodes saved in `nodelist` to the command line, in the format:
```
MAC address   Name
------------------------
examplemac1: node001
examplemac2: node002
.
.
examplemac50: node050
```

The `-r, --remove MAC` allows the user to remove a MAC: name (key,value) pairing from `nodelist`. The required argument `$MAC` should be a string containing the name of the MAC you would like to remove from the list (if you don't know the MAC you want to remove, run `-l` first).

The `-e, --edit MAC,NAME` option allows the user to edit one a MAC: name (key,value) pairing from `nodelist`. The required argument `$MAC` should be the MAC of the node you want to edit the name of, and the `$NAME` argument should be the new name to change it to.

### Client

Once `server.rb` is running with the `-f, --find` flag, the `client.rb` script can be executed with simply `ruby client.rb`. If the target IP : port in `config.yaml` is not reachable, the script will terminate with an error message. If the target is found and a successful communication occurs, the script will end naturally.



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

