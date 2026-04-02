confirm false

# The checking convention is: CHECK <id> <regexp>
# regexp and have multiple \n characters but not a trailing \n

# CHECK 0 thread 1\n---- Rank0:Thread1: Entering interactive mode
thread 1

# CHECK 1 thread 2\n---- Rank0:Thread2: Entering interactive mode
thread 2

# CHECK 2 thread 3\n---- Rank0:Thread3: Entering interactive mode
thread 3

# CHECK 3 thread 0\n---- Rank0:Thread0: Entering interactive mode
thread 0

shutdown
