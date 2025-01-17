/*
This is a bimodal prediction history table (BHT)

Table Format:
[Bit 1][Bit 0]

Bit 1: if the branch was taken or not taken
Bit 0: If the prediction is strong or weak

if prev correct
    if curr strong, nothing changes in BHT
    if curr weak, update entry to strong
if prev incorrect
    if curr strong, update to weak
    if curr weak, change prediction from taken to not taken or from not taken to taken
*/

`include "common_defines.svh"

module bht
    (
        input logic clk_i,

        input logic rst_i,

        input logic br_result_i, update_en_i,
        input logic [`BHT_IDX_WIDTH-1:0] idx_i,

        output logic prediction_o
        
        // Domain owner of the current request
        , input domain_t domain_i
        , input [31:0] targ_i
        // Target address
        , output logic [31:0] targ_o
    );

    logic [`BHT_IDX_WIDTH-1:0] prev_idx;
    
    // BHT data
    // logic [1:0] bht_data [2**`BHT_IDX_WIDTH-1:0];

    logic [1:0] bht_data_priv [2**`BHT_IDX_WIDTH-1:0];
    logic [1:0] bht_data_user [2**`BHT_IDX_WIDTH-1:0];

    logic [31:0] bht_targ_priv [2**`BHT_IDX_WIDTH-1:0];
    logic [31:0] bht_targ_user [2**`BHT_IDX_WIDTH-1:0];
    
    logic [31:0] prev_targ;
    domain_t prev_domain;

    // Initialize data to 00 indicating a strong predict not taken entry
    // initial begin
    //     for (int i = 0; i < 2**`BHT_IDX_WIDTH; i++)
    //         bht_data[i] = 2'b0;
    // end

    always_ff @(posedge clk_i) begin

    if (rst_i) begin
        for (int i = 0; i < 2**`BHT_IDX_WIDTH; i++) begin
            bht_data_user[i] = 2'b0;
            bht_data_priv[i] = 2'b0;
            bht_targ_user[i] = 0;
            bht_targ_priv[i] = 0;
        end
        

        // Reset additions
        prediction_o <= 1'b0;
        prev_idx <= 0;
        prev_targ <= 0;
        prev_domain <= INIT;
    end else begin

        // Update previous entry based on prediction results
        if (prev_idx != idx_i && update_en_i) begin
            if (prev_domain == PRIV) begin
                if(br_result_i) begin
                    if (bht_data_priv[prev_idx] != 2'b11) 
                        bht_data_priv[prev_idx] <= bht_data_priv[prev_idx] + 1;
                    bht_targ_priv[prev_idx] <= prev_targ;
                end else if(~br_result_i && (bht_data_priv[prev_idx] != 2'b0)) begin
                    bht_data_priv[prev_idx] <= bht_data_priv[prev_idx] - 1;
                end    
            end else if (prev_domain == USER) begin
                if(br_result_i) begin
                    if (bht_data_user[prev_idx] != 2'b11)
                        bht_data_user[prev_idx] <= bht_data_user[prev_idx] + 1;
                    bht_targ_user[prev_idx] <= prev_targ;
                end else if(~br_result_i && (bht_data_user[prev_idx] != 2'b0)) begin
                    bht_data_user[prev_idx] <= bht_data_user[prev_idx] - 1;
                end
            end
        end

        // Output prediction for current entry
        if (domain_i == PRIV) begin
            prediction_o <= bht_data_priv[idx_i][1];
            targ_o <= bht_targ_priv[idx_i];
        end else begin
            prediction_o <= bht_data_user[idx_i][1];
            targ_o <= bht_targ_user[idx_i];
        end
        prev_idx <= idx_i;
        prev_targ <= targ_i;
        prev_domain <= domain_i;
    end
    
    end
endmodule