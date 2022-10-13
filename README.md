# Hunter

A tool for tracking MAC addresses of nodes in a cluster.

## Overview

Hunter facilitates a communication between a two machines,
allowing one machine to send some diagnostic data and a payload
file to another machine listening for other nodes running Hunter.

## Installation

### Installing with the OpenFlight package repos
Flight Hunter is available in the OpenFlight User repos for Centos 7/8. This is the easiest way to install it, using the package manager of your choice.

### Manual installation

#### Prerequisites
Flight Hunter is developed and tested with Ruby version `2.7.1` and `bundler` `2.1.4`. Other versions may work but currently are not officially supported.

#### Steps
The following will install from source using `git`. The `master`. branch is the current development version and may not be appropriate for a production installation. Instead a tagged version should be checked out.

```bash
git clone https://github.com/alces-flight/flight-hunter.git
cd flight-hunter
git checkout <tag>
bundle install
```

Use the script located at `bin/hunter` to execute the tool.

## Configuration

Flight Hunter has some required configuration based on the environment it is being run on. A `config.yml.ex` file exists which gives examples of all configuration keys, required or optional.

- `port` - The port for the server to listen over; also the port for the client to send to.
- `target_host` - The hostname/IP for the client to attempt to send to.
- `autorun_mode` - Which mode to run when running the `autorun` command. Must be one of `hunt` or `send`. This setting can also be set (and is overridden by) the `flight_HUNTER_autorun_mode` environment variable.
- `include-self` - Toggle to automatically run `send` for itself when a `hunt` server is started.

Flight Hunter uses a PID file to track the `hunt` server process. By default, this PID file is created at `/tmp/hunter.pid`. The filepath used can be changed by setting the environment varaible `flight_HUNTER_pidfile`.


## Operation

A brief usage guide is given below. See the `help` command for further details and information about other commands.

Run the Hunter listening server with `hunt`. By default, nodes that already exist in the Hunter nodelist are ignored. Override existing nodes with `hunt --allow-existing`. The server can immediately `send` to itself with `--include-self`.

Run the Hunter payload transmitter with `send`. The system's hostid, IP, hostname, and a default payload of diagnostic data will be sent to the Hunter server running at the configured IP/port. The system hostname and payload can be overwritten via command line options.

Select nodes from the buffer list to move to the processed node list with `parse`. Generate labels automatically with the `prefix` and `start` command line options. For example:
`bin/hunter parse --prefix cnode --start 001`
will label each node in order `cnode001`, `cnode002`, and so on. When generating labels like this, the order that nodes are selected in will persist. If no label scheme is specified, the hostname of the node will be used instead. You may provide the `--auto` command line option to automatically process every node in the buffer in order. Please be aware that labels are considered unique across Hunter.

See all nodes in the node list with `list`.

Remove nodes from the node list with `remove-node`. When accessing the processed node list, specify the node by label; otherwise, specify the node by ID.

Add/remove groups to/from a node from the node list with `modify-groups`.

Update the label of a node in the processed list with `modify-label`.

Rename a group across a list with `rename-group`. All nodes with that group will be updated.

### Switching between buffer and processed list

Any command that accesses a node list (`show`, `remove-node`, etc.) will access the processed list by default. You may use the argument `--buffer` to instead use the buffer list.

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

