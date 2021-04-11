main:
    addi $a0, $zero, 10 # n = 10
    addi $a1, $zero, 5  # m = 5
    jal pascal          # call pascal(10, 5)
    j exit
pascal:
    addi $sp, $sp, -16
    sw $ra, 0x0($sp)    # Save $ra register into stack
    sw $s0, 0x4($sp)	# Save $s0 register into stack
    sw $a0, 0x8($sp)	# Save $a0 register into stack
    sw $a1, 0xc($sp)	# Save $a1 register into stack
	#  \^o^/   Write your code here~  \^o^/#
    beq $a0, $a1, L1
    beq $a1, $zero, L1
    
	addi $a0, $a0, -1	
	jal pascal
	lw $s0, 0x4($sp)
	add $s0, $v0, $zero
	sw $s0, 0x4($sp)
	addi $a1, $a1, -1
	jal pascal
    #--------------------------------------#
    lw $ra, 0x0($sp)    # Load $ra register from stack
    lw $s0, 0x4($sp)	# Load $s0 register from stack
    lw $a0, 0x8($sp)	# Load $a0 register from stack
    lw $a1, 0xc($sp)	# Load $a1 register from stack
    addi $sp, $sp, 16
    add $v0, $v0, $s0
    jr $ra
L1:
    addi $v0, $zero, 1
    addi $sp, $sp, 16
    jr $ra
exit:




