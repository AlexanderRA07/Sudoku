# Fully working game I think

# SudokuBasic.asm
# Authors: Jeannette Ruiz
# CS 2640.02

# Print the board and menu
# Get user input and print the board with the updated value
# Check for a win
# ============================================================================================

.include "macros.asm"

.data
	# Menu
	title: 		.asciiz "---------- Sudoku in MIPS ----------\n\n"
  # No option yet, this is a test board
	option: 	.asciiz "[1] Start Game \n[2] Choose Difficulty \n[3]Quit\n"
	
	# Get Input
	option_choice: 	.asciiz "Enter choice: \n"
	row_value:	.asciiz "Enter row: "
	col_value:	.asciiz "Enter column: "
	cell_value:	.asciiz "Value: "
	
	# Valid input prompts
	invalid:	.asciiz "Your input is invalid, please enter a number from 1-9"
	taken: 		.asciiz "Cell is taken, select a cell that was not taken."
	
	# Check win prompts
	continueOrEnd:	.asciiz "The board is full, would you like to check for a win?\n[1] Yes\n[Any other number] Not yet. Continue Game\nEnter choice: "
	chickenDinner:	.asciiz "\nWINNER WINNER, CHICKEN DINNER BABY! YOU WON! Congratulations pa!"
	loser:		.asciiz "\nLoser Loser, microwave dinner... Disappointed in you!"
	
	solutionBoard:	.word 	4,3,5,2,6,9,7,8,1,
				6,8,2,5,7,1,4,9,3,
				1,9,7,8,3,4,5,6,2,
				8,2,6,1,9,5,3,4,7,
				3,7,4,6,8,2,9,1,5,
				9,5,1,7,4,3,6,2,8,
				5,1,9,3,2,6,8,7,4,
				2,4,8,9,5,7,1,3,6,
				7,6,3,4,1,8,2,5,9
	
	playingBoard:	.word 	4,3,5,2,6,9,7,8,1,
				6,8,2,5,7,1,4,9,3,
				1,9,7,8,3,4,5,6,2,
				8,2,6,1,9,5,3,4,7,
				3,7,4,6,8,2,9,1,5,
				9,5,1,7,4,3,6,2,8,
				5,1,9,3,2,6,0,7,4,
				2,4,8,9,5,7,1,0,6,
				7,6,3,4,1,8,2,5,0
	
	userBoard:	.word 	0,0,0,0,0,0,0,0,0,
				0,0,0,0,0,0,0,0,0,
				0,0,0,0,0,0,0,0,0,
				0,0,0,0,0,0,0,0,0,
				0,0,0,0,0,0,0,0,0,
				0,0,0,0,0,0,0,0,0,
				0,0,0,0,0,0,0,0,0,
				0,0,0,0,0,0,0,0,0,
				0,0,0,0,0,0,0,0,0
       			
       	# Symbols
       	row_seperator: 	.asciiz "------------+-------------+------------\n"
       	leftPara:	.asciiz "("
       	rightPara:	.asciiz ")"
       	pipe:		.asciiz "| "
       	space:		.asciiz " "
       	newline:	.asciiz "\n"
	dot:     	.asciiz "."
	underline:	.asciiz "_"

# Reference:
	# $t0 = index / counter
	# $t1 = cell count = 81
	# $t2 = base addr. of board
	# $t4 = cell number (value)
 
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
	la $t2, userBoard
	la $t4, playingBoard

	# ======================================================================
# COPY THE PLAYINGBOARD ONTO THE USERSBOARD 
copy_loop:
	# Once copying is finished, reset the counter and print board
	beq $t0, $t1, resetCounterandAddr
	
	# Copy num from playingBoard into userBoard
	lw $t5, 0($t4)	# playingBoard[[i]
	sw $t5, 0($t2)	# userBoard[i]
	
	# Go to next element
	addi $t4, $t4, 4
	addi $t2, $t2, 4
	
	#Incremenet counter
	addi $t0, $t0, 1
	
	j copy_loop

resetCounterandAddr:
	# Counter = 0
	li $t0, 0
	
	# Load the address of the board
	la $t2, userBoard
	la $t4, playingBoard
	
	j print_loop
	
# ======================================================================
# PRINT THE BOARD

