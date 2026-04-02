logging cmd-t4-logging.console.out
ls
thread 3
cd c7
ls
thread 1
cd c2
ls
set test_string HelloMyNameIsC2AndICannotQuoteAString
print test_string
thread 2
continue 1us
confirm false
shutdown
