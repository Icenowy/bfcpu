/*
 * STATE_IF_REQ: Send REQ for I Bus, prepare for fetch instruction (-> STATE_IF_WAIT)
 * STATE_IF_WAIT: Wait for instruction to be feed (-> STATE_IF_ACK if I_ACK)
 * STATE_IF_ACK: Received ACK on I Bus (-> STATE_INSTR_DECODE)
 * STATE_DATA_R_REQ: Send REQ for D Bus, prepare for read data (-> STATE_DATA_R_REQ)
 * STATE_DATA_R_WAIT: Wait for data to be feed (-> STATE_DATA_R_ACK if D_ACK)
 * STATE_DATA_R_ACK: Received ACK on D Bus
 * STATE_DATA_W_REQ: Send REQ for D Bus, prepare for write data (-> STATE_DATA_W_REQ)
 * STATE_DATA_W_WAIT: Wait for data to be accepted (-> STATE_DATA_W_ACK if D_ACK)
 * STATE_DATA_W_ACK: Received ACK on D Bus
 * STATE_IO_R_REQ: Send REQ for IO Bus (-> STATE_IO_R_WAIT)
 * STATE_IO_R_WAIT: Wait for IO data to be feed (-> STATE_IO_R_ACK if IO_ACK)
 * STATE_IO_R_ACK: Received ACK on IO Bus
 * STATE_IO_W_REQ: Send REQ for IO Bus (-> STATE_IO_W_WAIT)
 * STATE_IO_W_WAIT: Wait for IO data to be accepted (-> STATE_IO_W_ACK if IO_ACK)
 * STATE_IO_W_ACK: Received ACK on IO Bus
 * STATE_START: The state that is put at reset
 * STATE_INSTR_DECODE: Decode the instruction
 * STATE_DP_EX: Execution for data pointer increase/decrease
 * STATE_D_EX: Execution for data increase/decrease
 * STATE_LOOP_START_EX: Execution for loop start
 * STATE_LOOP_END_EX: Execution for loop end
 */
`define STATES_IF		6'b001000
`define STATE_IF_REQ		6'b001000
`define STATE_IF_WAIT		6'b001001
`define STATE_IF_ACK		6'b001010
`define STATES_DATA		6'b010000
`define STATES_DATA_R		6'b010000
`define STATE_DATA_R_REQ	6'b010000
`define STATE_DATA_R_WAIT	6'b010001
`define STATE_DATA_R_ACK	6'b010010
`define STATES_DATA_W		6'b010100
`define STATE_DATA_W_REQ	6'b010100
`define STATE_DATA_W_WAIT	6'b010101
`define STATE_DATA_W_ACK	6'b010110
`define STATES_IO		6'b100000
`define STATES_IO_R		6'b100000
`define STATE_IO_R_REQ		6'b100000
`define STATE_IO_R_WAIT		6'b100001
`define STATE_IO_R_ACK		6'b100010
`define STATES_IO_W		6'b100100
`define STATE_IO_W_REQ		6'b100100
`define STATE_IO_W_WAIT		6'b100101
`define STATE_IO_W_ACK		6'b100110
`define STATE_START		6'b000000
`define STATE_INSTR_DECODE	6'b000001
`define STATE_DP_EX		6'b000010
`define STATE_D_EX		6'b000011
`define STATE_LOOP_START_EX	6'b000100
`define STATE_LOOP_END_EX	6'b000101
