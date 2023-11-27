// systemverilog module that implements our module jtag test logic
//  alongside example system logic and boundary scan register


module top (    
    // jtag logic
    (* mark_debug = "true" *) input tck,tdi,tms,trst,
    (* mark_debug = "true" *) output tdo,

    // dut logic
    input sysclk,
    input reset
);

logic [6:0] bsr_chain;

logic bsr_tdi, bsr_clk, bsr_update, bsr_shift, bsr_enable, bsr_mode, bsr_tdo;

logic [31:0] PCF, PCF_internal;
logic [31:0] InstrF, InstrF_internal;
logic 	     MemWriteM, MemWriteM_internal;
logic [31:0] DataAdrM, DataAdrM_internal;
logic [31:0] WriteDataM, WriteDataM_internal;
logic [31:0] ReadDataM, ReadDataM_internal;

assign bsr_chain[0] = bsr_tdi;
assign bsr_tdo = bsr_chain[6];

// test logic ////////////////////////////////////////////////////

jtag_test_logic jtag (
    .tck(tck),
    .tms(tms),
    .tdi(tdi),
    .trst(trst),
    .tdo(tdo),
    .bsr_tdi(bsr_tdi),
    .bsr_clk(bsr_clk),
    .bsr_update(bsr_update),
    .bsr_shift(bsr_shift),
    .bsr_mode(bsr_mode),
    .bsr_tdo(bsr_tdo)
);

// RISC-V Core ///////////////////////////////////////////////////

riscv core (
    .clk(sysclk),
    .reset(reset),
    .PCF(PCF_internal),
    .InstrF(InstrF_internal),
    .MemWriteM(MemWriteM_internal),
    .ALUResultM(DataAdrM_internal),
    .WriteDataM(WriteDataM_internal),
    .ReadDataM(ReadDataM_internal)
);

// Core memory

imem imem (PCF, InstrF);
dmem dmem (sysclk, MemWriteM, DataAdrM, WriteDataM, ReadDataM);

// boundary scan registers ///////////////////////////////////////


bsr #(.WIDTH(32)) PCF_bsr (
    .clk(sysclk),
    .update_dr(bsr_update),
    .shift_dr(bsr_shift),
    .mode(bsr_mode),
    .tdi(bsr_chain[0]),
    .tdo(bsr_chain[1]),
    .parallel_in(PCF_internal),
    .parallel_out(PCF)
);

bsr #(.WIDTH(32)) InstrF_bsr (
    .clk(sysclk),
    .update_dr(bsr_update),
    .shift_dr(bsr_shift),
    .mode(bsr_mode),
    .tdi(bsr_chain[1]),
    .tdo(bsr_chain[2]),
    .parallel_in(InstrF),
    .parallel_out(InstrF_internal)
);

bsr #(.WIDTH(1)) MemWriteM_bsr (
    .clk(sysclk),
    .update_dr(bsr_update),
    .shift_dr(bsr_shift),
    .mode(bsr_mode),
    .tdi(bsr_chain[2]),
    .tdo(bsr_chain[3]),
    .parallel_in(MemWriteM_internal),
    .parallel_out(MemWriteM)
);

bsr #(.WIDTH(32)) DataAdrM_bsr (
    .clk(sysclk),
    .update_dr(bsr_update),
    .shift_dr(bsr_shift),
    .mode(bsr_mode),
    .tdi(bsr_chain[3]),
    .tdo(bsr_chain[4]),
    .parallel_in(DataAdrM_internal),
    .parallel_out(DataAdrM)
);

bsr #(.WIDTH(32)) WriteDataM_bsr (
    .clk(sysclk),
    .update_dr(bsr_update),
    .shift_dr(bsr_shift),
    .mode(bsr_mode),
    .tdi(bsr_chain[4]),
    .tdo(bsr_chain[5]),
    .parallel_in(WriteDataM_internal),
    .parallel_out(WriteDataM)
);

bsr #(.WIDTH(32)) ReadDataM_bsr (
    .clk(sysclk),
    .update_dr(bsr_update),
    .shift_dr(bsr_shift),
    .mode(bsr_mode),
    .tdi(bsr_chain[5]),
    .tdo(bsr_chain[6]),
    .parallel_in(ReadDataM),
    .parallel_out(ReadDataM_internal)
);


endmodule // top