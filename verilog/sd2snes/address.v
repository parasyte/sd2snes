`timescale 1 ns / 1 ns
//////////////////////////////////////////////////////////////////////////////////
// Company: Rehkopf
// Engineer: Rehkopf
// 
// Create Date:    01:13:46 05/09/2009 
// Design Name: 
// Module Name:    address 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: Address logic w/ SaveRAM masking
//
// Dependencies: 
//
// Revision: 
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module address(
    input CLK,
    input [2:0] MAPPER,       // MCU detected mapper
    input [23:0] SNES_ADDR,   // requested address from SNES
    input SNES_CS,            // "CART" pin from SNES (active low)
    output [22:0] ROM_ADDR,   // Address to request from SRAM0
    output ROM_SEL,            // enable SRAM0 (active low)
    input MCU_OVR,            // enable MCU master mode (active low)
    input MODE,               // MCU(1) or SNES(0) ("bus phase")
    output IS_SAVERAM,        // address/CS mapped as SRAM?
    output IS_ROM,            // address mapped as ROM?
	 output IS_WRITABLE,       // address somehow mapped as writable area?
    input [23:0] MCU_ADDR,    // allow address to be set externally
    input ADDR_WRITE,
    output ROM_ADDR0,
    input [23:0] SAVERAM_MASK,
    input [23:0] ROM_MASK,
	 input use_msu,
	 output msu_enable,
	 output srtc_enable,
    output use_bsx,
	 input [14:0] bsx_regs,
   output dspx_enable,
   output dspx_a0
    );

wire [1:0] SRAM_BANK;

wire [23:0] SRAM_ADDR_FULL;

/* currently supported mappers:
   Index     Mapper     
      000      HiROM
      001      LoROM
      010      ExHiROM (48-64Mbit)
      011      BS-X
      100      DSPx (HiROM - 00-0f:6000-7fff)
      101      DSPx (LoROM - 30-3f:8000-ffff)
      110      brainfuck interleaved 96MBit Star Ocean =)
      111      menu (ROM in upper SRAM)
*/

/*                               HiROM:   SRAM @ Bank 0x30-0x3f, 0xb0-0xbf
                                          Offset 6000-7fff */

assign IS_ROM = ( (MAPPER == 3'b000) ? ((!SNES_ADDR[22] & SNES_ADDR[15])
                                       |(SNES_ADDR[22]))
                : (MAPPER == 3'b001) ? ((!SNES_ADDR[22] & SNES_ADDR[15])
                                       |(SNES_ADDR[22]))                                         
                : (MAPPER == 3'b010) ? ((!SNES_ADDR[22] & SNES_ADDR[15])
                                       |(SNES_ADDR[22]))
                : (MAPPER == 3'b011) ? ((!SNES_ADDR[22] & SNES_ADDR[15])
                                       |(SNES_ADDR[22]))
                : (MAPPER == 3'b100) ? ((!SNES_ADDR[22] & SNES_ADDR[15])
                                       |(SNES_ADDR[22]))
                : (MAPPER == 3'b101) ? ((!SNES_ADDR[22] & SNES_ADDR[15])
                                       |(SNES_ADDR[22]))                
                : (MAPPER == 3'b110) ? ((!SNES_ADDR[22] & SNES_ADDR[15])
                                       |(SNES_ADDR[22]))
                : (MAPPER == 3'b111) ? ((!SNES_ADDR[22] & SNES_ADDR[15])
                                       |(SNES_ADDR[22]))
                : 1'b0);


assign IS_SAVERAM = ((MAPPER == 3'b000 || MAPPER == 3'b010 || MAPPER == 3'b100 || MAPPER == 3'b110 || MAPPER == 3'b111) ? (!SNES_ADDR[22]
                                           & &SNES_ADDR[21:20]                                           
                                           & &SNES_ADDR[14:13]
                                           & !SNES_ADDR[15]
                                           )
/*                               LoROM:   SRAM @ Bank 0x70-0x7d, 0xf0-0xfd
                                          Offset 0000-7fff TODO: 0000-ffff for
                                          small ROMs */
                    :(MAPPER == 3'b001 || MAPPER == 3'b101) ? (&SNES_ADDR[22:20]
                                           & (SNES_ADDR[19:16] < 4'b1110)
                                           & !SNES_ADDR[15])
/*										   BS-X: SRAM @ Bank 0x10-0x17
                                       Offset 5000-5fff */													
						  :(MAPPER == 3'b011) ? ((SNES_ADDR[23:19] == 5'b00010)
						                         & (SNES_ADDR[15:12] == 4'b0101)
														 )
                    : 1'b0);


assign IS_WRITABLE = IS_SAVERAM | (
                       (MAPPER == 3'b011)
                        ? ( 
								    (bsx_regs[3] && SNES_ADDR[23:20]==4'b0110)
									|(!bsx_regs[5] && SNES_ADDR[23:20]==4'b0100)
									|(!bsx_regs[6] && SNES_ADDR[23:20]==4'b0101)
									|(SNES_ADDR[23:19] == 5'b01110)
									|(SNES_ADDR[23:21] == 3'b001 && SNES_ADDR[15:13] == 3'b011))
							   : 1'b0);

/* BSX regs:
	Index		Function
		1		0=map flash to ROM area; 1=map PRAM to ROM area
		2		1=HiROM; 0=LoROM
		3		1=Mirror PRAM @60-6f:0000-ffff
		5		1=DO NOT mirror PRAM @40-4f:0000-ffff
		6		1=DO NOT mirror PRAM @50-5f:0000-ffff
		7		1=map BSX cartridge ROM @00-1f:8000-ffff
		8		1=map BSX cartridge ROM @80-9f:8000-ffff
*/

assign SRAM_ADDR_FULL = (MODE) ? MCU_ADDR
                          : ((MAPPER[1:0] == 2'b00) ?
                              (IS_SAVERAM ? 24'hE00000 + ((SNES_ADDR[14:0] - 15'h6000) & SAVERAM_MASK)
                                          : ({1'b0, SNES_ADDR[22:0]} & ROM_MASK))
                            :(MAPPER[1:0] == 2'b01) ? 
                              (IS_SAVERAM ? 24'hE00000 + (SNES_ADDR[14:0] & SAVERAM_MASK)
                                          : ({2'b00, SNES_ADDR[22:16], SNES_ADDR[14:0]} & ROM_MASK))
                            :(MAPPER == 3'b010) ?
                              (IS_SAVERAM ? 24'hE00000 + ((SNES_ADDR[14:0] - 15'h6000) & SAVERAM_MASK)
                                          : ({1'b0, !SNES_ADDR[23], SNES_ADDR[21:0]} & ROM_MASK))
                            :(MAPPER == 3'b011) ?
                              (IS_SAVERAM ? 24'hE00000 + {SNES_ADDR[18:16], SNES_ADDR[11:0]}
                                          : IS_WRITABLE ? (24'h400000 + (SNES_ADDR & 24'h0FFFFF /*7ffff*/))
                                                        : ((bsx_regs[7] && SNES_ADDR[23:21] == 3'b000)
                                                           |(bsx_regs[8] && SNES_ADDR[23:21] == 3'b100))
                                                            ? (24'h800000 + ({1'b0, SNES_ADDR[23:16], SNES_ADDR[14:0]} & 24'h0FFFFF))
                                                            : ((bsx_regs[1] ? 24'h400000 : 24'h000000)
                                                               + bsx_regs[2] ? ({2'b00, SNES_ADDR[21:0]} & (ROM_MASK /* >> bsx_regs[1] */))
                                                                             : ({1'b0, SNES_ADDR[23:16], SNES_ADDR[14:0]} & (ROM_MASK /* >> bsx_regs[1] */))))
                            :(MAPPER == 3'b110) ?
                              (IS_SAVERAM ? 24'hE00000 + ((SNES_ADDR[14:0] - 15'h6000) & SAVERAM_MASK)
                                          : (SNES_ADDR[15] ? ({1'b0, SNES_ADDR[23:16], SNES_ADDR[14:0]})
                                                           : ({2'b10, SNES_ADDR[23], SNES_ADDR[21:16], SNES_ADDR[14:0]})))
                            :(MAPPER == 3'b111) ?
                              (IS_SAVERAM ? 24'hFF0000 + ((SNES_ADDR[14:0] - 15'h6000) & SAVERAM_MASK)
                                          : (({1'b0, SNES_ADDR[22:0]} & ROM_MASK) + 24'hE00000))
                            : 24'b0);

assign ROM_ADDR = SRAM_ADDR_FULL[23:1];

assign ROM_SEL = 1'b0; // (MODE) ? CS_ARRAY[SRAM_BANK] : IS_SAVERAM ? 4'b1000 : CS_ARRAY[SRAM_BANK];

assign ROM_ADDR0 = SRAM_ADDR_FULL[0];
//488888
assign msu_enable = (!SNES_ADDR[22] && ((SNES_ADDR[15:0] & 16'hfff8) == 16'h2000));
assign use_bsx = (MAPPER == 3'b011);

assign srtc_enable = (!SNES_ADDR[22] && ((SNES_ADDR[15:0] & 16'hfffe) == 16'h2800));

// DSP1 LoROM: DR=30-3f:8000-bfff; SR=30-3f:c000-ffff
//          or DR=60-6f:0000-3fff; SR=60-6f:4000-7fff
// DSP1 HiROM: DR=00-0f:6000-6fff; SR=00-0f:7000-7fff
assign dspx_enable =
  (MAPPER == 3'b101) ? 
    (ROM_MASK[20] ? 
      (SNES_ADDR[22] & SNES_ADDR[21] & ~SNES_ADDR[20] & ~SNES_ADDR[15])
     :(~SNES_ADDR[22] & SNES_ADDR[21] & SNES_ADDR[20] & SNES_ADDR[15])
    )
  :(MAPPER == 3'b100) ? 
   (~SNES_ADDR[22] & ~SNES_ADDR[21] & ~SNES_ADDR[20] & &SNES_ADDR[14:13]/* & CS */)
  :1'b0;
assign dspx_a0 = (MAPPER == 3'b101) ? SNES_ADDR[14]
                :(MAPPER == 3'b100) ? SNES_ADDR[12]
                :1'b1;

endmodule
