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

# CHECK 0 p v_queue_unsigned\nv_queue_unsigned \(
p v_queue_unsigned

cd v_queue_unsigned
# CHECK 1 ls\ncontainer/ \(
ls

# CHECK 2 p container\ncontainer .+\n 0 = 100 .+\n 1 = 200 .+\n 2 = 300
p container

cd container
# CHECK 3 ls\n0 = 100 .+\n1 = 200 .+\n2 = 300
ls

# CHECK 4 p 0\n0 = 100
p 0

# CHECK 5 p 1\n1 = 200
p 1

# CHECK 6 p 2\n2 = 300
p 2

set 0 1100
set 1 1200
set 2 1300
# CHECK 7 ls\n0 = 1100 .+\n1 = 1200 .+\n2 = 1300
ls

# advance simulator sufficiently to observe change in front data
run 10400ns

# confirm cp0 front value is changing
# DbgSST15[cp0:tickleBits:1300000]: v_queue_unsigned.front()=1200
# DbgSST15[cp0:tickleBits:2600000]: v_queue_unsigned.front()=1300
# DbgSST15[cp0:tickleBits:3900000]: v_queue_unsigned.front()=1101
# DbgSST15[cp0:tickleBits:5200000]: v_queue_unsigned.front()=1201
# DbgSST15[cp0:tickleBits:6500000]: v_queue_unsigned.front()=1301
# DbgSST15[cp0:tickleBits:7800000]: v_queue_unsigned.front()=1102
# DbgSST15[cp0:tickleBits:9100000]: v_queue_unsigned.front()=1202

# CHECK 8 pwd\ncp0/v_queue_unsigned/container \(
pwd

# CHECK 9 ls\n0 = 1202 \(.+\n1 = 1302 \(.+\n2 = 1103 \(
ls
# 0 = 1202 (unsigned int)
# 1 = 1302 (unsigned int)
# 2 = 1103 (unsigned int)

shutdown

