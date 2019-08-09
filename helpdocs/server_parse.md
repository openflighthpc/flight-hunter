**NAME:** 
parse

**SYNOPSIS:**
hunter.rb server parse [options]

**DESCRIPTION:**
Parses each node in the unprocessed node list, assigns it a name,
and adds it to the parsed nodelist. Can be done automatically 
or manually.

**OPTIONS:**
- *manual*
&nbsp;&nbsp;&nbsp;&nbsp;- Takes user input to manually name each node.
- *automatic* [options]
&nbsp;&nbsp;&nbsp;&nbsp;- Automatically iterates over each node in the
&nbsp;&nbsp;&nbsp;&nbsp;  not processed list, assigning it a string prefix
&nbsp;&nbsp;&nbsp;&nbsp;  and a numeric suffix, incrementing the suffix per 
&nbsp;&nbsp;&nbsp;&nbsp;  node processed. See `ruby hunter.rb server parse`
&nbsp;&nbsp;&nbsp;&nbsp;  `automatic --help` for more information.
