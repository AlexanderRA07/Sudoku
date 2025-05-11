# presets.asm

# Board Storage File of Sudoku Project
# Authors of Project: Alexander, Jeannnette, Moose, Miguel
# Author(s) of presets.asm: Alexander
# CS2640.02 Assembly
# 5/16/2025

# This file holds three base presets, one for easy, medium, and hard.
# 0 denotes an 'empty' space, this will be converted into _ when printing
# ============================================================================================


# access external refrences
.extern board 324
.extern solution 324


# return macro, just for visual apeal of code
.macro return
jr $ra
.end_macro

.data
# 'board' is the true, solutions resource
# 'user' is the board provided to the player
# easy
.align 2
easyBoard: .word 6,5,2, 7,3,1, 9,8,4
		 3,9,7, 4,5,8, 1,2,6,
		 4,1,8, 6,9,2, 3,7,5,
		 
		 5,2,4, 1,8,9, 7,6,3,
		 9,8,6, 3,4,7, 5,1,2,
		 7,3,1, 5,2,6, 4,9,8,
		 
		 2,4,9, 8,1,5, 6,3,7,
		 8,6,3, 9,7,4, 2,5,1,
		 1,7,5, 2,6,3, 8,4,9


.align 2
easyUser:  .word 6,5,2, 7,3,0, 9,8,4
		 3,0,0, 0,0,8, 0,0,6,
		 0,1,8, 0,9,2, 0,0,0,
		 
		 5,2,4, 1,0,9, 7,6,3,
		 0,8,6, 0,4,0, 5,1,0,
		 7,0,1, 0,2,6, 4,9,8,
		 
		 2,4,0, 0,0,0, 6,3,7,
		 8,0,0, 0,7,4, 0,5,0,
		 0,7,0, 2,6,3, 8,4,0

# medium
.align 2
mediumBoard: .word 5,1,9, 8,7,6, 4,2,3,
		   2,6,3, 1,4,5, 8,7,9,
		   4,7,8, 9,2,3, 6,5,1,
		   
		   8,5,7, 3,1,2, 9,4,6,
		   3,4,6, 7,5,9, 1,8,2,
		   9,2,1, 6,8,4, 5,3,7,
		   
		   6,8,2, 5,9,7, 3,1,4,
		   7,3,5, 4,6,1, 2,9,8,
		   1,9,4, 2,3,8, 7,6,5


.align 2
mediumUser:  .word 5,0,0, 8,0,0, 4,2,0,
		   0,6,0, 0,0,5, 0,0,9,
		   0,7,0, 0,2,0, 6,0,0,
		   
		   0,0,7, 0,0,0, 0,0,6,
		   0,4,6, 0,0,0, 1,8,0,
		   9,0,0, 0,0,0, 5,0,0,
		   
		   0,0,2, 0,9,0, 0,1,0,
		   7,0,0, 4,0,0, 0,9,0,
		   0,9,4, 0,0,8, 0,0,5
		   
		   
# hard
.align 2
hardUser: .word  0,0,0, 7,0,0, 0,6,9, 
		 8,5,0, 0,0,0, 0,0,0,
		 0,0,0, 0,0,0, 0,0,0,
		 
		 4,0,0, 0,0,8, 5,0,0,
		 9,0,0, 0,3,0, 0,0,0,
		 0,0,6, 0,0,0, 0,7,0,
		 
		 0,8,0, 0,0,0, 2,0,0,
		 0,0,0, 6,4,0, 0,0,0,
		 0,0,0, 9,0,0, 0,0,0
		 
	
.align 2	 
hardBoard: .word 2,4,1, 7,5,3, 8,6,9,
		 8,5,7, 2,9,6, 4,3,1
		 6,9,3, 8,1,4, 7,5,2,
		
	 	 4,7,2, 1,6,8, 5,9,3,
		 9,1,8, 5,3,7, 6,2,4,
		 5,3,6, 4,2,9, 1,7,8,
		
		 1,8,9, 3,7,5, 2,4,6,
		 3,2,5, 6,4,1, 9,8,7,
		 7,6,4, 9,8,2, 3,1,5


.text
# decalres the assignments as global
.globl setEasy
.globl setMedium
.globl setHard

setEasy:
# load boards and global equivalents
la $t1, easyBoard
la $t2, solution

la $t6, easyUser
la $t7, board
j copy 

return

setMedium:
# load boards and global equivalents
la $t1, mediumBoard
la $t2, solution

la $t6, mediumUser
la $t7, board
j copy 

return

setHard:
# load boards and global equivalents
la $t1, hardBoard
la $t2, solution

la $t6, hardUser
la $t7, board
j copy 

return


# copies the array in t1 into t2 and t6 into t7
copy:
li $t3, 0 #counter
li $t4, 81 #total

copy_loop:
lw $t5, 0($t1)
lw $t8, 0($t6)

sw $t5, 0($t2)
sw $t8, 0($t7)

addi $t1, $t1, 4 # increment source solution
addi $t2, $t2, 4 # increment destination solution

addi $t6, $t6, 4 # increment source board
addi $t7, $t7, 4 # increment destination board

addi $t3, $t3, 1 # increment counter
blt $t3, $t4, copy_loop
return
