# Main File of Sudoku Project
# Authors: Alexander, Jeannnette, Moose, _
# CS2640.02 Assembly
# 5/16/2025

# This file is the core of the project, it will be the file which is executed to run the code. 
# This file uses macros stored in a seperate local file: macros.asm
# ============================================================================================

.include macros.asm

.data
dif: .asciiz "What difficulty level do you want? Easy (1), Medium (2), Hard (3) "
type: .asciiz "Do you want a generated board (1) or a preset (2)? "


.text
main:

# get difficulty
# What difficulty level do you want? Easy (1), Medium (2), Hard (3) 
print(dif)

# set boundaries
li $t0, 1
li $t1, 3

# get input
jal getInt
move $s1, $s0


# get prefrence
# Do you want a generated board (1) or a preset (2)?
print(type)

# set boundaries
li $t0, 1
li $t1, 2

jal getInt
move $s2, $s0

