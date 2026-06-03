set start_time [clock microseconds]
run all
set end_time [clock microseconds]
set total_time [expr $end_time - $start_time]
puts "\n=================================================="
puts "DPI-C Execution Time: $total_time microseconds per iteration"
puts "==================================================\n"
quit
