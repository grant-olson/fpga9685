output/%_sim: src/%.v testbench/%_tb.v
	mkdir -p output
	iverilog -o $@ $^

output/%_dump.vcd: output/%_sim
	vvp $<

%_gtkwave: output/%_dump.vcd
	gtkwave $<
