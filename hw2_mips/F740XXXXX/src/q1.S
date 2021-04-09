main:
    addi $a0, $zero, 19654 # a0= 19654
    addi $a1, $zero, 100654  # a1=100654
    addi $a2, $zero, 10065  # a2= 10065
    jal average     # call average
    j exit

average:
    addi $sp, $sp, -4	#sp : stack pointer 先到上一個空間，存ra原本的值
    sw $ra, 0x0($sp)    # Save $ra register into stack

    #--------------------------------------#
	addi $ra, $zero, 0		#ra = 0
	add $a0, $a0, $a1
	add $a0, $a0, $a2		#a0 =  a0 + a1 + a2
	loop:
		addi $a0, $a0, -3	#a0 = a0 - 3
		addi $ra, $ra, 1	#ra = ra + 1
		slti $a1, $a0, 3	#if(a0 < 3) a1 = 1; else a1 = 0;
		beq $a1, 0, loop	#if(a1 == 0) jump to loop
	addi $v0, $zero, 0
	add $v0, $ra, $zero
    #--------------------------------------#

    lw $ra, 0x0($sp)    # Load $ra register from stack
    addi $sp, $sp, 4	#ra原本的值存回後，sp回到的位置
    jr $ra				#一般是函数调用结束后，用于跳转到返回地址

exit:
