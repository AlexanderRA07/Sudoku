# MACROS.ASM

# exit
# getInt, printInt(%int)
# getString(%bufferName, %bufferLength), printf(%str)

# Exit macro
.macro exit
	li $v0, 10
	syscall
.end_macro

# Recieve Integer
.macro getInput(%register)
	li $v0, 5
	syscall
	move %register, $v0
.end_macro

# Print Integer
.macro printInt(%int)
	li $v0, 1
	move $a0, %int
	syscall
.end_macro

# Revieve String
.macro getString(%bufferName, %bufferLength)
	# bufferName for address
	# bufferLength for length
	
	li $v0, 8		# 8 to read string
	la $a0, %bufferName	# 
	li $s1, %bufferLength	# 
.end_macro

# Print string
.macro printf(%str)
	li $v0, 4
	la $a0, %str
	syscall
.end_macro

