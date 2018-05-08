.include "./cs47_proj_macro.asm"
.text
.globl au_logical
# TBD: Complete your project procedures
# Needed skeleton is given
#####################################################################
# Implement au_logical
# Argument:
# 	$a0: First number
#	$a1: Second number
#	$a2: operation code ('+':add, '-':sub, '*':mul, '/':div)
# Return:
#	$v0: ($a0+$a1) | ($a0-$a1) | ($a0*$a1):LO | ($a0 / $a1)
# 	$v1: ($a0 * $a1):HI | ($a0 % $a1)
# Notes:
#####################################################################
au_logical:
	store_frame()

# TBD: Complete it
	li $v0, 0
	
	
	beq $a2, '+', addit
	beq $a2, '-', subt
	beq $a2, '*', multi
	beq $a2, '/', divis
addit: 
	jal add_sub_logical
	j end
subt: 
	move $t0, $a0
	move $a0, $a1
	jal twos_compliment
	move $a1, $v0
	move $a0, $t0
	jal add_sub_logical
	j end
multi: 
	jal mul_signed
	j end
divis: 
	jal div_signed
end: 
	restore_frame()

add_sub_logical: 
	li $s0, 0
	li $s1, 0
	li $s2, 0
#make the RTE: 7 * 4 = 28 bytes
#s0 = index, s1 = result address, s2 = carryover value
	addi $sp, $sp, -12
	sw $fp, 12($sp)
	sw $ra, 8($sp)
	addi $fp, $sp, 12
	
add_loop:
	beq $s0, 32, add_end

	extract_nth_bit($t1, $a0, $s0) #$t1 = A
	extract_nth_bit($t2, $a1, $s0) #t2 = B
	
	xor $t3, $t1, $t2 # A (+) B
	and $t4, $t1, $t2 # A.B
	xor $t1, $t3, $s2 # Ci (+) A (+) B
	and $t2, $s2, $t3 # Ci.(A(+)B)
	or $s2, $t2, $t4

loop_end: 
	insert_to_nth_bit($s1, $s0, $t1, $t9)
	addi $s0, $s0, 1
	j add_loop
add_end: 
	move $v0, $s1
	move $v1, $t3
	beq $s7, 1, ex_end 
restore_rte:
#restore the RTE
	lw $fp, 12($sp)
	lw $ra, 8($sp)
	addi $sp, $sp, 12
ex_end:
	jr $ra


twos_compliment:
	addi $sp, $sp, -16
	sw $fp, 16($sp)
	sw $ra, 12($sp)
	sw $t0, 8($sp)
	addi $fp, $sp, 16

	xori $a0, $a0, -1
	li $a1, 1
	jal add_sub_logical

	lw $fp, 16($sp)
	lw $ra, 12($sp)
	lw $t0, 8($sp)
	addi $sp, $sp, 16
	jr	$ra
	
twos_compliment_if_neg: 
	bge $a0, $zero, not_neg
	j twos_compliment
not_neg: 	
	move $v0, $a0
	jr $ra

twos_complement_64bit: 
	addi $sp, $sp, -12
	sw $fp, 12($sp)
	sw $ra, 8($sp)
	addi $fp, $sp, 12
	
	# both arguments are inverted
	xori $a0, $a0, -1
	xori $a1, $a1, -1
	move $t8, $a1 # contents of $a1 are moved to $t8 since it needs to be used for add_sub_logical
	li $a1, 1
	jal add_sub_logical
	move $t7, $v0
	move $a1, $v1
	move $a0, $t8
	jal add_sub_logical #add the carryover to the second argument 
	move $v1, $v0
	move $v0, $t7
	
	lw $fp, 12($sp)
	lw $ra, 8($sp)
	addi $sp, $sp, 12
	jr	$ra
	
bit_replicator: 
	addi $sp, $sp, -12
	sw $fp, 12($sp)
	sw $ra, 8($sp)
	addi $fp, $sp, 12
	
	beq $a0, 1, repl_1
	li $v0, 0
	j rep_end
repl_1: 
	li $v0, 0xFFFFFFFF
rep_end: 
	lw $fp, 12($sp)
	lw $ra, 8($sp)
	addi $sp, $sp, 12
	jr	$ra