print_loop:
	# Current cell value
	lw $t3, 0($t2)	# userBoard[i]
	lw $t5, 0($t4)	# playingBoard[[i]
	
	# If the cell is empty (0) print a underline
	beqz $t3, print_underline
	
	# If the cell user is in is a GIVEN cell, print a paranthesis
	bnez $t5, print_para
	
	printf(space)
	# Otherwise just print value (uerBoard)
	li $v0, 1
	move $a0, $t3
	syscall
	printf(space)
	
	# Next element
	add $t2, $t2, 4
	add $t4, $t4, 4
	
	# Check index and evaluate is we print a seperator
	j check_newline

print_para:
	printf(leftPara)
	printInt($t3)
	printf(rightPara)
	
	# Next element
	add $t2, $t2, 4
	add $t4, $t4, 4
	
	j check_newline
	
print_underline: 
	printf(space)
	li $v0, 4
	la $a0, underline
	syscall
	printf(space)
	
	# Next element
	add $t2, $t2, 4
	add $t4, $t4, 4
	
	j check_newline

print_pipe:
	printf(pipe)
	j print_loop

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

check_row_seperator:
	# If index = 81($t1), do not print the row separator at the bottom of the board
	beq $t0, $t1, get_input

	# Check if we're after the 3rd, 6th, 9th row, i.e., indices 27, 54
	# index % 27 == 0 means we're at a 3-row boundary (i.e., after 3, 6, 9... rows)
	li $t5, 27
	div $t0, $t5
	mfhi $t6
	bnez $t6, check_pipe	# If remainder is 0, it's a valid place for a separator

	# Otherwise, print row seperator
	printf(row_seperator)

	j print_loop

# ======================================================================
# GET USER INPUT

get_input:
#Reference:
#	$s0 = cell value
#	$s1 = row
#	$s2 = col
#	$s3 = array index of cell. element = (row * 9) + col
#	$s4 = base address of board

	#Prompt: Row #
	printf(row_value)
	li $v0, 5
	syscall
	move $s1, $v0
	#Check for valid input (1-9 = 0-8)
	subi $s1, $s1, 1
	bltz $s1, invalid_input
	bgt $s1, 8, invalid_input
	
	#Prompt: Column #
	printf(col_value)
	li $v0, 5
	syscall
	move $s2, $v0
	# Check for valid input (1-9 = 0-8)
	subi $s2, $s2, 1
	bltz $s2, invalid_input
	bgt $s2, 8, invalid_input
	
	# Prompt: Cell #
	printf(cell_value)
	li $v0, 5
	syscall
	move $s0, $v0
	# Check for valid input (1-9)
	blt $s0, 1, invalid_input
	bgt $s0, 9, invalid_input

	# Calculate Index: (row * 9) + col
	li $s3, 0		# Register to store index
	mul $s3, $s1, 9		# Store row * 9
	add $s3, $s3, $s2	# Add column
	mul $s3, $s3, 4		# Multiply index by 4 for .word values
	
	# Find the spot in array
	la $s4, userBoard	# Get base address of board
	add $s4, $s4, $s3	# Add the index ($s3)to the base address($s4) to get to users desired element.
	
	# Find spot in playingBoard to see if spot if a GIVEN value
	la $s5, playingBoard
	add $s5, $s5, $s3
	
	# If user seleced cell that is taken (cell != 0), reprompt
	lw $t7, 0($s5)
	bnez $t7, input_taken
	# OTHERWISE, Load value into userBoard
	sw $s0, 0($s4)
	
	j check_full_board
	
invalid_input:
	printf(invalid)
	j get_input

input_taken:
	printf(taken)
	j get_input

# ======================================================================
# CHECK WIN
check_full_board:
	# Counter
	li $t0, 0
	# User board
	la $t2, userBoard

check_loop:
	# If board is full of numbers, ask user if they are ready to submit
	beq $t0, 81, choice_continueOrEnd
	lw $t3, 0($t2)
	
	# If any cell is zero, it is not full, continue getting input
	beqz $t3, resetCounterandAddr
	
	# Move to next element
	addi $t2, $t2, 4
	#Increment Coutner
	addi $t0, $t0, 1
	
	j check_loop

choice_continueOrEnd:
	printf(continueOrEnd)
	getInput($s1)
	
	# 1 = checkWin, 2 = continueGame
	beq $s1, 1, checkWin
	
	# Any other num go to user input
	j get_input
	
checkWin:
	# Load counter
	li $t0, 0

	# Load addresses to COMPARE
	la $t2, userBoard
	la $t4, solutionBoard
	
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

# LMAOO YOU LOST
not_a_winner:
	printf(loser)
	j exit
	
# WINNER BABY
win:
	printf(chickenDinner)
	j exit

# ======================================================================
# EXIT PROGRAM

exit:
	exit
