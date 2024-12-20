## UART TX pin (FPGA transmitting data to the PC)
set_property PACKAGE_PIN B16 [get_ports tx]
set_property IOSTANDARD LVCMOS33 [get_ports tx]

## UART RX pin (FPGA receiving data from the PC)
#set_property PACKAGE_PIN B15 [get_ports rx]
#set_property IOSTANDARD LVCMOS33 [get_ports rx]

## Reset pin connected to the center button (BTN_CENTER on Basys-3)
set_property PACKAGE_PIN U18 [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports rst]

## Clock constraints for the system clock
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
