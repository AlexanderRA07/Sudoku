# main.asm

# Main File of Sudoku Project
# Authors of Project: Alexander, Jeannnette, Moose, Miguel
# Author(s) of main.asm: Alexander
# CS2640.02 Assembly
# 5/16/2025

# This file is the core of the project, it will be the file which is executed to run the code. 
# This file uses macros stored in a seperate local file: macros.asm
# ============================================================================================



# grant access to macros
.include "macros.asm"

# declare global function
.globl main


.data
# declare the board as a global variable
.globl board
.globl solution

dif: .asciiz "What difficulty level do you want? Easy (1), Medium (2), Hard (3) "
type: .asciiz "Do you want a generated board (1) or a preset (2)? "
.align 2
board: .space 324
.align 2
solution: .space 324
debug: .asciiz "checkpoint\n" # for debugging purposes
wrong1: .asciiz "Wrong input, choose a value between "
wrong2: .asciiz " and "
enter: .asciiz "\n"


.text
main:
# print(debug)

# get difficulty
# What difficulty level do you want? Easy (1), Medium (2), Hard (3) 
print(dif)

# set boundaries
li $t0, 1
li $t1, 3

# get input
# print(debug)
jal getInt
move $s1, $s0


# branch to the correct preset filling
beq $s1, 1, easy
beq $s1, 2, medium
beq $s1, 3, hard

# Getting Prefrence is a scrapped idea, we wanted to be able to generate random boards
# get prefrence
# Do you want a generated board (1) or a preset (2)?
print(type)

# set boundaries
li $t0, 1
li $t1, 2

jal getInt
move $s2, $s0


# get boards
easy:
jal setEasy
j play

medium:
jal setMedium
j play

hard:
jal setHard
j play


# start playing the game
play:

# Present the User Board
# Gets User Input as s5, Row as s7, Column as s6
jal print_userBoard

# Update User Board
jal update_board

# If the solution is found, exit. Else, continue to play





# For Debuging, print solutions
#jal print_solutionBoard
exit




# Helper Functions
# takes an integer input from the user, checks that the input is between the bounds t0 < input < t1
getInt:
li $v0, 5
syscall
blt $v0, $t0, wrongInput
bgt $v0, $t1, wrongInput

move $s0, $v0
jr $ra

wrongInput:
print(wrong1)
printInt($t0)
print(wrong2)
printInt($t1)
print(enter)
j getInt
