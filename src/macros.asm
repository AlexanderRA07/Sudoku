# Authors: Alexander, Jeannnette, Moose, Miguel
# CS2640.02 Assembly
# 5/16/2025

# This file is the core of the project, it will be the file which is executed to run the code. 
# This file uses macros stored in a seperate local file: macros.asm
# ============================================================================================

.data 


# Macros
# print a string arguement
.macro print(%str)
li $v0, 4
la $a0, %str
syscall
.end_macro

# print an int
.macro printInt(%num)
li $v0, 1
move $a0, %num
syscall
.end_macro

# end program
.macro exit
la $v0, 10
syscall
.end_macro
