# Sudoku Grid Generator in MIPS Assembly
# Adapted from Java version

.data
grid:          .space 324       # 81 integers (4 bytes each) for the grid
randomValues:  .space 36        # 9 integers for shuffling
registered:    .space 40        # boolean array for tracking registered numbers (1-9)
sorted:        .space 324       # boolean array for tracking sorted cells
newline:       .asciiz "\n"
space:         .asciiz " "
lbracket:      .asciiz "["
rbracket:      .asciiz "]"
perfectMsg:    .asciiz "PERFECT GRID GENERATED\n"
imperfectMsg:  .asciiz "ERROR: Imperfect grid generated.\n"
seedMsg:       .asciiz "Random seed: "

.text
.globl main

main:
    # Initialize the random number generator with system time
    li $v0, 30           # get system time
    syscall
    move $a0, $v0        # seed with lower 32 bits of system time
    li $v0, 40           # set random seed
    li $a1, 0            # random generator ID
    syscall
    
    # Print seed for debugging
    li $v0, 4
    la $a0, seedMsg
    syscall
    move $a0, $v0
    li $v0, 1
    syscall
    li $v0, 4
    la $a0, newline
    syscall
    
    # Generate the grid
    jal generateGrid
    
    # Test if the grid is perfect
    jal isPerfect
    beq $v0, $zero, notPerfect
    
    # Print perfect message and the grid
    li $v0, 4
    la $a0, perfectMsg
    syscall
    
    jal printGrid
    j endProgram
    
notPerfect:
    # Print error message
    li $v0, 4
    la $a0, imperfectMsg
    syscall
    
endProgram:
    li $v0, 10       # exit program
    syscall

#############################################################
# Generate a valid Sudoku grid
# Returns: void (grid is stored in memory)
#############################################################
generateGrid:
    # Save return address
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Initialize randomValues array with 1-9
    la $t0, randomValues
    li $t1, 1              # starting value
    
    initRandomValues:
        sw $t1, 0($t0)
        addi $t0, $t0, 4
        addi $t1, $t1, 1
        ble $t1, 9, initRandomValues
    
    # Clear the grid and sorted arrays
    la $t0, grid
    li $t1, 0
    
    clearGrid:
        sw $zero, 0($t0)
        addi $t0, $t0, 4
        addi $t1, $t1, 1
        blt $t1, 81, clearGrid
    
    la $t0, sorted
    li $t1, 0
    
    clearSorted:
        sw $zero, 0($t0)
        addi $t0, $t0, 4
        addi $t1, $t1, 1
        blt $t1, 81, clearSorted
    
    # Load boxes with numbers 1-9
    li $t0, 0              # i counter (0-80)
    
    loadBoxes:
        # Check if we need to shuffle
        rem $t1, $t0, 9
        bne $t1, 0, skipShuffle
        
        # Shuffle randomValues
        jal shuffleArray
        
    skipShuffle:
        # Calculate perBox index
        # perBox = ((i / 3) % 3) * 9 + ((i % 27) / 9) * 3 + (i / 27) * 27 + (i % 3)
        
        # (i / 3) % 3
        div $t1, $t0, 3
        rem $t1, $t1, 3
        mul $t1, $t1, 9    # ((i / 3) % 3) * 9
        
        # (i % 27) / 9
        rem $t2, $t0, 27
        div $t2, $t2, 9
        mul $t2, $t2, 3    # ((i % 27) / 9) * 3
        
        # (i / 27) * 27
        div $t3, $t0, 27
        mul $t3, $t3, 27   # (i / 27) * 27
        
        # (i % 3)
        rem $t4, $t0, 3
        
        # perBox = sum of all parts
        add $t1, $t1, $t2
        add $t1, $t1, $t3
        add $t1, $t1, $t4  # t1 now has perBox index
        
        # Get the number from randomValues
        rem $t2, $t0, 9    # i % 9
        mul $t2, $t2, 4    # convert to byte offset
        la $t3, randomValues
        add $t3, $t3, $t2
        lw $t4, 0($t3)     # t4 has the value to place
        
        # Store in grid[perBox]
        mul $t1, $t1, 4    # convert to byte offset
        la $t3, grid
        add $t3, $t3, $t1
        sw $t4, 0($t3)
        
        addi $t0, $t0, 1
        blt $t0, 81, loadBoxes
    
    # Sort rows and columns to ensure Sudoku validity
    li $t0, 0              # i counter (0-8)
    
    sortRowsAndCols:
        # For each row and column (i = 0 to 8)
        # First sort row
        li $t1, 0          # rowMode (0 = row, 1 = column)
        jal sortRowOrCol
        
        # Then sort column
        li $t1, 1          # colMode (0 = row, 1 = column)
        jal sortRowOrCol
        
        addi $t0, $t0, 1
        blt $t0, 9, sortRowsAndCols
    
    # Restore return address and return
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

