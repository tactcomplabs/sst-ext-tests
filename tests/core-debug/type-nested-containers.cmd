confirm false

# The checking convention is: CHECK <id> <regexp>
# regexp and have multiple \n characters but not a trailing \n

cd c0
cd function0/
ls
cd v_type3_
ls
cd 0
ls
cd 0
ls
cd first
ls

# CHECK 1 ls\n0 = one \(.+\n1 = two \(.+\n2 = three \(
ls

shutdown

