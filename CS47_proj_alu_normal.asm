.include "./cs47_proj_macro.asm"
.text
.globl au_normal
# TBD: Complete your project procedures
# Needed skeleton is given
#####################################################################
# Implement au_normal
# Argument:
# 	$a0: First number
#	$a1: Second number
#	$a2: operation code ('+':add, '-':sub, '*':mul, '/':div)
# Return:
#	$v0: ($a0+$a1) | ($a0-$a1) | ($a0*$a1):LO | ($a0 / $a1)
# 	$v1: ($a0 * $a1):HI | ($a0 % $a1)
# Notes:
#####################################################################
au_normal:
	addi $sp, $sp, -12
	sw $fp, 12($sp)
	sw $ra, 8($sp)
	addi $fp, $sp, 12

# TBD: Complete it
	li $v0, 0
	beq $a2, '+', addit
	beq $a2, '-', subt
	beq $a2, '*', multi
	beq $a2, '/', divis
addit: 
	add $v0, $a0, $a1
	j end
subt: 
	sub $v0, $a0, $a1
	j end
multi: 
	mult $a0, $a1
	mflo $v0
	mfhi $v1
	j end
divis: 
	div $a0, $a1
	mflo $v0
	mfhi $v1
end: 
	lw $fp, 12($sp)
	lw $ra, 8($sp)
	addi $sp, $sp, 12
	jr	$ra
