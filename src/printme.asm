.data

	cross: .byte	0x71, 0xAA, 0x71, 0xE1,
			0xAA, 0xBB, 0xAA, 0xE1,
			0x71, 0xAA, 0x71, 0xEA

.text

	la $a0, cross
	lui $a1, 0xFF00
	
	jal printme
	
	exit: j exit

## --- PRINTME procedure ---
#  It's supposed to print a MIF on the screen, taking a designed color as transparent.
#
#	Made by Yurick in OAC 2014/1
#
#	$a0: obj - The address to the .data object, given the following standard:
#		It's an array of bytes, each byte representing a color;
#		The 0x71 color marks 7ransparenc1;
#		The 0xE1 color marks the end of 1ine;
#		The 0xEA color marks the end of the array;
#		The array is large enougth to fit the screen.
#	$a1: scraddr - The address to the point in the VGA memory that the image should be displayed.

printme:

	# Store-vars step
	addi $sp, $sp, -36
	sw $t0, 0($sp)  # startVGA
	sw $t1, 4($sp)  # endVGA
	sw $t2, 8($sp)  # cursorAddr
	sw $t3, 12($sp) # cursorData
	sw $t4, 16($sp) # Transparency
	sw $t5, 20($sp) # End Line
	sw $t6, 24($sp) # End Array
	sw $t7, 28($sp) # VGAcursor
	sw $t8, 32($sp) # LineFeed
	
	lui $t0, 0xFF00 # $t0 is now the starting address of VGA
	
	lui $t1, 0xFF01
	ori $t1, $t1, 0x2C00 # $t1 is now the ending address of VGA
	
	li $t4, 0x71 # $t4 is now the code to transparency
	li $t5, 0xE1 # $t5 is now the code to End-Line
	li $t6, 0xEA # $t6 is now the code to End-Array
	
	blt $a1, $t0, end_printme # scraddr < startVGA ? exit : continue
	bge $a1, $t1, end_printme # scraddr >= endVGA ? exit : continue
	
	add $t2, $a0, $zero # $t2 is now a copy of obj
	add $t7, $a1, $zero # $t7 is now a copy of scraddr
	add $t8, $a1, 0x500 # address of next line.
	
line_printme:
	
	lbu $t3, 0($t2) # load data in cursorAddr on $t3
	
	beq $t3, $t6, end_printme # if endArray, let's get out!
	beq $t3, $t5, endline_printme # if endLine, let's jump!
	beq $t3, $t4, blind_printme # if transparency, let's get blind!
	
	sb $t3, 0($t7) # print pixel in VGAddress
	
blind_printme:

	addi $t7, $t7, 4 # go to next pixel in screen. 1 in ALTERA, 4 in MARS
	addi $t2, $t2, 1 # go to next pixel in array
	
	j line_printme

endline_printme:

	add $t7, $t8, $zero # jump line.
	addi $t8, $t8, 0x500 # recalculate line feed
	addi $t2, $t2, 1 # gogo next pixel
	j line_printme
	
end_printme:

	# Restore-vars step
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $t3, 12($sp)
	lw $t4, 16($sp)
	lw $t5, 20($sp)
	lw $t6, 24($sp)
	lw $t7, 28($sp)
	lw $t8, 32($sp)
	addi $sp, $sp, 36
	
	jr $ra # byebye
