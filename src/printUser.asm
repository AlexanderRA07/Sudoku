# printUser.asm

# Print Board File of Sudoku Project
# Authors of Project: Alexander, Jeannnette, Moose, Miguel
# Author(s) of main.asm: Jeannette, Alexander
# CS2640.02 Assembly
# 5/16/2025

# This file prints the user board, and accepts user inputs to update the board.
# ============================================================================================

# pull global boards
.extern board 324


.data
	title:         .asciiz "---------- Sudoku in MIPS ----------\n\n"
	row_value:     .asciiz "Enter row: \n"
	col_value:     .asciiz "Enter column: \n"
	cell_value:    .asciiz "Value: \n"
	row_seperator: .asciiz "------+-------+------\n"
	pipe:          .asciiz "| "
	space:         .asciiz " "
	newline:       .asciiz "\n"
	dot:           .asciiz "_"
	wrong1: .asciiz "Wrong input, choose a value between "
	wrong2: .asciiz " and "

.text
.globl print_userBoard

print_userBoard:
	# Print title
	li $v0, 4
	la $a0, title
	syscall
	
	# Load board address
	la $s0, board
	
	# Initialize row and column counters
	li $s1, 0    # row counter (0-8)
	
	j print_row_loop
	
	
print_row_loop:
	# Check if we've printed all rows
	li $t0, 9
	beq $s1, $t0, print_done
	
	# Initialize column counter for this row
	li $s2, 0    # column counter (0-8)
	
print_col_loop:
	# Check if we've printed all columns in this row
	li $t0, 9
	beq $s2, $t0, end_row
	
	# Calculate offset: (row * 9 + col) * 4
	mul $t0, $s1, 9    # row * 9
	add $t0, $t0, $s2  # + col
	sll $t0, $t0, 2    # * 4 (for word size)
	
	# Load value from board[row][col]
	add $t1, $s0, $t0
	lw $t2, 0($t1)
	
	# If value is 0, print dot/asterisk
	beqz $t2, print_empty
	
	# Print the number
	li $v0, 1
	move $a0, $t2
	syscall
	j after_print
	
print_empty:
	# Print dot/asterisk
	li $v0, 4
	la $a0, dot
	syscall
	
after_print:
	# Print space
	li $v0, 4
	la $a0, space
	syscall
	
	# Check if we need to print a pipe (after columns 2 and 5)
	li $t0, 2
	beq $s2, $t0, print_col_pipe
	li $t0, 5
	beq $s2, $t0, print_col_pipe
	j next_col
	
print_col_pipe:
	# Print pipe
	li $v0, 4
	la $a0, pipe
	syscall
	
next_col:
	# Increment column counter
	addi $s2, $s2, 1
	j print_col_loop
	
end_row:
	# Print newline
	li $v0, 4
	la $a0, newline
	syscall
	
	# Check if we need to print row separator (after rows 2 and 5)
	li $t0, 2
	beq $s1, $t0, print_row_sep
	li $t0, 5
	beq $s1, $t0, print_row_sep
	j next_row
	
print_row_sep:
	# Print row separator
	li $v0, 4
	la $a0, row_seperator
	syscall
	
next_row:
	# Increment row counter
	addi $s1, $s1, 1
	j print_row_loop
	
print_done:
	# Print prompts for user input, then stores input
	li $v0, 4
	la $a0, row_value
	syscall
	
	# get row
	j getRow
	backRow:
	
	move $s7, $s0
	
	li $v0, 4
	la $a0, col_value
	syscall
	
	# get column
	j getCol
	backCol:
	
	move $s6, $s0
	
	li $v0, 4
	la $a0, cell_value
	syscall
	
	# get response
	j getInp
	backInp:
	
	move $s5, $s0
	
	# Return to caller
	jr $ra
	
wrongInput:
	# "Wrong input, enter a value betnwee X and Y"
	li $v0, 4
	la $a0, wrong1
	syscall
	
	li $v0, 1
	move $a0, $t0
	syscall
	
	li $v0, 4
	la $a0, wrong2
	syscall
	
	li $v0, 1
	move $a0, $t1
	syscall
	
	li $v0, 4
	la $a0, newline
	syscall
	
	# return to user input function
	j print_done
	
getRow:
	# set boundaries
	li $t0, 1
	li $t1, 9

	# get number
	li $v0, 5
	syscall
	blt $v0, $t0, wrongInput
	bgt $v0, $t1, wrongInput

	move $s0, $v0
	j backRow
	
getCol:
	# set boundaries
	li $t0, 1
	li $t1, 9

	# get number
	li $v0, 5
	syscall
	blt $v0, $t0, wrongInput
	bgt $v0, $t1, wrongInput

	move $s0, $v0
	j backCol
	
getInp:
	# set boundaries
	li $t0, 1
	li $t1, 9

	# get number
	li $v0, 5
	syscall
	blt $v0, $t0, wrongInput
	bgt $v0, $t1, wrongInput

	move $s0, $v0
	j backInp
