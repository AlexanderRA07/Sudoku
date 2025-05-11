# Simplified Sudoku Board Printing Function
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
	dot:           .asciiz "*"

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
	# Print prompts for user input
	li $v0, 4
	la $a0, row_value
	syscall
	
	li $v0, 4
	la $a0, col_value
	syscall
	
	li $v0, 4
	la $a0, cell_value
	syscall
	
	# Return to caller
	jr $ra