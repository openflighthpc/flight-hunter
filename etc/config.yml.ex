---
# Host to send data to when running client (optional)
# target_host:
#
# Port to listen/send over. This must match on both server and client. (required)
# port:
#
# Mode to use when autorun (optional)
# autorun_mode:
#
# Automatically include self when hunting (optional)
# include_self: false
#
# Command to use to generate content (optional)
# content_command:
#
# Allow existing nodes when hunting (optional)
# allow_existing: false
#
# Key used to authenticate data (required)
# auth_key: flight-hunter
#
# Broadcast address to use when sending via a UDP broadcast (optional)
# broadcast_address: 127.0.255.255
#
# Command used to run the Flight Profile executable (optional)
# profile_command:
#
# Attempt to automatically parse nodes when hunted, if they match the given
# regular expression (optional)
# auto_parse: /expression/
#
# Attempt to automatically trigger Flight Profile for nodes that have been
# picked up by the `auto_parse` functionality. Must be a set of key/value
# pairs, where the key is a regular expression to match the node's label
# against and the value is the name of an identity existing within your
# given Flight Profile installation
# auto_apply:
#   exp1: identity1
#   exp2: identity2
#
# Preset data to send
# presets:
#   label:
#   prefix:
#   groups:
#     - example_group1
#     - example_group2
#
# Attempt to shorten given hostnames by removing everything after the 
# first "." (optional)
# short_hostname: true
#
# Default number start value for automatically parsed nodes
# default_start: "01"
#
# List of custom start values for given prefixes. (optional)
# Each entry should be of the form <prefix>: "<start value>"
# prefix_starts:
#
# If automatic parsing attempts to create a label which already exists, 
# skip that label and give the node a higher suffix until an unusued label is found.
# If false, an error is raised when names clash in this manner.
# skip_used_index: true
