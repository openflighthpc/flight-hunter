**NAME:** 
server modify

**SYNOPSIS:**
hunter.rb server modify [options]

**DESCRIPTION:**
Modifies some element of the server side `config.yaml` file, or modifies one of the nodes in
either of the saved nodelists.

**OPTIONS:**
- *PORT* $PORT
&nbsp;&nbsp;&nbsp;&nbsp;- Changes the port to run the server process over. Replace $PORT with the desired port.
- *not_processed* $PATH.yaml
&nbsp;&nbsp;&nbsp;&nbsp;- Changes the file path in which to store the unprocessed list of nodes. Replace $PATH
&nbsp;&nbsp;&nbsp;&nbsp;  with the path relative to the `server` directory.
- *nodelist* $PATH.yaml
&nbsp;&nbsp;&nbsp;&nbsp;- Changes the file path in which to store the parsed list of nodes. Repalce $PATH with
&nbsp;&nbsp;&nbsp;&nbsp;  the path relative to the `server` directory.
- *mac* $LIST $MAC $NEWNAME
&nbsp;&nbsp;&nbsp;&nbsp;- Modifies the name of a node existing in the list $LIST (either `not_processed` or
&nbsp;&nbsp;&nbsp;&nbsp;  `nodelist`). The node with MAC address $MAC will be renamed to $NEWNAME.
- *name* $LIST $NAME $NEWMAC
&nbsp;&nbsp;&nbsp;&nbsp;- Modifies the MAC address of a node existing in the list $LIST (either `not_processed`
&nbsp;&nbsp;&nbsp;&nbsp;  or `nodelist`). The node with name $NAME will be reassigned the MAC address $NEWMAC.
