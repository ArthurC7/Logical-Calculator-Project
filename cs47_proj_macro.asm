# Add you macro definition here - do not touch cs47_common_macro.asm"
#<------------------ MACRO DEFINITIONS ---------------------->#

#regD: register that will contain the bit
#regS: Source register
#regT: register position
.macro extract_nth_bit($regD, $regS, $regT)
	srlv $t0, $regS, $regT
	andi $regD, $t0, 1
.end_macro

#regD: source register and result 
#regS: position to insert the bit into 
#regT: register that contains the 1 or 0 in insert
#maskReg: The mask that isolates the bit
.macro insert_to_nth_bit ($regD, $regS, $regT, $maskReg)
	li $t0, 1
	sllv $t0, $t0, $regS
	xori $maskReg, $t0, -1
	and $regD, $regD, $maskReg
	sllv $regT, $regT, $regS
	or $regD, $regD, $regT
.end_macro

.macro store_frame()
addi $sp, $sp, -60
sw $fp, 60($sp)
sw $ra, 56($sp)
sw $a0, 52($sp)
sw $a1, 48($sp)
sw $a2, 44($sp)
sw $a3, 40($sp)
sw $s0, 36($sp)
sw $s1, 32($sp)
sw $s2, 28($sp)
sw $s3, 24($sp)
sw $s4, 20($sp)
sw $s5, 16($sp)
sw $s6, 12($sp)
sw $s7, 8($sp)
addi $fp, $sp, 60
.end_macro

.macro restore_frame()
lw $fp, 60($sp)
lw $ra, 56($sp)
lw $a0, 52($sp)
lw $a1, 48($sp)
lw $a2, 44($sp)
lw $a3, 40($sp)
lw $s0, 36($sp)
lw $s1, 32($sp)
lw $s2, 28($sp)
lw $s3, 24($sp)
lw $s4, 20($sp)
lw $s5, 16($sp)
lw $s6, 12($sp)
lw $s7, 8($sp)
addi $sp, $sp, 60
jr $ra
.end_macro
	


