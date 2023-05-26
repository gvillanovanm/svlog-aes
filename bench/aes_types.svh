`ifndef AES_TYPES
`define AES_TYPES

typedef enum logic [4:0]{
    REGFILE_KEY0,
    REGFILE_KEY1,
    REGFILE_KEY2,
    REGFILE_KEY3,
    REGFILE_BLOCK0,
    REGFILE_BLOCK1,
    REGFILE_BLOCK2,
    REGFILE_BLOCK3,
    REGFILE_IV0,
    REGFILE_IV1,
    REGFILE_IV2,
    REGFILE_IV3,
    REGFILE_RESULT0,
    REGFILE_RESULT1,
    REGFILE_RESULT2,
    REGFILE_RESULT3,
    REGFILE_COUNTER0,
    REGFILE_COUNTER1,
    REGFILE_CONF,
    REGFILE_STATUS,
    REGFILE_FIRSTILEGAL,
    REGFILE_RANDOM
}ADDR_E;

localparam [31:0] MEMFILE_KEY0         = 32'h00;
localparam [31:0] MEMFILE_KEY1         = 32'h04;
localparam [31:0] MEMFILE_KEY2         = 32'h08;
localparam [31:0] MEMFILE_KEY3         = 32'h0C;
localparam [31:0] MEMFILE_BLOCK0       = 32'h10;
localparam [31:0] MEMFILE_BLOCK1       = 32'h14;
localparam [31:0] MEMFILE_BLOCK2       = 32'h18;
localparam [31:0] MEMFILE_BLOCK3       = 32'h1C;
localparam [31:0] MEMFILE_IV0          = 32'h20;
localparam [31:0] MEMFILE_IV1          = 32'h24;
localparam [31:0] MEMFILE_IV2          = 32'h28;
localparam [31:0] MEMFILE_IV3          = 32'h2C;
localparam [31:0] MEMFILE_RESULT0      = 32'h30;
localparam [31:0] MEMFILE_RESULT1      = 32'h34;
localparam [31:0] MEMFILE_RESULT2      = 32'h38;
localparam [31:0] MEMFILE_RESULT3      = 32'h3C;
localparam [31:0] MEMFILE_COUNTER0     = 32'h40;
localparam [31:0] MEMFILE_COUNTER1     = 32'h44;
localparam [31:0] MEMFILE_CONF         = 32'h48;
localparam [31:0] MEMFILE_STATUS       = 32'h4C;
localparam [31:0] MEMFILE_FIRSTILEGAL  = 32'h50;



logic [31:0] address_map[ADDR_E] = '{
    REGFILE_KEY0       : MEMFILE_KEY0,
    REGFILE_KEY1       : MEMFILE_KEY1,
    REGFILE_KEY2       : MEMFILE_KEY2,
    REGFILE_KEY3       : MEMFILE_KEY3,
    REGFILE_BLOCK0     : MEMFILE_BLOCK0,
    REGFILE_BLOCK1     : MEMFILE_BLOCK1,
    REGFILE_BLOCK2     : MEMFILE_BLOCK2,
    REGFILE_BLOCK3     : MEMFILE_BLOCK3,
    REGFILE_IV0        : MEMFILE_IV0,
    REGFILE_IV1        : MEMFILE_IV1,
    REGFILE_IV2        : MEMFILE_IV2,
    REGFILE_IV3        : MEMFILE_IV3,
    REGFILE_RESULT0    : MEMFILE_RESULT0,
    REGFILE_RESULT1    : MEMFILE_RESULT1,
    REGFILE_RESULT2    : MEMFILE_RESULT2,
    REGFILE_RESULT3    : MEMFILE_RESULT3,
    REGFILE_COUNTER0   : MEMFILE_COUNTER0,
    REGFILE_COUNTER1   : MEMFILE_COUNTER1,
    REGFILE_CONF       : MEMFILE_CONF,
    REGFILE_STATUS     : MEMFILE_STATUS,
    REGFILE_FIRSTILEGAL: MEMFILE_FIRSTILEGAL
};


localparam mode_high = 3'd5;
localparam mode_low = 2'd3;
localparam key_exp = 2'd2;
localparam decrypt = 1'd1;
localparam encrypt = 1'd0;
localparam DONE = 5'd31;

typedef enum logic [2:0]{
  ECB,
  CBC,
  PCBC,
  CFB,
  OFB,
  CTR,
  PCBC_RESERVED,
  CFB_RESERVED
} AES_MODES;

  `ifdef ALL
    parameter [2:0] COVER_MODE_LOW = ECB;
    parameter [2:0] COVER_MODE_HIGH = CTR;
    parameter CHANGE_MODE = 1'b1;
  `endif
  `ifdef ECB
    parameter [2:0] COVER_MODE_LOW = ECB;
    parameter [2:0] COVER_MODE_HIGH = ECB;
    parameter CHANGE_MODE = 1'b0;
  `endif
  `ifdef CBC
    parameter [2:0] COVER_MODE_LOW = CBC;
    parameter [2:0] COVER_MODE_HIGH = CBC;
    parameter CHANGE_MODE = 1'b0;
  `endif
  `ifdef PCBC
    parameter [2:0] COVER_MODE_LOW = PCBC;
    parameter [2:0] COVER_MODE_HIGH = PCBC;
    parameter CHANGE_MODE = 1'b0;
  `endif
  `ifdef CFB
    parameter [2:0] COVER_MODE_LOW = CFB;
    parameter [2:0] COVER_MODE_HIGH = CFB;
    parameter CHANGE_MODE = 1'b0;
  `endif
  `ifdef OFB
    parameter [2:0] COVER_MODE_LOW = OFB;
    parameter [2:0] COVER_MODE_HIGH = OFB;
    parameter CHANGE_MODE = 1'b0;
  `endif
  `ifdef CTR
    parameter [2:0] COVER_MODE_LOW = CTR;
    parameter [2:0] COVER_MODE_HIGH = CTR;
    parameter CHANGE_MODE = 1'b0;
  `endif
`endif
