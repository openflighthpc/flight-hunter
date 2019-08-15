**NAME:** 
server

**SYNOPSIS:**
hunter.rb server [options]

**DESCRIPTION:**
Subcommand to filter commands into server side options.

**OPTIONS:**
- *hunt*
&nbsp;&nbsp;&nbsp;&nbsp;- Begins listening over the port specified in `config.yaml` for clients running
&nbsp;&nbsp;&nbsp;&nbsp;  the `send` command. To revoke automatic rejection of MACs/hostnames that already
&nbsp;&nbsp;&nbsp;&nbsp;  exist in either saved list, pass the optional argument *allow_existing*.
- *list* [option]
&nbsp;&nbsp;&nbsp;&nbsp;- Displays a formatted list of one of the nodelists (unprocessed,parsed).
- *parse* [options]
&nbsp;&nbsp;&nbsp;&nbsp;- Processes each node in the unprocessed node list and appends them to the parsed
&nbsp;&nbsp;&nbsp;&nbsp;  nodelist. Can be done manually or automatically, with the flags `manual` or 
&nbsp;&nbsp;&nbsp;&nbsp;  `automatic` (see *server parse automatic --help* for more information).
- *remove* [options]
&nbsp;&nbsp;&nbsp;&nbsp;- Removes a node from either of the nodelists, using either MAC or name as a primary
&nbsp;&nbsp;&nbsp;&nbsp;  key.
- *modify* [options]
&nbsp;&nbsp;&nbsp;&nbsp;- Modifies a node from the parsed nodelist. Can change either the MAC or the
&nbsp;&nbsp;&nbsp;&nbsp;  name, using the inverse as the key. *Modify* also changes the `config.yaml`,
&nbsp;&nbsp;&nbsp;&nbsp;  setting the file paths to use for the unprocessed and parsed nodelists, as well
&nbsp;&nbsp;&nbsp;&nbsp;  as the port to listen over.

