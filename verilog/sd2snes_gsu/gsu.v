`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: N/A
// Engineer: Ari Sundholm <megari@iki.fi>
// 
// Create Date:    23:24:07 02/01/2015 
// Design Name: 
// Module Name:    gsu 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module gsu(
	input clkin,
	input [7:0] DI,
	output [7:0] DO,
	input [23:0] ADDR,
	input CS,
	input reg_we_rising
);

reg [2:0] clk_counter;
reg clk;

wire mmio_enable = CS & !ADDR[22] & (ADDR[15:12] == 4'b0011) & (ADDR[15:0] < 16'h3300);
wire MMIO_WR_EN = mmio_enable & reg_we_rising;

reg  [7:0] MMIO_DOr;
wire [7:0] MMIO_DO;
assign MMIO_DO = MMIO_DOr;

assign DO = mmio_enable ? MMIO_DO
            : 8'h00;

reg [15:0] regs [0:13]; // General purpose registers R0~R13
reg [15:0] regs_int [0:13];
reg [15:0] regs_mmio [0:13];
always @(MMIO_WR_EN,
         regs_mmio[0], regs_mmio[1], regs_mmio[2], regs_mmio[3], regs_mmio[4], regs_mmio[5],
         regs_mmio[6], regs_mmio[7], regs_mmio[8], regs_mmio[9], regs_mmio[10], regs_mmio[11],
         regs_mmio[12], regs_mmio[13],
         regs_int[0], regs_int[1], regs_int[2], regs_int[3], regs_int[4], regs_int[5],
         regs_int[6], regs_int[7], regs_int[8], regs_int[9], regs_int[10], regs_int[11],
         regs_int[12], regs_int[13]) begin
	regs[0] <= MMIO_WR_EN ? regs_mmio[0] : regs_int[0];
	regs[1] <= MMIO_WR_EN ? regs_mmio[1] : regs_int[1];
	regs[2] <= MMIO_WR_EN ? regs_mmio[2] : regs_int[2];
	regs[3] <= MMIO_WR_EN ? regs_mmio[3] : regs_int[3];
	regs[4] <= MMIO_WR_EN ? regs_mmio[4] : regs_int[4];
	regs[5] <= MMIO_WR_EN ? regs_mmio[5] : regs_int[5];
	regs[6] <= MMIO_WR_EN ? regs_mmio[6] : regs_int[6];
	regs[7] <= MMIO_WR_EN ? regs_mmio[7] : regs_int[7];
	regs[8] <= MMIO_WR_EN ? regs_mmio[8] : regs_int[8];
	regs[9] <= MMIO_WR_EN ? regs_mmio[9] : regs_int[9];
	regs[10] <= MMIO_WR_EN ? regs_mmio[10] : regs_int[10];
	regs[11] <= MMIO_WR_EN ? regs_mmio[11] : regs_int[11];
	regs[12] <= MMIO_WR_EN ? regs_mmio[12] : regs_int[12];
	regs[13] <= MMIO_WR_EN ? regs_mmio[13] : regs_int[13];
end
reg [15:0] rap;         // Game Pak ROM address pointer: R14
reg [15:0] rap_int;
reg [15:0] rap_mmio;
always @(MMIO_WR_EN, rap_mmio, rap_int) begin
	rap <= MMIO_WR_EN ? rap_mmio : rap_int;
end
reg [15:0] pc;          // Program counter: R15
reg [15:0] pc_int;
reg [15:0] pc_mmio;
always @(MMIO_WR_EN, pc_mmio, pc_int) begin
	pc <= MMIO_WR_EN ? pc_mmio : pc_int;
end

// Status/flag register flags
reg z;    // Zero
reg z_int;
reg z_mmio;
always @(MMIO_WR_EN, z_mmio, z_int) begin
	z <= MMIO_WR_EN ? z_mmio : z_int;
end
reg cy;   // Carry
reg cy_int;
reg cy_mmio;
always @(MMIO_WR_EN, cy_mmio, cy_int) begin
	cy <= MMIO_WR_EN ? cy_mmio : cy_int;
end
reg s;    // Sign
reg s_int;
reg s_mmio;
always @(MMIO_WR_EN, s_mmio, s_int) begin
	s <= MMIO_WR_EN ? s_mmio : s_int;
end
reg ov;   // Overflow
reg ov_int;
reg ov_mmio;
always @(MMIO_WR_EN, ov_mmio, ov_int) begin
	ov <= MMIO_WR_EN ? ov_mmio : ov_int;
end
reg g;    // Go
reg g_int;
reg g_mmio;
always @(MMIO_WR_EN, g_mmio, g_int) begin
	g <= MMIO_WR_EN ? g_mmio : g_int;
end
reg r;    // Reading ROM using R14
reg r_int;
reg r_mmio;
always @(MMIO_WR_EN, r_mmio, r_int) begin
	r <= MMIO_WR_EN ? r_mmio : r_int;
end
reg alt1; // Mode flag for next insn
reg alt1_int;
reg alt1_mmio;
always @(MMIO_WR_EN, alt1_mmio, alt1_int) begin
	alt1 <= MMIO_WR_EN ? alt1_mmio : alt1_int;
end
reg alt2; // Mode flag for next insn
reg alt2_int;
reg alt2_mmio;
always @(MMIO_WR_EN, alt2_mmio, alt2_int) begin
	alt2 <= MMIO_WR_EN ? alt2_mmio : alt2_int;
end
reg il;   // Immediate lower
reg il_int;
reg il_mmio;
always @(MMIO_WR_EN, il_mmio, il_int) begin
	il <= MMIO_WR_EN ? il_mmio : il_int;
end
reg ih;   // Immediate higher
reg ih_int;
reg ih_mmio;
always @(MMIO_WR_EN, ih_mmio, ih_int) begin
	ih <= MMIO_WR_EN ? ih_mmio : ih_int;
end
reg b;    // Instruction executed with WITH
reg b_int;
reg b_mmio;
always @(MMIO_WR_EN, b_mmio, b_int) begin
	b <= MMIO_WR_EN ? b_mmio : b_int;
end
reg irq;  // Interrupt
reg irq_int;
reg irq_mmio;
always @(MMIO_WR_EN, irq_mmio, irq_int) begin
	irq <= MMIO_WR_EN ? irq_mmio : irq_int;
end

reg [7:0] pbr;   // Program bank register
reg [7:0] pbr_int;
reg [7:0] pbr_mmio;
always @(MMIO_WR_EN, pbr_mmio, pbr_int) begin
	pbr <= MMIO_WR_EN ? pbr_mmio : pbr_int;
end
reg [7:0] rombr; // Game Pak ROM bank register
reg rambr;       // Game Pak RAM bank register
reg [15:0] cbr;  // Cache base register. [3:0] are always 0.
                 // TODO: why not make the register only 12 bits wide?
reg [7:0] scbr;  // Screen base register
reg [7:0] scbr_int;
reg [7:0] scbr_mmio;
always @(MMIO_WR_EN, scbr_mmio, scbr_int) begin
	scbr <= MMIO_WR_EN ? scbr_mmio : scbr_int;
end
reg [5:0] scmr;  // Screen mode register
reg [5:0] scmr_int;
reg [5:0] scmr_mmio;
always @(MMIO_WR_EN, scmr_mmio, scmr_int) begin
	scmr <= MMIO_WR_EN ? scmr_mmio : scmr_int;
end
reg [7:0] colr;  // Color register
reg [4:0] por;   // Plot option register
reg bramr;       // Back-up RAM register
reg bramr_int;
reg bramr_mmio;
always @(MMIO_WR_EN, bramr_mmio, bramr_int) begin
	bramr <= MMIO_WR_EN ? bramr_mmio : bramr_int;
end

reg [7:0] vcr;   // Version code register
reg [7:0] cfgr;  // Config register
reg [7:0] cfgr_int;
reg [7:0] cfgr_mmio;
always @(MMIO_WR_EN, cfgr_mmio, cfgr_int) begin
	cfgr <= MMIO_WR_EN ? cfgr_mmio : cfgr_int;
end
reg clsr;        // Clock select register
reg clsr_int;
reg clsr_mmio;
always @(MMIO_WR_EN, clsr_mmio, clsr_int) begin
	clsr <= MMIO_WR_EN ? clsr_mmio : clsr_int;
end

reg [7:0] curr_insn [0:2];
reg [1:0] insn_idx;
reg [1:0] fetches_left;
reg [7:0] pipeline;

reg [3:0] imm;
reg [3:0] src_reg;
reg [3:0] dst_reg;

/* Cache RAM and cache flags */
reg [7:0] cache [511:0];
reg [31:0] cache_flags;

/* XXX: old, useless cache stuff. Remove ASAP! */
reg [8:0] cache_addra;
wire [7:0] cache_douta;

/* For plotting, two pixel caches. */
reg[7:0] primary_pcache [7:0];
reg[7:0] primary_pcache_flags;
reg[7:0] secondary_pcache [7:0];
reg[7:0] secondary_pcache_flags;

reg fetch_cached_insn;

reg[0:0] state;
/*
parameter STATE_FETCHNLOAD = 2'b01;
parameter STATE_EXEC       = 2'b10;
*/
parameter STATE_BEGIN = 1'b0;
parameter STATE_FETCH = 1'b1; // This is somewhat misleadingly named.

parameter OP_ALT1 = 8'b00111101;
parameter OP_ALT2 = 8'b00111110;
parameter OP_ALT3 = 8'b00111111;
parameter OP_ADX  = 8'b0101zzzz;
parameter OP_BEQ  = 8'b00001001;
parameter OP_NOP  = 8'b00000001;

initial begin: initial_blk
	reg[1:0] i;
	clk = 1'b0;
	clk_counter = 3'h0;
	insn_idx = 2'b00;

	for (i = 0; i < 2'h3; i = i+1) begin
		curr_insn[i] = OP_NOP;
	end
	fetches_left = 2'b00;
	state = STATE_BEGIN;
end

always @(posedge clkin) begin
	if (clk_counter == 3'h0) begin
		clk = !clk;
	end
	clk_counter = clk_counter + 3'h1;

	// The upper limit depends on the frequency desired.
	if ((clsr == 1'b0 && clk_counter >= 3'h2) ||
	    (clsr == 1'b1 && clk_counter == 3'h4)) begin
		clk_counter = 3'h0;
	end
end

always @(posedge clk) begin
	if (fetch_cached_insn) begin
		pipeline = cache_douta;
	end
end

always @(posedge clk) begin // Should probably use clock in divided by 4 or 8

	// First, copy instruction from cache
	// TODO: reading from RAM & ROM
	curr_insn[insn_idx] = cache_douta;
	fetches_left = fetches_left - 2'b01;

	// If we are beginning a new instruction, determine the number of fetches needed.
	if (state == STATE_BEGIN) begin

		casez (curr_insn[insn_idx])
			OP_NOP:
			begin
				fetches_left = 2'b00;
			end
			OP_ADX:
			begin
				if (!alt1 && !alt2) begin
					// ADD Rn
					fetches_left = 2'b00;
				end
				else begin
					// ADC Rn
					// ADD #n
					// ADC #n
					fetches_left = 2'b01;
				end
			end
			OP_BEQ:
			begin
				fetches_left = 2'b01;
			end
		endcase
		state = STATE_FETCH;
	end

	// Fetch phase. This is always done.
	if (state == STATE_FETCH) begin
		// Start fetching next instruction from cache.
		// It will be ready next cycle.
		cache_addra = pc - cbr;
	end

`define NONE 1
`ifdef NONE
	// Exec phase. This is only done once the instruction's been read in full.
	if (fetches_left == 2'b00) begin
		//imm = curr_insn[insn_idx][3:0]; // Causes internal error in the compiler!?
		imm = curr_insn[insn_idx] & 8'h0f;

		casez (curr_insn[0])
			OP_NOP:
			begin
				// Just reset regs.
				b_int <= 1'b0;
				alt1_int <= 1'b0;
				alt2_int <= 1'b0;
				src_reg <= 3'h0;
				dst_reg <= 3'h0;
			end
`define NONE2 1
`ifdef NONE2
			OP_ADX:
			begin: op_adx_blk
				reg [16:0] tmp;

				if (!alt1 && !alt2) begin
					// ADD Rn
					tmp = regs[src_reg] + regs[imm];
				end
				else if (alt1 && !alt2) begin
					// ADC Rn
					tmp = regs[src_reg] + regs[imm] + cy;
				end
				else if (!alt1 && alt2) begin
					// ADD #n
					tmp = regs[src_reg] + imm;
				end
				else /* if (alt1 && alt2) */ begin
					// ADC #n
					tmp = regs[src_reg] + imm + cy;
				end

				// Set flags
				ov_int <= (~(regs[src_reg] ^ regs[imm])
							& (regs[imm] ^ tmp)
							& 16'h8000) != 0;
				s_int  <= (tmp & 16'h8000) != 0;
				cy_int <= tmp >= 17'h10000;
				z_int  <= (tmp & 16'hffff) == 0;

				// Set result
				regs_int[dst_reg] = tmp;

				// Register reset
				b_int    <= 1'b0;
				alt1_int <= 1'b0;
				alt2_int <= 1'b0;
				src_reg  <= 3'h0;
				dst_reg  <= 3'h0;
			end
			OP_BEQ:
			begin: op_beq_blk
				reg signed [7:0] tmp;
				tmp = pipeline;
				pc_int = pc + 1'b1;
				//pipeline = 8'b1; // XXX: NOP for now. Should read.
				//fetch_next_cached_insn;
				if (z) begin
					// XXX this is ugly!
					pc_int = $unsigned($signed(pc) + tmp);
				end
			end
`endif
		endcase

		state = STATE_BEGIN;
		insn_idx = 2'b00;
	end
