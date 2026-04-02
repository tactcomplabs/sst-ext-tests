confirm false
cd cp0
ls
cd v_bitset42/
ls
# CHECK 0 p 0\n0 = false \(bool\)
p 0
# CHECK 1 p 3\n3 = true \(bool\)
p 3
# CHECK 2 p 38\n38 = false \(bool\)
p 38
# CHECK 3 p 39\n39 = true \(bool\)
p 39
# Flip bits 38 and 39
set 38 1
set 39 0
run 1ns
# CHECK 4 p 38\n38 = true \(bool\)
p 38
# CHECK 5 p 39\n39 = false \(bool\)
p 39
cd ..
# std::vector<bool> v_vecbool  =  { true, false, true, true, false, false, true, true};
p v_vecbool
cd v_vecbool
ls
# CHECK 6 p 5\n5 = false \(bool\)
p 5
# CHECK 7 p 6\n6 = true \(bool\)
p 6
# flip 5 and 6
set 5 1
set 6 0
run 1ns
ls
# CHECK 8 p 5\n5 = true \(bool\)
p 5
# CHECK 9 p 6\n6 = false \(bool\)
p 6

# Invalid setting
set 5 0x10
# CHECK 10 p 5\n5 = true \(bool\)
p 5

# Watch a vector bool bit
watch 7 changed
# CHECK 11 run\n\n---- Rank0:Thread0: Entering interactive mode
run
ls

# clear all watches
unwatch

# back up to bitset and do the same
cd ..
cd v_bitset42/
watch 41 changed
# CHECK 12 run\n\n---- Rank0:Thread0: Entering interactive mode
run
ls

