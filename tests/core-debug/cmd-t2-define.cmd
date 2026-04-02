confirm false

# The checking convention is: CHECK <id> <regexp>
# regexp and have multiple \n characters but not a trailing \n

define foo0
cd cp0
print v_short
end

thread 1

define foo1
cd cp1
print v_int
end
 
thread 0


# CHECK 0 foo0\nv_short = -2 \(
foo0

thread 1

# CHECK 1 foo1\nv_int = -3 \(
foo1

shutdown
