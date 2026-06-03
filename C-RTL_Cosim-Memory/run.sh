exec xvlog -sv dual_port_ram.sv top.sv
exec xelab -dpiheader dpiheader.h -svlog top.sv
exec xsc Ccode.cpp
exec xelab -svlog top.sv -sv_lib dpi -R