mul_unsigned: 
	li $s3, 0
	li $s4, 0
	move $t5, $a0
	move $t6, $a1
#s3 = index, $s4 = H, $a1 = L, $a0 = M
	addi $sp, $sp, -12
	sw $fp, 12($sp)
	sw $ra, 8($sp)
	addi $fp, $sp, 12
mul_loop: 
	beq $s3, 32, mul_end
	
	extract_nth_bit($a0, $t5, $zero)#the bit to replicate 
	jal bit_replicator
	and $t2, $t5, $v0
	move $a0, $s4
	move $a1, $t2
	
	jal add_sub_logical
	move $s4, $v0
	
	
	srl $t6, $t6, 1
	extract_nth_bit($t7, $s4, $zero)
	li $t8, 31
	insert_to_nth_bit($t6, $t8, $t7, $t9)
	
	srl $s4, $s4, 1
	addi $s3, $s3, 1
	j mul_loop
mul_end: 
	move $v0, $t6
	move $v1, $s4
	lw $fp, 12($sp)
	lw $ra, 8($sp)
	addi $sp, $sp, 12
	jr $ra
	
	
mul_signed: 
	addi $sp, $sp, -12
	sw $fp, 12($sp)
	sw $ra, 8($sp)
	addi $fp, $sp, 12
	
	move $a3, $a1
	jal twos_compliment_if_neg
	move $t5, $v0
	move $a0, $a3
	jal twos_compliment_if_neg
	move $a1, $v0
	move $a0, $t5
	jal mul_unsigned
	
	li $t1, 31
	extract_nth_bit($t2, $a0, $t1)
	extract_nth_bit($t3, $a1, $t1)
	xor $t4, $t3, $t2
	bne $t4, 1, muls_end
	
	move $a0, $v0
	move $a1, $v1
	jal twos_complement_64bit
	move $v0, $a1
	move $v1, $s1
muls_end: 
	lw $fp, 12($sp)
	lw $ra, 8($sp)
	addi $sp, $sp, 12
	jr $ra

div_unsigned: 
#$a0 = dividend, $a1 = divisor, $s3 = index, $s4 = remainder
	addi $sp, $sp, -12
	sw $fp, 12($sp)
	sw $ra, 8($sp)
	addi $fp, $sp, 12
	
	beq $s3, 32, div_end
	
	srl $s4, $s4, 1
	li $t1, 31
	extract_nth_bit($t1, $a0, $t1)
	insert_to_nth_bit($s4, $zero, $t1,$t9)
	sll $a0, $a0, 1
	
	#setup for subtraction
	move $t5, $a0
	xori $a1, $a1, -1
	addi $s2, $s2, 1
	move $a0, $s4
	jal add_sub_logical
	xori $a1, $a1, -1
	
	move $t1, $v0
	blt $t1, $zero, div_else
	move $s4, $t1
	li $t1, 1
	insert_to_nth_bit($a0, $zero, $t1,$t9)
div_else:
	addi $s3, $s3, 1
	jal div_unsigned
div_end: 
	move $v0, $a0
	move $v1, $s4
	lw $fp, 12($sp)
	lw $ra, 8($sp)
	addi $sp, $sp, 12
	jr $ra
	
div_signed: 
	addi $sp, $sp, -12
	sw $fp, 12($sp)
	sw $ra, 8($sp)
	addi $fp, $sp, 12
	
	move $a3, $a1
	jal twos_compliment_if_neg
	move $t5, $v0
	move $a0, $a3
	jal twos_compliment_if_neg
	move $a1, $v0
	move $a0, $t5
	
	jal div_unsigned
	li $t1, 31
	extract_nth_bit($t2, $a0, $t1)
	extract_nth_bit($t3, $a1, $t1)
	
	xor $t1, $t2, $t3
	bne $t1, 1, test2
	move $a0, $v0
	jal twos_compliment
	move $t3, $v0
test2: 
	bne $t2, 1, divs_end
	move $a0, $v1
	jal twos_compliment
	move $v1, $v0
	move $v0, $t3
divs_end:
	lw $fp, 12($sp)
	lw $ra, 8($sp)
	addi $sp, $sp, 12
	jr $ra
