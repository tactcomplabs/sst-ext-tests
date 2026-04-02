confirm false

# The checking convention is: CHECK <id> <regexp>
# regexp and have multiple \n characters but not a trailing \n

# CHECK 0 print cp1\ncp1
print cp1

# CHECK 1 thread 0\n---- Rank0:Thread0: Entering interactive mode
thread 0

# CHECK 2 print cp0\ncp0
print cp0

