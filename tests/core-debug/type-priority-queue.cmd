confirm false

# The checking convention is: CHECK <id> <regexp>
# regexp and have multiple \n characters but not a trailing \n

# Extend the test time
cd cp1
ls
set clocks 1000000
cd ..
cd cp0
set clocks 1000000

# CHECK 0 p v_priority_queue_unsigned\nv_priority_queue_unsigned \(
p v_priority_queue_unsigned

cd v_priority_queue_unsigned
# CHECK 1 ls\ncontainer/ \(
ls

# CHECK 2 p container\ncontainer .+\n 0 = 3 .+\n 1 = 2 .+\n 2 = 1
p container

cd container
# CHECK 3 ls\n0 = 3 .+\n1 = 2 .+\n2 = 1
ls

# CHECK 4 p 0\n0 = 3
p 0

# CHECK 5 p 1\n1 = 2
p 1

# CHECK 6 p 2\n2 = 1
p 2

set 0 1300
set 1 1200
set 2 1100
# CHECK 7 ls\n0 = 1300 .+\n1 = 1200 .+\n2 = 1100
ls

# advance simulator sufficiently to observe change in front data
run 10400ns

# Here we see only the original values changing
# 1300000: v_queue_unsigned.front()=200
# 1300000: v_queue_unsigned.front()=200
# 2600000: v_queue_unsigned.front()=300
# 2600000: v_queue_unsigned.front()=300
# 3900000: v_queue_unsigned.front()=101
# 3900000: v_queue_unsigned.front()=101
# 5200000: v_queue_unsigned.front()=201
# 5200000: v_queue_unsigned.front()=201
# 6500000: v_queue_unsigned.front()=301
# 6500000: v_queue_unsigned.front()=301
# 7800000: v_queue_unsigned.front()=102
# 7800000: v_queue_unsigned.front()=102
# 9100000: v_queue_unsigned.front()=202
# 9100000: v_queue_unsigned.front()=202

# CHECK 8 pwd\ncp0/v_priority_queue_unsigned/container \(
pwd

# The values read do not match what is printed.
ls
# 0 = 1306 (unsigned int) <- this has changed!
# 1 = 1100 (unsigned int)
# 2 = 1200 (unsigned int)

#TODO Depending on how we handle the above add trace testing.

shutdown

