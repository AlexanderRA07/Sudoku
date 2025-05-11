# macros.asm

# Secondary File of Sudoku Project
# Authors of Project: Alexander, Jeannnette, Moose, Miguel
# Author(s) of macros.asm: Alexander
# CS2640.02 Assembly
# 5/16/2025

# This file holds helper macros for the main.asm
# ============================================================================================

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
