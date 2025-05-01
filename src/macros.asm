# Authors: Alexander, Jeannnette, Moose, Miguel
# CS2640.02 Assembly
# 5/16/2025

# This file is the core of the project, it will be the file which is executed to run the code. 
# This file uses macros stored in a seperate local file: macros.asm
# ============================================================================================

.data 
wrong1: .asciiz "Wrong input, choose a value between "
wrong2: .asciiz " and "
enter: .asciiz "\n"

# Macros
# print a string arguement
.macro print(%str)
li $v0, 4
la $a0, %str
syscall
.end_macro

.macro printInt(%num)
li $v0, 1
la $a0, %num
syscall
.end_macro


# Loops
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