#############################################################
# Sort a row or column to ensure Sudoku validity
# Uses: t0 (row/col index), t1 (0=row, 1=col)
# Returns: void
#############################################################
sortRowOrCol:
    # Save return address and used registers
    addi $sp, $sp, -16
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    
    move $s0, $t0          # s0 = row/col index
    move $s1, $t1          # s1 = mode (0=row, 1=col)
    
    # Clear registered array
    la $t0, registered
    li $t1, 0
    
    clearRegistered:
        sw $zero, 0($t0)
        addi $t0, $t0, 4
        addi $t1, $t1, 1
        blt $t1, 10, clearRegistered
    
    # Calculate origin based on mode
    beq $s1, 1, calcColOrigin
    
    # Row origin = i * 9
    mul $s2, $s0, 9
    j originCalcDone
    
calcColOrigin:
    # Col origin = i
    move $s2, $s0
    
originCalcDone:
    # Process each cell in row/column
    li $t0, 0              # j counter (0-8)
    
processCells:
    # Calculate step based on mode
    beq $s1, 1, calcColStep
    
    # Row step = rowOrigin + j
    add $t1, $s2, $t0
    j stepCalcDone
    
calcColStep:
    # Col step = colOrigin + j*9
    mul $t1, $t0, 9
    add $t1, $t1, $s2
    
stepCalcDone:
    # Get number at this position
    mul $t2, $t1, 4        # convert to byte offset
    la $t3, grid
    add $t3, $t3, $t2
    lw $t4, 0($t3)         # t4 has the number
    
    # Check if registered
    mul $t5, $t4, 4        # convert to byte offset
    la $t6, registered
    add $t6, $t6, $t5
    lw $t7, 0($t6)
    
    beq $t7, 1, duplicateFound
    
    # Register this number
    li $t7, 1
    sw $t7, 0($t6)
    
    j nextCell
    
duplicateFound:
    # Simple swap algorithm - find unregistered number in another position
    li $t7, 0              # k counter
    
swapSearch:
    # Look for a position with a number that isn't registered
    add $t8, $s2, $t7      # potential swap position in row/column
    
    # Skip if it's the current position
    beq $t8, $t1, nextSwapPos
    
    # Get number at this position
    mul $t9, $t8, 4        # convert to byte offset
    la $t3, grid
    add $t3, $t3, $t9
    lw $t5, 0($t3)         # t5 has the number
    
    # Check if this number is registered
    mul $t6, $t5, 4        # convert to byte offset
    la $t2, registered
    add $t2, $t2, $t6
    lw $t6, 0($t2)
    
    bne $t6, 0, nextSwapPos
    
    # Swap values
    sw $t5, 0($t3)         # grid[t1] = t5
    
    mul $t9, $t1, 4        # convert t1 to byte offset
    la $t3, grid
    add $t3, $t3, $t9
    sw $t4, 0($t3)         # grid[t8] = t4
    
    # Register swapped number
    mul $t5, $t5, 4        # convert to byte offset
    la $t6, registered
    add $t6, $t6, $t5
    li $t7, 1
    sw $t7, 0($t6)
    
    j nextCell
    
nextSwapPos:
    addi $t7, $t7, 1
    blt $t7, 9, swapSearch
    
    # If no simple swap works, we'll try a more complex approach or backtrack
    # For simplicity in this implementation, we'll just continue and fix in verification
    
nextCell:
    addi $t0, $t0, 1
    blt $t0, 9, processCells
    
    # Mark as sorted based on mode
    beq $s1, 1, markColSorted
    
    # Mark row as sorted
    li $t0, 0              # j counter
    
markRowSorted:
    # sorted[i*9+j] = true
    mul $t1, $s0, 9
    add $t1, $t1, $t0
    mul $t1, $t1, 4        # convert to byte offset
    la $t2, sorted
    add $t2, $t2, $t1
    li $t3, 1
    sw $t3, 0($t2)
    
    addi $t0, $t0, 1
    blt $t0, 9, markRowSorted
    j sortDone
    
markColSorted:
    # Mark column as sorted
    li $t0, 0              # j counter
    
markColLoop:
    # sorted[i+j*9] = true
    mul $t1, $t0, 9
    add $t1, $t1, $s0
    mul $t1, $t1, 4        # convert to byte offset
    la $t2, sorted
    add $t2, $t2, $t1
    li $t3, 1
    sw $t3, 0($t2)
    
    addi $t0, $t0, 1
    blt $t0, 9, markColLoop
    
sortDone:
    # Restore registers and return
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    addi $sp, $sp, 16
    jr $ra

#############################################################
# Shuffle the randomValues array (Fisher-Yates algorithm)
# Returns: void (randomValues is modified in place)
#############################################################
shuffleArray:
    # Save return address
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Fisher-Yates shuffle algorithm
    li $t0, 8              # i = array length - 1
    
shuffleLoop:
    # Generate random j where 0 <= j <= i
    li $v0, 42             # random int
    li $a0, 0              # generator id
    addi $a1, $t0, 1       # upper bound (i+1)
    syscall
    move $t1, $a0          # t1 = j (random index)
    
    # Swap randomValues[i] and randomValues[j]
    mul $t2, $t0, 4        # t2 = i * 4 (byte offset)
    mul $t3, $t1, 4        # t3 = j * 4 (byte offset)
    
    la $t4, randomValues
    add $t4, $t4, $t2      # address of randomValues[i]
    la $t5, randomValues
    add $t5, $t5, $t3      # address of randomValues[j]
    
    lw $t6, 0($t4)         # t6 = randomValues[i]
    lw $t7, 0($t5)         # t7 = randomValues[j]
    
    sw $t7, 0($t4)         # randomValues[i] = randomValues[j]
    sw $t6, 0($t5)         # randomValues[j] = temp
    
    # Decrement i and continue if i > 0
    addi $t0, $t0, -1
    bgez $t0, shuffleLoop
    
    # Restore return address and return
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

#############################################################
# Print the Sudoku grid
# Returns: void
#############################################################
printGrid:
    # Save return address
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    li $t0, 0              # i counter (0-80)
    
printLoop:
    # Print opening bracket
    li $v0, 4
    la $a0, lbracket
    syscall
    
    # Print grid value
    mul $t1, $t0, 4        # convert to byte offset
    la $t2, grid
    add $t2, $t2, $t1
    lw $a0, 0($t2)
    li $v0, 1
    syscall
    
    # Print closing bracket and space
    li $v0, 4
    la $a0, rbracket
    syscall
    
    li $v0, 4
    la $a0, space
    syscall
    
    # Check if end of row
    rem $t1, $t0, 9
    bne $t1, 8, skipNewline
    
    # Print newline
    li $v0, 4
    la $a0, newline
    syscall
    
skipNewline:
    addi $t0, $t0, 1
    blt $t0, 81, printLoop
    
    # Restore return address and return
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

#############################################################
# Tests if the grid is a valid Sudoku grid
# Returns: $v0 = 1 if perfect, 0 if not
#############################################################
isPerfect:
    # Save return address
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Test boxes
    li $t0, 0              # box counter (0-8)
    
testBoxes:
    # Clear registered array
    la $t1, registered
    li $t2, 0
    
    clearBoxRegistered:
        sw $zero, 0($t1)
        addi $t1, $t1, 4
        addi $t2, $t2, 1
        blt $t2, 10, clearBoxRegistered
    
    # Mark registered[0] as true (we don't use index 0)
    la $t1, registered
    li $t2, 1
    sw $t2, 0($t1)
    
    # Calculate box origin
    # boxOrigin = (i * 3) % 9 + ((i * 3) / 9) * 27
    mul $t1, $t0, 3
    rem $t2, $t1, 9
    div $t1, $t1, 9
    mul $t1, $t1, 27
    add $t1, $t1, $t2      # t1 = boxOrigin
    
    # Check each cell in box
    li $t2, 0              # j counter (0-8)
    
testBoxCells:
    # Calculate boxStep
    # boxStep = boxOrigin + (j / 3) * 9 + (j % 3)
    div $t3, $t2, 3
    mul $t3, $t3, 9
    rem $t4, $t2, 3
    add $t3, $t3, $t4
    add $t3, $t3, $t1      # t3 = boxStep
    
    # Get number at this position
    mul $t4, $t3, 4        # convert to byte offset
    la $t5, grid
    add $t5, $t5, $t4
    lw $t4, 0($t5)         # t4 has the number
    
    # Mark as registered
    mul $t5, $t4, 4        # convert to byte offset
    la $t6, registered
    add $t6, $t6, $t5
    li $t7, 1
    sw $t7, 0($t6)
    
    addi $t2, $t2, 1
    blt $t2, 9, testBoxCells
    
    # Check if all numbers 1-9 are registered
    li $t2, 1              # start at 1
    
