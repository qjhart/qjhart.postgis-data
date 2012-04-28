import sys

#sqlite CMZ\ 45.gdb ".dump managements" | python fixsql.py | psql testlite


print "".join([i.replace("'managements'", "managements").replace("varvchar", "varchar").replace('text(8)','text')  for i in sys.stdin.readlines()[1:-3]])
