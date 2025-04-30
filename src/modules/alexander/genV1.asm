# MIPS Sudoku Generator (Simplified)
# MARS simulator compatible
# This version creates a partially-filled 9x9 grid with random numbers that
# don't repeat in rows. No full Sudoku solving logic (e.g., backtracking) is included.

.data
grid:         .space 324          # 9x9 integers = 81 * 4 = 324 bytes
newline:      .asciiz "\n"
tab:          .asciiz "\t"
seed:         .word 12345         # initial seed for RNG

.text
.globl main

main:
    # Initialize random seed
    li $t0, 12345
    sw $t0, seed

    # Fill each row with random values 1–9 without duplicates
    li $t1, 0                  # row index (0–8)
fill_rows:
    li $t2, 0                  # col index
    move $t3, $t1              # store row in $t3
    sll $t4, $t1, 5            # $t4 = row * 9 * 4 = row * 36
    li $t5, 0                  # reset seen mask

fill_cols:
    # Generate random number between 1–9
    jal rand_1_to_9
    move $t6, $v0              # $t6 = random number

    # Check if number already seen in this row
    li $t7, 1
    sllv $t7, $t7, $t6         # shift mask to bit rand_num
    and $t8, $t5, $t7
    bne $t8, $zero, fill_cols  # already used

    # Mark number as seen
    or $t5, $t5, $t7

    # Calculate offset = (row * 9 + col) * 4
    mul $t9, $t3, 9
    add $t9, $t9, $t2
    sll $t9, $t9, 2

    # Store random number at grid[offset]
    la $a0, grid
    add $a0, $a0, $t9
    sw $t6, 0($a0)

    # Increment column
    addi $t2, $t2, 1
    li $t0, 9
    blt $t2, $t0, fill_cols

    # Next row
    addi $t1, $t1, 1
    li $t0, 9
    blt $t1, $t0, fill_rows

    # Print the grid
    jal print_grid

    li $v0, 10                 # Exit
    syscall

########################################################
# print_grid: prints the 9x9 Sudoku grid
########################################################
print_grid:
    li $t1, 0                  # row index
pg_row:
    li $t2, 0                  # col index
pg_col:
    # Get offset = (row * 9 + col) * 4
    mul $t3, $t1, 9
    add $t3, $t3, $t2
    sll $t3, $t3, 2
    la $t4, grid
    add $t4, $t4, $t3
    lw $a0, 0($t4)

    li $v0, 1
    syscall

    # print tab
    li $v0, 4
    la $a0, tab
    syscall

    # next column
    addi $t2, $t2, 1
    li $t0, 9
    blt $t2, $t0, pg_col

    # print newline
    li $v0, 4
    la $a0, newline
    syscall

    # next row
    addi $t1, $t1, 1
    li $t0, 9
    blt $t1, $t0, pg_row

    jr $ra

########################################################
# rand_1_to_9: returns a random number between 1 and 9
# Output: $v0 = random number (1-9)
########################################################
rand_1_to_9:
    # LCG algorithm: seed = (seed * 1103515245 + 12345) % 2^32
    la $t0, seed
    lw $t1, 0($t0)

    li $t2, 1103515245
    mul $t1, $t1, $t2
    li $t3, 12345
    add $t1, $t1, $t3

    sw $t1, 0($t0)

    # $t1 now contains a pseudo-random number
    # Get (rand % 9) + 1
    li $t2, 9
    remu $t4, $t1, $t2
    addi $v0, $t4, 1
    jr $ra