checkBoxRegistered:
    mul $t3, $t2, 4        # convert to byte offset
    la $t4, registered
    add $t4, $t4, $t3
    lw $t5, 0($t4)
    
    beq $t5, 0, notPerfectGrid   # if not registered, grid is not perfect
    
    addi $t2, $t2, 1
    ble $t2, 9, checkBoxRegistered
    
    addi $t0, $t0, 1
    blt $t0, 9, testBoxes
    
    # Test rows
    li $t0, 0              # row counter (0-8)
    
testRows:
    # Clear registered array
    la $t1, registered
    li $t2, 0
    
    clearRowRegistered:
        sw $zero, 0($t1)
        addi $t1, $t1, 4
        addi $t2, $t2, 1
        blt $t2, 10, clearRowRegistered
    
    # Mark registered[0] as true (we don't use index 0)
    la $t1, registered
    li $t2, 1
    sw $t2, 0($t1)
    
    # Calculate row origin
    # rowOrigin = i * 9
    mul $t1, $t0, 9        # t1 = rowOrigin
    
    # Check each cell in row
    li $t2, 0              # j counter (0-8)
    
testRowCells:
    # Calculate rowStep
    # rowStep = rowOrigin + j
    add $t3, $t1, $t2      # t3 = rowStep
    
    # Get number at this position
    mul $t4, $t3, 4        # convert to byte offset
    la $t5, grid
    add $t5, $t5, $t4
    lw $t4, 0($t5)         # t4 has the number
    
    # Mark as registered
    mul $t5, $t4, 4        # convert to byte offset
    la $t6, registered
    add $t6, $t6, $t5
    li $t7, 1
    sw $t7, 0($t6)
    
    addi $t2, $t2, 1
    blt $t2, 9, testRowCells
    
    # Check if all numbers 1-9 are registered
    li $t2, 1              # start at 1
    
checkRowRegistered:
    mul $t3, $t2, 4        # convert to byte offset
    la $t4, registered
    add $t4, $t4, $t3
    lw $t5, 0($t4)
    
    beq $t5, 0, notPerfectGrid   # if not registered, grid is not perfect
    
    addi $t2, $t2, 1
    ble $t2, 9, checkRowRegistered
    
    addi $t0, $t0, 1
    blt $t0, 9, testRows
    
    # Test columns
    li $t0, 0              # column counter (0-8)
    
testColumns:
    # Clear registered array
    la $t1, registered
    li $t2, 0
    
    clearColRegistered:
        sw $zero, 0($t1)
        addi $t1, $t1, 4
        addi $t2, $t2, 1
        blt $t2, 10, clearColRegistered
    
    # Mark registered[0] as true (we don't use index 0)
    la $t1, registered
    li $t2, 1
    sw $t2, 0($t1)
    
    # Calculate column origin
    # colOrigin = i
    move $t1, $t0          # t1 = colOrigin
    
    # Check each cell in column
    li $t2, 0              # j counter (0-8)
    
testColCells:
    # Calculate colStep
    # colStep = colOrigin + j*9
    mul $t3, $t2, 9
    add $t3, $t3, $t1      # t3 = colStep
    
    # Get number at this position
    mul $t4, $t3, 4        # convert to byte offset
    la $t5, grid
    add $t5, $t5, $t4
    lw $t4, 0($t5)         # t4 has the number
    
    # Mark as registered
    mul $t5, $t4, 4        # convert to byte offset
    la $t6, registered
    add $t6, $t6, $t5
    li $t7, 1
    sw $t7, 0($t6)
    
    addi $t2, $t2, 1
    blt $t2, 9, testColCells
    
    # Check if all numbers 1-9 are registered
    li $t2, 1              # start at 1
    
checkColRegistered:
    mul $t3, $t2, 4        # convert to byte offset
    la $t4, registered
    add $t4, $t4, $t3
    lw $t5, 0($t4)
    
    beq $t5, 0, notPerfectGrid   # if not registered, grid is not perfect
    
    addi $t2, $t2, 1
    ble $t2, 9, checkColRegistered
    
    addi $t0, $t0, 1
    blt $t0, 9, testColumns
    
    # If we got here, grid is perfect
    li $v0, 1
    j isPerfectDone
    
notPerfectGrid:
    li $v0, 0
    
isPerfectDone:
    # Restore return address and return
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
