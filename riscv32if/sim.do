vlib work
vlog Single_Cycle.v
vsim -voptargs="+acc" work.tb_top
add wave -position insertpoint sim:/tb_top/uut/PC/*
add wave -position insertpoint sim:/tb_top/uut/Inst_Memory/*
add wave -position insertpoint sim:/tb_top/uut/Reg_File/*
add wave -position insertpoint sim:/tb_top/uut/ImmGen/*