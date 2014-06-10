#UnB
#OAC - lamar     ||      2014/1
#flappy bird 
#grupo 5




.data
	# VARIAVEIS DE GERENCIAMENTO DO DISPLAY
	bitmap_address: .word 0x10040000
	bitmap_width:   .word 512
	bitmap_height:  .word 512

	
	#variaveis do jogo
	
	#PLAYER
	P_posY:		.word		100			#afetada pela gravidade
	P_posX:		.word		70			#nunca mais sera mudada
	P_velY:		.word		0			#inicialmente parado até receber input

	#cores
	
	
	# CORES DEFAULT
	black:		.word 0x000000
	white:		.word 0xffffff		# cores default #
	blue:		.word 0x0000ff
	red:		.word 0xff0000
	green:		.word 0x00ff00
	yellow:		.word 0xffff00
	
	azul_fundo:	.word 0x5aa0af
	amarelo_geral:	.word 0xfcd225
	amarelo_claro:	.word 0xffea94
	amarelo_escuro:	.word 0xc7a210
	boca:		.word 0xdd4110
	


.text


main:
	
	init:
		addi $sp,$sp,-4
		sw $ra,($sp)
		
		jal clearScreen
		
		#draw flappy
		lw $a0,P_posX
		lw $a1,P_posY
		
		jal drawFlappy
	
	
	
	
	#loop_principal:
	
	
	
	
	
	
	
	
	
	
	
	#j loop_principal
	
	
	j exit
	
	#procedures
	
	#a0 == cor ||  a1 == x  || a2 == y
	drawPixel:
		lw $t0,bitmap_width
		mul $t1,$t0,$a2		#obter endereço
		add $t2,$t1,$a1
		sll $t2,$t2,2		#multyply por 4
		lw $t3,bitmap_address
		add $t4,$t3,$t2
		sw $a0,($t4)
		
		jr $ra
	
	#a0 == x ; a1 == y
	drawFlappy:
		addi $sp,$sp,-4
		sw $ra,($sp)
		
		move $t0,$a0
		move $t1,$a1
		drawPixelsPretos:
			lw $a0,black
			
			#pixels
			addi $a1,$t0,0
			addi $a2,$t1,2
			jal drawPixel
			
			#pixels
			addi $a1,$t0,0
			addi $a2,$t1,3
			jal drawPixel
			
			#pixels
			addi $a1,$t0,1
			addi $a2,$t1,4
			jal drawPixel
			
			#pixels
			addi $a1,$t0,1
			addi $a2,$t1,5
			jal drawPixel
			
			#pixels
			addi $a1,$t0,0
			addi $a2,$t1,7
			jal drawPixel
			
			#pixels
			addi $a1,$t0,0
			addi $a2,$t1,8
			jal drawPixel
			
			#pixels
			addi $a1,$t0,1
			addi $a2,$t1,9
			jal drawPixel
			
			#pixels
			addi $a1,$t0,2
			addi $a2,$t1,9
			jal drawPixel
			
			#pixels
			addi $a1,$t0,3
			addi $a2,$t1,8
			jal drawPixel
			
			#pixels
			addi $a1,$t0,4
			addi $a2,$t1,7
			jal drawPixel
			
			#pixels
			addi $a1,$t0,5
			addi $a2,$t1,8
			jal drawPixel
			
			#pixels
			addi $a1,$t0,6
			addi $a2,$t1,9
			jal drawPixel
			
			#pixels
			addi $a1,$t0,7
			addi $a2,$t1,9
			jal drawPixel
			
			#pixels
			addi $a1,$t0,8
			addi $a2,$t1,10
			jal drawPixel
			
			#pixels
			addi $a1,$t0,9
			addi $a2,$t1,10
			jal drawPixel
			
			#pixels
			addi $a1,$t0,11
			addi $a2,$t1,10
			jal drawPixel
			
			#pixels
			addi $a1,$t0,12
			addi $a2,$t1,10
			jal drawPixel
			
			
			#pixels
			addi $a1,$t0,13
			addi $a2,$t1,10
			jal drawPixel
			
			#pixels
			addi $a1,$t0,14
			addi $a2,$t1,10
			jal drawPixel
			
			#pixels
			addi $a1,$t0,15
			addi $a2,$t1,9
			jal drawPixel
			
			#pixels
			addi $a1,$t0,16
			addi $a2,$t1,9
			jal drawPixel
			
			#pixels
			addi $a1,$t0,18
			addi $a2,$t1,7
			jal drawPixel
			
			#pixels
			addi $a1,$t0,18
			addi $a2,$t1,6
			jal drawPixel
			
			#pixels
			addi $a1,$t0,18
			addi $a2,$t1,5
			jal drawPixel
			
			#pixels
			addi $a1,$t0,18
			addi $a2,$t1,4
			jal drawPixel
			
			#pixels
			addi $a1,$t0,17
			addi $a2,$t1,3
			jal drawPixel
			
			#pixels
			addi $a1,$t0,16
			addi $a2,$t1,2
			jal drawPixel
			
			#pixels
			addi $a1,$t0,15
			addi $a2,$t1,1
			jal drawPixel
			
			#pixels
			addi $a1,$t0,14
			addi $a2,$t1,1
			jal drawPixel
			
			#pixels
			addi $a1,$t0,13
			addi $a2,$t1,0
			jal drawPixel
			
			#pixels
			addi $a1,$t0,12
			addi $a2,$t1,0
			jal drawPixel
			
			#pixels
			addi $a1,$t0,11
			addi $a2,$t1,0
			jal drawPixel
			
			#pixels
			addi $a1,$t0,10
			addi $a2,$t1,0
			jal drawPixel
			
			#pixels
			addi $a1,$t0,9
			addi $a2,$t1,0
			jal drawPixel
			
			#pixels
			addi $a1,$t0,8
			addi $a2,$t1,1
			jal drawPixel
			
			#pixels
			addi $a1,$t0,7
			addi $a2,$t1,1
			jal drawPixel
			
			#pixels
			addi $a1,$t0,6
			addi $a2,$t1,2
			jal drawPixel
			
			#pixels
			addi $a1,$t0,5
			addi $a2,$t1,3
			jal drawPixel
			
			#pixels
			addi $a1,$t0,4
			addi $a2,$t1,2
			jal drawPixel
			
			#pixels
			addi $a1,$t0,3
			addi $a2,$t1,1
			jal drawPixel
			
			#pixels
			addi $a1,$t0,2
			addi $a2,$t1,1
			jal drawPixel
			
			
		lw $ra,($sp)
		addi $sp,$sp,4
		
		jr $ra
	
	
	
	#clear screen com a cor do fundo padrao
	clearScreen:
		#t0 = x, t1 = y
		addi $sp,$sp,-8
		sw $ra,4($sp)
		sw $s7,0($sp)
		
		li $t0,0
		li $t1,0
		lw $t2,azul_fundo
		lw $t3,bitmap_width
		lw $t4,bitmap_height
		
		lw $s7,bitmap_address
		
		loop_x:
			beq $t3,$t0,sai_x
			li $t1,0
			loop_y:
				beq $t4,$t1,sai_y
				
				mul $t5,$t3,$t0
				add $t6,$t5,$t1
				sll $t6,$t6,2
				
				add $t7,$s7,$t6		#t7 == endereço pra guardar a word de cor
				
				sw $t2,($t7)
				
				addi $t1,$t1,1   #inc y
			j loop_y
			sai_y:
			
			addi $t0,$t0,1	#inc x
		j loop_x
		sai_x:
		
		lw $s7,0($sp)
		lw $ra,4($sp)
		
		jr $ra
	
	
	exit:
		li $v0,10
		syscall
