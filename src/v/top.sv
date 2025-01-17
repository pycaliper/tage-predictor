`include "common_defines.svh"

module top
    (
        /* verilator lint_off UNUSED */
        input logic clk_i,

        input logic rst_i,

        input logic br_result_i, update_en_i, correct_i,
        input logic [31:0] idx_i,
        /* verilator lint_on UNUSED */
        output logic prediction_o
`ifdef VERILOG
        , input [31:0] nd
`endif
        , input domain_t domain_i
        , input [31:0] targ_i
        , output logic [31:0] targ_o
    );
    /* verilator lint_off WIDTH */
    //assign prediction_o = `BR_TAKEN;
    //bht b (.*);
    tage_predictor tp (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .br_result_i(br_result_i),
        // .update_en_i(update_en_i),
        .correct_i(correct_i),
        .idx_i(idx_i),
        .prediction_o(prediction_o),
`ifdef VERILOG
        .nd(nd),
`endif
        .domain_i(domain_i),
        .targ_o(targ_o)
    );
    /* verilator lint_on WIDTH */
endmodule