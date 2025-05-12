.extern board 324
.extern solution 324
.globl victory

.text
victory:

checkWin:
	# Load counter
	li $t0, 0

	# Load addresses to COMPARE
	la $t2, board
	#Debug line:
	# la $t2, solution
	la $t4, solution
	
checkWin_loop:
	# If we find no mismatches, WINNER WINNER CHICKEN DINNER!
	beq $t0, 81, win
	
	lw $t3, 0($t2)	# UserBoard
	lw $t5, 0($t4)	# SolutionBoard
	
	# If not equal, LOSER
	bne $t3, $t5, not_a_winner
	
	# Move to next element
	addi $t2, $t2, 4
	addi $t4, $t4, 4
	
	# Incrememt Counter
	addi $t0, $t0, 1
	
	j checkWin_loop
	
	
	
win:
	li $s4, 1
	j return 


not_a_winner:
	li $s4, 0
	j return

return:
	jr $ra