`endif
end

wire [8:0] RESOLVED_CACHE_ADDR = (ADDR[9:0] + cbr) & 9'h1ff;

always @(posedge clkin) begin
	casex (ADDR[9:0])
		10'h000: MMIO_DOr <= regs[0][7:0];
		10'h001: MMIO_DOr <= regs[0][15:8];
		10'h002: MMIO_DOr <= regs[1][7:0];
		10'h003: MMIO_DOr <= regs[1][15:8];
		10'h004: MMIO_DOr <= regs[2][7:0];
		10'h005: MMIO_DOr <= regs[2][15:8];
		10'h006: MMIO_DOr <= regs[3][7:0];
		10'h007: MMIO_DOr <= regs[3][15:8];
		10'h008: MMIO_DOr <= regs[4][7:0];
		10'h009: MMIO_DOr <= regs[4][15:8];
		10'h00a: MMIO_DOr <= regs[5][7:0];
		10'h00b: MMIO_DOr <= regs[5][15:8];
		10'h00c: MMIO_DOr <= regs[6][7:0];
		10'h00d: MMIO_DOr <= regs[6][15:8];
		10'h00e: MMIO_DOr <= regs[7][7:0];
		10'h00f: MMIO_DOr <= regs[7][15:8];
		10'h010: MMIO_DOr <= regs[8][7:0];
		10'h011: MMIO_DOr <= regs[8][15:8];
		10'h012: MMIO_DOr <= regs[9][7:0];
		10'h013: MMIO_DOr <= regs[9][15:8];
		10'h014: MMIO_DOr <= regs[10][7:0];
		10'h015: MMIO_DOr <= regs[10][15:8];
		10'h016: MMIO_DOr <= regs[11][7:0];
		10'h017: MMIO_DOr <= regs[11][15:8];
		10'h018: MMIO_DOr <= regs[12][7:0];
		10'h019: MMIO_DOr <= regs[12][15:8];
		10'h01a: MMIO_DOr <= regs[13][7:0];
		10'h01b: MMIO_DOr <= regs[13][15:8];
		10'h01c: MMIO_DOr <= rap[7:0];
		10'h01d: MMIO_DOr <= rap[15:8];
		10'h01e: MMIO_DOr <= pc[7:0];
		10'h01f: MMIO_DOr <= pc[15:8];

		// Status flag register
		10'h030: MMIO_DOr <= {1'b0, r, g, ov, s, cy, z, 1'b0};
		10'h031: MMIO_DOr <= {irq, 1'b0, 1'b0, b, ih, il, alt2, alt1};

		//10'h032: Unused

		// Back-up RAM register: write only
		//10'h033: MMIO_DOr <= {7'b0000000, bramr};

		// Program bank register
		10'h034: MMIO_DOr <= pbr;

		// Game Pak ROM bank register
		10'h036: MMIO_DOr <= rombr;

		// Config register: write only
		//10'h037: MMIO_DOr <= cfgr;

		// Screen base register: write only
		//10'h038: MMIO_DOr <= scbr;

		// Clock select register: write only
		//10'h039: MMIO_DOr <= {7'b0000000, clsr};

		// Screen mode register: write only
		//10'h03a: MMIO_DOr <= {2'b00, scmr};

		// Version code register
		10'h03b: MMIO_DOr <= vcr;

		// Game Pak RAM bank register
		10'h03c: MMIO_DOr <= {7'b0000000, rambr};

		//10'h03d: Unused

		// Cache base register
		10'h03e: MMIO_DOr <= {cbr[7:4], 4'b0000};
		10'h03f: MMIO_DOr <= cbr[15:8];

		// Color register: no access from SNES CPU
		// Plot option register: no access from SNES CPU

		// Cache RAM
		10'h1xx, 10'h2xx: MMIO_DOr <= cache[RESOLVED_CACHE_ADDR];

		default: MMIO_DOr <= 8'hff;
	endcase
end

always @(posedge clkin) begin
	if (MMIO_WR_EN) begin
		casex (ADDR[9:0])
			10'h000: regs_mmio[0][7:0] <= DI;
			10'h001: regs_mmio[0][15:8] <= DI;
			10'h002: regs_mmio[1][7:0] <= DI;
			10'h003: regs_mmio[1][15:8] <= DI;
			10'h004: regs_mmio[2][7:0] <= DI;
			10'h005: regs_mmio[2][15:8] <= DI;
			10'h006: regs_mmio[3][7:0] <= DI;
			10'h007: regs_mmio[3][15:8] <= DI;
			10'h008: regs_mmio[4][7:0] <= DI;
			10'h009: regs_mmio[4][15:8] <= DI;
			10'h00a: regs_mmio[5][7:0] <= DI;
			10'h00b: regs_mmio[5][15:8] <= DI;
			10'h00c: regs_mmio[6][7:0] <= DI;
			10'h00d: regs_mmio[6][15:8] <= DI;
			10'h00e: regs_mmio[7][7:0] <= DI;
			10'h00f: regs_mmio[7][15:8] <= DI;
			10'h010: regs_mmio[8][7:0] <= DI;
			10'h011: regs_mmio[8][15:8] <= DI;
			10'h012: regs_mmio[9][7:0] <= DI;
			10'h013: regs_mmio[9][15:8] <= DI;
			10'h014: regs_mmio[10][7:0] <= DI;
			10'h015: regs_mmio[10][15:8] <= DI;
			10'h016: regs_mmio[11][7:0] <= DI;
			10'h017: regs_mmio[11][15:8] <= DI;
			10'h018: regs_mmio[12][7:0] <= DI;
			10'h019: regs_mmio[12][15:8] <= DI;
			10'h01a: regs_mmio[13][7:0] <= DI;
			10'h01b: regs_mmio[13][15:8] <= DI;
			10'h01c: rap_mmio[7:0] <= DI;
			10'h01d: rap_mmio[15:8] <= DI;
			10'h01e: pc_mmio[7:0] <= DI;
			10'h01f: pc_mmio[15:8] <= DI;

			// Status flag register
			10'h030: begin
				r_mmio <= DI[6];
				g_mmio <= DI[5];
				ov_mmio <= DI[4];
				s_mmio <= DI[3];
				cy_mmio <= DI[2];
				z_mmio <= DI[1];
			end
			10'h031: begin
				irq_mmio <= DI[7];
				b_mmio <= DI[4];
				ih_mmio <= DI[3];
				il_mmio <= DI[2];
				alt2_mmio <= DI[1];
				alt1_mmio <= DI[0];
			end

			//10'h032: Unused

			// Back-up RAM register
			10'h033: bramr_mmio <= DI[0];

			// Program bank register
			10'h034: pbr_mmio <= DI;

			// Game Pak ROM bank register: read only
			//10'h036: rombr <= DI;

			// Config register:
			10'h037: cfgr_mmio <= {DI[7], 1'b0, DI[5], 5'b00000};

			// Screen base register
			10'h038: scbr_mmio <= DI;

			// Clock select register
			10'h039: clsr_mmio <= DI[0];

			// Screen mode register
			10'h03a: scmr_mmio <= DI[5:0];

			// Version code register: read only
			//10'h03b: vcr <= DI;

			// Game Pak RAM bank register: read only
			//10'h03c: rambr <= DI[0];

			//10'h03d: Unused

			// Cache base register: read only
			//10'h03e: cbr[7:0] <= {DI[7:4], 4'b0000};
			//10'h03f: cbr[15:8] <= DI;

			// Color register: no access from SNES CPU
			// Plot option register: no access from SNES CPU

			// Cache RAM
			10'h1xx, 10'h2xx: begin
				cache[RESOLVED_CACHE_ADDR] <= DI;
				if (ADDR[0]) begin
					cache_flags[RESOLVED_CACHE_ADDR[8:4]] <= 1'b1;
				end
			end
		endcase
	end
end

endmodule
