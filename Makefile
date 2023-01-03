output/%_sim: src/%.v testbench/%_tb.v
	mkdir -p output
	iverilog -o $@ $^

output/i2c_target_sim: src/i2c_target.v src/i2c_controller.v src/register_data.v testbench/i2c_target_tb.v 

output/%_dump.vcd: output/%_sim
	vvp $<

%_gtkwave: output/%_dump.vcd
	gtkwave $<
