# PrintBoard.asm
# Authors: Jeannette
# CS2640.02 Assembly

# Print Sudoku Board
# ============================================================================================

.data
	title: 		.asciiz "---------- Sudoku in MIPS ----------\n\n"
	
	board: 	.word 	5, 3, 0, 0, 7, 0, 0, 0, 0, 
			6, 0, 0, 1, 9, 5, 0, 0, 0,
			0, 9, 8, 0, 0, 0, 0, 6, 0,
       			8, 0, 0, 0, 6, 0, 0, 0, 3,
       			4, 0, 0, 8, 0, 3, 0, 0, 1,
       			7, 0, 0, 0, 2, 0, 0, 0, 6,
       			0, 6, 0, 0, 0, 0, 2, 8, 0,
       			0, 0, 0, 4, 1, 9, 0, 0, 5,
       			0, 0, 0, 0, 8, 0, 0, 7, 9
       	row_seperator: 	.asciiz "------+-------+------\n"
       	pipe:		.asciiz "| "
       	space:		.asciiz " "
       	newline:	.asciiz "\n"
	dot:     	.asciiz "."

# Reference:
	# $t0 = index / counter
	# $t1 = cell count = 81
	# $t2 = base addr. of board
	# $t3 = offset
	# $t4 = cell number (value)
	

# printf - Func. to print string
.macro printf(%str)
	li $v0, 4
	la $a0, %str
	syscall
.end_macro

# end program
.macro exit
	li $v0, 10
	syscall
.end_macro

.text
.globl main

main:
	# Print menu
	printf(title)
	
	# Create the index/counter. 0
	li $t0, 0
	
	# Total cells in board = 81
	li $t1, 81
	
	#Load the address of the board
	la $t2, board
	
# Print board
print_loop:

	# Get the current cell value from memory and load it into $t4
	lw $t4, 0($t2)	
	# Move to next element
	add $t2, $t2, 4 

	
	# If the cell value is equal to 0 (empty cell) Print a space
	beqz $t4, print_dot
	
	# Otherwise just print the value($t4)
	li $v0, 1
	move $a0, $t4
	syscall
	
	# Check index and evaluate is we print a seperator
	j check_newline
	
print_dot: 
	li $v0, 4
	la $a0, dot
	syscall
	
	j check_newline

print_pipe:
	printf(pipe)
	j print_loop

check_pipe:	
	# If we are at begining of row, do not print pipe.
	# 
	li $t5, 9
    	div $t0, $t5
    	mfhi $t6
    	beqz  $t6, print_loop
	# If index/3 != 0, then check for newline
	li $t5, 3
    	div $t0, $t5
    	mfhi $t6
    	bnez $t6, print_loop
	
	#Otherise, print the next value
	j print_pipe

check_newline:
	# Print space for clean look
	printf(space)
	
	# Increment the counter
	addi $t0, $t0, 1  
	
	# Print a newline after 9 numbers to move to the next row
	li $t5, 9
    	div $t0, $t5
    	mfhi $t6
    	#If index/9 != 0, check for pipe
	bnez $t6, check_pipe
	
	# Otherwise, print newline and return to printing values
	printf(newline)
	
	j check_row_seperator

check_row_seperator:
	#if index = 81($t1), end program
	beq $t0, $t1, exit
	
	#If index/27 != 0, check for newline
	li $t5, 27
    	div $t0, $t5
    	mfhi $t6
	bnez $t6, check_pipe
	
	# Otherwise, print row seperator
	printf(row_seperator)
	
	j print_loop
	
exit:
	exit
