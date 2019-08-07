**NAME:** 
parse automatic

**SYNOPSIS:**
hunter.rb server parse automatic $PREFIX $LENGTH $START

**DESCRIPTION:**
Parse received nodes from the unprocessed list and automatically give each node a name
based on the supplied $PREFIX, $LENGTH, and $START arguments.

**OPTIONS:**
- *$PREFIX*
&nbsp;&nbsp;&nbsp;&nbsp;- The required arguemnt $PREFIX provides a string that every node processed will
&nbsp;&nbsp;&nbsp;&nbsp;  begin with.
- *$LENGTH*
&nbsp;&nbsp;&nbsp;&nbsp;- The required argument $LENGTH provides the length in digits of the numeric suffix
&nbsp;&nbsp;&nbsp;&nbsp;  each node will end with.
- *$START*
&nbsp;&nbsp;&nbsp;&nbsp;- The required argument $START describes with numeric value the node parser should
&nbsp;&nbsp;&nbsp;&nbsp;  begin counting from. NOTE: $START must be the same length as described in $LENGTH

**EXAMPLE:**
`ruby hunter.rb server parse automatic node 3 001`
will result in nodes being named as such:

```
node001
node002
node003
...
nodeNNN
```
