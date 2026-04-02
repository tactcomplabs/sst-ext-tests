confirm false

# The checking convention is: CHECK <id> <regexp>
# regexp and have multiple \n characters but not a trailing \n

cd c0
cd function0/
cd v_queue_unsigned_/
cd container/
# CHECK 0 pwd\nc0/function0/v_queue_unsigned_/container \(
pwd

# CHECK 1 ls\n0 = 100 \(.+\n1 = 200 \(.+\n2 = 300 \(
ls
# 0 = 100 (unsigned int)
# 1 = 200 (unsigned int)
# 2 = 300 (unsigned int)
run 10ns
# 1000: v_queue_unsigned_.front()=200
# 2000: v_queue_unsigned_.front()=300
# 3000: v_queue_unsigned_.front()=101
# 4000: v_queue_unsigned_.front()=201
# 5000: v_queue_unsigned_.front()=301
# 6000: v_queue_unsigned_.front()=102
# 7000: v_queue_unsigned_.front()=202
# 8000: v_queue_unsigned_.front()=302
# 9000: v_queue_unsigned_.front()=103
# Entering interactive mode at time 10000 
# Ran clock for 10000 sim cycles

# CHECK 2 ls\n0 = 103 \(.+\n1 = 203 \(.+\n2 = 303 \(
ls
# 0 = 103 (unsigned int)
# 1 = 203 (unsigned int)
# 2 = 303 (unsigned int)

# sst-core #1517 refreshes object map on break into interactive mode.
# Solution for watchpoints is....?

# watch 0 changed
# run
# # check- 3 ls\n0 = 104 \(.+\n1 = 204 \(.+\n2 = 304 \(
# ls

# run
# # check- 4 ls\n0 = 105 \(.+\n1 = 205 \(.+\n2 = 305 \(
# ls

# unwatch 0
# watch 0 > 200
# # check- 5 ls\n0 = 201 \(.+\n1 = 301 \(.+\n2 = 401 \(
# ls

shutdown

