cd c0
cd xorshift
trace w changed : 32 4 : w x y z : checkpoint
setHandler 0 ae ac
# CHECK 0 printWatchpoint 0\nWP0: TriggerCount 0 : AC AE : c0/xorshift/w CHANGED  : bufsize = 32 postDelay = 4 : c0/xorshift/w c0/xorshift/x c0/xorshift/y c0/xorshift/z  : checkpoint
printWatchpoint 0
run 100us
shutdown
