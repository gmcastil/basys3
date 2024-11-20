# Suppress warnings about problems reading symbols
set StdArithNoWarnings 1
set NumericStdNoWarnings 1

vsim -c \
    -voptargs=+acc \
    "work.skid_buffer_tb"

log -r \*
run -all

exit