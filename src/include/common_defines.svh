`ifndef COMMON_DEFINES_SVH
`define COMMON_DEFINES_SVH

`define BR_TAKEN        1'b1
`define BR_NOT_TAKEN    1'b0

`define BHT_IDX_WIDTH       6

`define TAGE_IDX_WIDTH      (`BHT_IDX_WIDTH - 2)
`define TAGE_WEAK_TAKEN     3'b100
`define TAGE_WEAK_NOT_TAKEN 3'b011

`define GHIST_LEN   130
`define PHIST_LEN   16

`define PP_THRESHOLD    2863311530

typedef enum logic [1:0] {
    INIT = 2'b00,
    USER = 2'b01,
    PRIV = 2'b10,
    SHAR = 2'b11
} domain_t;

`endif