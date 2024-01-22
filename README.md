# Hunter

A tool for tracking MAC addresses of nodes in a cluster.

## Overview

Hunter facilitates a communication between two machines, allowing one machine to send some data to another machine listening for other nodes running Hunter.

## Installation

### Installing with the OpenFlight package repos
Flight Hunter is available in the OpenFlight User repos for Centos 7/8. This is the easiest way to install it, using the package manager of your choice.

### Manual installation

#### Prerequisites
Flight Hunter is developed and tested with Ruby version `2.7.1` and `bundler` `2.1.4`. Other versions may work but currently are not officially supported.

#### Steps
The following will install from source using `git`. The `master`. branch is the current development version and may not be appropriate for a production installation. Instead a tagged version should be checked out.

```bash
https://github.com/openflighthpc/flight-hunter.git
cd flight-hunter
git checkout <tag>
bundle install
```

Use the script located at `bin/hunter` to execute the tool.

## Configuration

Flight Hunter has some required configuration based on the environment it is being run on. A `config.yml.ex` file exists which gives examples of all configuration keys, required or optional.

- `port` - The port for the server to listen over; also the port for the client to send to.
- `target_host` - The hostname/IP for the client to attempt to send to.
- `autorun_mode` - Which mode to run when running the `autorun` command. Must be one of `hunt` or `send`.
- `include_self` - Toggle to automatically run `send` for itself when a `hunt` server is started.
- `content_command` - A command which will be executed, with the output being sent when running `send`
- `allow_existing` - Overwrite existing nodes when hunting/parsing a node that already exists
- `auth_key` - Specify an authentication key allowing only nodes with a matching key to connect
- `broadcast_address` - Specify an IP address range to use when using `send`'s broadcast mode.
- `profile_command` - Specify the path to your Flight Profile executable (if it exists).
- `auto_parse` - A regular expresssion, nodes matching this expression will bypass the buffer and be parsed immediately when `hunt`ed
- `auto_apply` - Specify pairs of regular expressions and Flight Profile identities. If a node label matches the regular expression (when the node is parsed) then the corresponding Flight Profile identity is applied to it.
- `presets` - Specify preset data to send when sending to self using `hunt` with `--include self`. Includes `label`, `prefix` and `groups`.
- `default_label` - Must be either `long` (default), `short` or `blank`. When generating a label for a node, if the hostname would be used, it may be either shortened or made blank intead.
- `default_start` - The default start index when parsing automatically with a prefix. Note that this must be enclosed in quotation marks.
- `prefix_starts` - Custom start values for specified prefixes when automatically parsing. Note that given start values must be enclosed in quotation marks.
- `skip_used_index` - If automatic parsing attempts to create a label which already exists, skip that label and give the node a higher suffix until an unusued label is found.
- `retry_interval` - If the server cannot be found, retry every `n` seconds until a successful response is retrieved.

Each of the above config keys can be overwritten at all levels by an environment variable of the form `flight_HUNTER_*key*`.

Flight Hunter uses a PID file to track the `hunt` server process. By default, this PID file is created at `/tmp/hunter.pid`. The filepath used can be changed by setting the environment varaible `flight_HUNTER_pidfile`.


## Operation

A brief usage guide is given below. See the `help` command for further details and information about other commands.

Run the Hunter listening server with `hunt`. By default, nodes that already exist in the Hunter nodelist are ignored. Override existing nodes with `hunt --allow-existing`. The server can immediately `send` to itself with `--include-self`. The `--auto-parse` argument allows the server to attempt to automatically parse nodes whose hostname matches the given regular expression.

Run the Hunter payload transmitter with `send`. The system's hostid, IP, hostname, and a default chunk of diagnostic data will be sent to the Hunter server running at the configured IP/port. The system hostname and data content can be overwritten via command line options. You may also provide a label or a prefix to use for the node's label when being parsed by the host machine.

The `send` command will, by default, attempt to establish a TCP connection with the given `target_host`. You may also use the `--broadcast` option, to send a UDP packet via a given broadcast address. Currently, the only format supported is:

```
192.168.0.255
192.168.255.255
```

and so on. CIDR format IP ranges (e.g. `192.168.0.0/16`) are *not* currently supported. Please be aware that, by default, the maximum transmission unit for a UDP broadcast is 1500 bytes. Not all kernels support fragmentation for UDP broadcasts, so please be aware of your kernel's capabilities (and your payload size) before using this transmission mode.

See all nodes in the node list with `list`.

Remove nodes from the node list with `remove-node`. When accessing the processed node list, specify the node by label; otherwise, specify the node by ID.

Add/remove groups to/from a node from the node list with `modify-groups`.

Update the label of a node in the processed list with `modify-label`.

Rename a group across a list with `rename-group`. All nodes with that group will be updated.

### Node entry methods

The `remove-node` and `modify-groups` commands accept a comma separated collection of either node search terms or regular expressions to match nodes against. When modifying buffer list nodes with the `--buffer` option, the terms are matched against the nodes' IDs; when modifying parsed nodes, they are matched against node labels.
When using regular search terms, a comma separated list of terms is accepted. Each term can use genders-style square bracket syntax. Using a range of numbers in these brackets will search for anything in that range. For example:
```
node0[1-5],login[1-2]
```

will internally expand to:

```
node01, node02, node03, node04, node04, login1, login2
```

You may instead use a comma separated list of regular expressions at the CLI, by including the `--regex` option. In this case, _any_ nodes matching _any_ of the expressions will be accessed.
Please note that square bracket expansion is not supported for the regular expression input approach.


### Parsing nodes

Flight Hunter provides both interactive and command line methods for parsing nodes. Both methods support quasi-automatic label generation for parsed nodes with the `--prefix` and `--start` options.

#### Interactive menu

Launch the interactive parser with `bin/hunter parse` to be presented with a multi-selection menu:

```yaml
Select nodes: (Scroll for more nodes)
‣ ⬡ hostname1 - 10.50.0.40
  ⬡ hostname2 - 10.50.0.41
  ⬡ hostname3 - 10.50.0.42
```

Selecting a node from this menu will prompt the user for a label to assign to the node. If the node was sent with a `--label` or a `--prefix` (or if the user has chosen command line options for `prefix` and `start`), the input prompt will be pre-populated with the given data. If these are not given, the prompt will give the node hostname instead. The `--default-label` option may be used to `short`en this value, or make it `blank` entirely.

#### Automatic parser

Launch the automatic parser with `bin/hunter parse --auto`, along with any desired label generation options.  For example:

```bash
bin/hunter parse --prefix cnode --start 001

```

will label each node in order `cnode001`, `cnode002`, and so on. When generating labels like this, the order that nodes are selected in will persist. If no label scheme is specified, the hostname of the node will be used instead. You may provide the `--auto` command line option to automatically process every node in the buffer in order. Please be aware that labels are considered unique across Hunter.
Labels may also have their naming data pre-set by using the `--label` or `--prefix` options for `hunter send`.

* Nodes with a preset label will always attempt to use that label.

* Nodes without a preset label but with a preset prefix will generate a label involving the prefix and a numerical suffix determined based on the start value set through either the `default_start` or `prefix_starts` config options.

* Nodes without either of the above will take their hostnames as labels, which may be shortened up to the first `.` using the `short` value for the `default_label` config option.

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


