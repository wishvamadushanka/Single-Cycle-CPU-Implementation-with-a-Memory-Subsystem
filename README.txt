1. Compile
	iverilog -o cpu.vvp control.v cpu.v alu.v reg_file.v data_cache.v data_memory.v ins_cache.v data_memory_ins.v testbed.v

2. Run
	vvp cpu.vvp

3. Open with gtkwave tool
	gtkwave wavedata.vcd