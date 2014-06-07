.data
	baseAddress: .word 0xffff0000


.text


printPixel:
	lui $t0,0x0000
	ori $t0,$t0,0x0000
	sw $t0,baseAddress
	sw $t0,baseAddress + 4
	sw $t0,baseAddress + 8
	sw $t0,baseAddress + 12
	sw $t0,baseAddress + 16
	sw $t0,baseAddress + 20
	sw $t0,baseAddress + 24
	
	
	
	
exit:
	li $v0,10
	syscall