# CS 2640 - 12pm
# Final Project - Sudoku in MIPS

# Tasks:
#	[X}: Print Board
#	[X}: Get user input


.data
	title: 		.asciiz "---------- Sudoku in MIPS ----------\n\n"
	option: 	.asciiz "[1] Start Game \n[2] Choose Difficulty \n[3]Quit\n"
	option_choice: 	.asciiz "Enter choice: \n"
	row_value:	.asciiz "Enter row: "
	col_value:	.asciiz "Enter column: "
	cell_value:	.asciiz "Value: "
	taken: 		.asciiz "Cell is taken, select a cell that was not taken."
	
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
	printf(option)
	printf(newline)
	
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
	#if index = 81($t1), end program to not get row seperator at bottom of board
	beq $t0, $t1, user_input
	
	#If index/27 != 0, check for newline
	li $t5, 27
    	div $t0, $t5
    	mfhi $t6
	bnez $t6, check_pipe
	
	# Otherwise, print row seperator
	printf(row_seperator)
	
	j print_loop

input_taken: 
	printf(taken)
	j user_input

user_input:
#Reference:
#	$s0 = cell value
#	$s1 = row
#	$s2 = col
#	$s3 = array index of cell. element = (row * 9) + col
#	$s4 = base address of board

	printf(row_value)
	li $v0, 5
	syscall
	move $s1, $v0
	printf(col_value)
	li $v0, 5
	syscall
	move $s2, $v0
	printf(cell_value)
	li $v0, 5
	syscall
	move $s0, $v0
	
	#Subtract 1 from both
	subi $s1, $s1, 1
	subi $s2, $s2, 1
	
	#lement = (row * 9) + col
	li $s3, 0		# Register to store index
	mul $s3, $s1, 9		# Store row * 9
	add $s3, $s3, $s2	# Add col
	
	#Now replace array element with user input
	la $s4, board		# Get base address of board
	mul $s3, $s3, 4		# Multiply index by 4 for .word values
	add $s4, $s4, $s3	# Add the index ($s3)to the base address($s4) to get to users desired element.
	
	# If user seleced cell that is taken (cell != 0), reprompt
	lw $t7, 0($s4)
	bnez $t7, input_taken
	
	sw $s0, 0($s4)	# Load the users value into desired cell.
	
	# Since the counter and base addres is on last element, we need to reset both values.
	li $t0, 0	# Reset counter

	la $t2, board	# Load address of board from beginning
	
	j print_loop

	exit
