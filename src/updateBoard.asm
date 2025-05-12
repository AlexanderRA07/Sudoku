
.extern board 324

.globl update_board
.text
update_board:
# cell value: 	s5
# row: 		s7
# column:	s6
# index: 	t9	(row * 9) + col
# board base:	t2

lw $s7, 8($sp)      # $t2 = row
lw $s6, 4($sp)      # $t1 = column
lw $s5, 0($sp)      # $t0 = cell value

# Adjust stack pointer back to original (deallocate)
addi $sp, $sp, 12

# reduce row and column to valid numbers
subi $s7, $s7, 1
subi $s6, $s6, 1

# element = row * 9 + column
li $t3, 9
mul $t9, $s7, $t3
add $t9, $t9, $s6

# replace array element with user input 
la $t2, board		# load array
li $t3, 4
mul $t9, $t9, $t3	# multiply index by 4 for .word
add $t2, $t2, $t9	# add index to base address to get location of memory of node

sw $s5, 0($t2)		# store data

j return


return:
jr $ra


