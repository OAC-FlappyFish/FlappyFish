#UnB
#OAC - lamar     ||      2014/1
#flappy bird 
#grupo 5




.data
	# VARIAVEIS DE GERENCIAMENTO DO DISPLAY
	bitmap_address: .word 0x10040000
	bitmap_width:   .word 128
	bitmap_height:  .word 128
	
	nl:	.asciiz "\n"

	
	#variaveis do jogo
	
	#PLAYER
	P_posY:		.word 45			#afetada pela gravidade
	P_posX:		.word 32			#nunca mais sera mudada
	P_velY:		.word 0			#inicialmente parado até receber input
	
	P_aceleracao:	.word	2			#aceleracao da gravidade, sempre constante
	
	P_force:	.word	-20			#força aplicada qnd receber o input
	
	frameCounter:	.word 1				#contar em qual frame está
	
	frequenciaForce:	.word	6		#aplicar força a cada 100 frames(teste apenas)
	
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
		
		lw $a0,P_posX
		lw $a1,P_posY
		
		#draw flappy
		
		jal drawFlappy
	
		#jal drawQuadrado
	
	
	loop_principal:
	
	
		jal atualizarVelocidade
		jal atualizarPosicoes
	
	
		jal clearScreen		#resetar o display
		
		
		lw $a0,P_posX
		lw $a1,P_posY
		#draw flappy
		jal drawFlappy
		
		lw $t7,frameCounter			#registrador nao guardado na pilha!!!
		bge $t7,18,naoChamaForce
		jal applyForce
		naoChamaForce:
	
		jal incFrame
	
	
	j loop_principal
	
	
	j exit
	
	#procedures
	
	
	applyForce:
		addi $sp,$sp,-16
		sw $s0,($sp)
		sw $s1,4($sp)
		sw $s2,8($sp)
		sw $s3,12($sp)
		
		
		lw $s3,frameCounter
		lw $s2,frequenciaForce
		div $s3,$s2
		
		mfhi $s1
		
		bne $s1,0,naoAplicar
		
		lw $s0,P_velY
		lw $s1,P_force
		
		add $s2,$s0,$s1		#s2(nova velocidade)  =  velocidadeAntiga + forca
		
		sw $s2,P_velY
		
		
		
		naoAplicar:
		
		lw $s0,($sp)
		lw $s1,4($sp)
		lw $s2,8($sp)
		lw $s3,12($sp)
		addi $sp,$sp,16
		
		
		
		jr $ra
	
	
	incFrame:
		addi $sp,$sp,-4
		sw $s0,0($sp)
		
		lw $s0,frameCounter
		
		addi $s0,$s0,1
		
		sw $s0,frameCounter
		
		
		
		lw $s0,0($sp)
		addi $sp,$sp,4
		
		jr $ra
	
	atualizarPosicoes:
		addi $sp,$sp,-16
		sw $s0,($sp)
		sw $s1,4($sp)
		sw $s2,8($sp)
		sw $s3,12($sp)
		
		lw $s0,P_posY
		lw $s1,P_velY
		
		add $s2,$s0,$s1		#nova posicao = posicaoantiga + velocidade atual
		
		sw $s2,P_posY
		
		lw $s0,($sp)
		lw $s1,4($sp)
		lw $s2,8($sp)
		lw $s3,12($sp)
		addi $sp,$sp,16
		
		jr $ra
	
	atualizarVelocidade:
		addi $sp,$sp,-16
		sw $s0,($sp)
		sw $s1,4($sp)
		sw $s2,8($sp)
		sw $s3,12($sp)
		
		lw $s0,P_aceleracao
		lw $s1,P_velY
		
		add $s2,$s0,$s1		#s2 = velocidade + aceleracao (nova velocidade)
		
		sw $s2,P_velY
		
		
		
		lw $s0,($sp)
		lw $s1,4($sp)
		lw $s2,8($sp)
		lw $s3,12($sp)
		addi $sp,$sp,16
		
		jr $ra
	
	#a0 == cor ||  a1 == x  || a2 == y
	drawPixel:
		addi $sp,$sp,-36
		sw $ra,0($sp)
		sw $a0,4($sp)
		sw $a1,8($sp)
		sw $a2,12($sp)
		sw $t0,16($sp)
		sw $t1,20($sp)
		sw $t2,24($sp)
		sw $t3,28($sp)
		sw $t4,32($sp)
		
		
		lw $t0,bitmap_width
		mul $t1,$t0,$a2		#t1 = width * y
		add $t2,$t1,$a1		#t2 = (width * y) + x
		sll $t2,$t2,2		#t2 = 4 * ((width * y) + x)
		lw $t3,bitmap_address
		add $t4,$t3,$t2		#t4 = address + 4 * ((width * y) + x)
		sw $a0,0($t4)
		
		lw $ra,0($sp)
		lw $a0,4($sp)
		lw $a1,8($sp)
		lw $a2,12($sp)
		lw $t0,16($sp)
		lw $t1,20($sp)
		lw $t2,24($sp)
		lw $t3,28($sp)
		lw $t4,32($sp)
		addi $sp,$sp,36
		
		jr $ra
	
	
	#a0 == x ; a1 == y
	drawQuadrado:
		addi $sp,$sp,-12
		sw $ra,($sp)
		sw $a0,4($sp)
		sw $a1,8($sp)
		
		move $t0,$a0
		move $t1,$a1
		
		#pixels
		addi $a1,$t0,0
		addi $a2,$t1,0
		
		jal drawPixel
		
			
		#pixels
		addi $a1,$t0,0
		addi $a2,$t1,1
		jal drawPixel
		
			
						
		#pixels
		addi $a1,$t0,1
		addi $a2,$t1,0
		jal drawPixel
			
		#pixels
		addi $a1,$t0,1
		addi $a2,$t1,1
		jal drawPixel
		
				
		lw $ra,($sp)
		lw $a0,4($sp)
		lw $a1,8($sp)
		addi $sp,$sp,12
		
		jr $ra
	
	
	#a0 == x ; a1 == y
	drawFlappy:
		addi $sp,$sp,-12
		sw $ra,($sp)
		sw $a0,4($sp)
		sw $a1,8($sp)
		
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
			
			#pixels
			addi $a1,$t0,14
			addi $a2,$t1,3
			jal drawPixel
			
			#pixels
			addi $a1,$t0,14
			addi $a2,$t1,4
			jal drawPixel
			
			##############
			#barbatanas pretas
			
			#pixels
			addi $a1,$t0,8
			addi $a2,$t1,6
			jal drawPixel
			
			#pixels
			addi $a1,$t0,8
			addi $a2,$t1,7
			jal drawPixel
			
			#pixels
			addi $a1,$t0,8
			addi $a2,$t1,8
			jal drawPixel
			
			#pixels
			addi $a1,$t0,11
			addi $a2,$t1,3
			jal drawPixel
			
			#pixels
			addi $a1,$t0,11
			addi $a2,$t1,4
			jal drawPixel
			
			#pixels
			addi $a1,$t0,11
			addi $a2,$t1,5
			jal drawPixel
			
			#pixels
			addi $a1,$t0,11
			addi $a2,$t1,6
			jal drawPixel
			
			#pixels
			addi $a1,$t0,11
			addi $a2,$t1,7
			jal drawPixel
			
			#pixels
			addi $a1,$t0,11
			addi $a2,$t1,8
			jal drawPixel
			
		
		drawPixelsBoca:
			lw $a0,boca
			
			
			#pixels
			addi $a1,$t0,14
			addi $a2,$t1,7
			jal drawPixel
			
			#pixels
			addi $a1,$t0,15
			addi $a2,$t1,7
			jal drawPixel
			
			#pixels
			addi $a1,$t0,16
			addi $a2,$t1,7
			jal drawPixel
			
			#pixels
			addi $a1,$t0,14
			addi $a2,$t1,8
			jal drawPixel
			
			#pixels
			addi $a1,$t0,15
			addi $a2,$t1,8
			jal drawPixel
			
			#pixels
			addi $a1,$t0,16
			addi $a2,$t1,8
			jal drawPixel
			
			
			###### fim boca ######
			
		drawPixelsAmareloClaro:
			lw $a0,amarelo_claro
			
			#pixels
			addi $a1,$t0,1
			addi $a2,$t1,2
			jal drawPixel
			
			#pixels
			addi $a1,$t0,2
			addi $a2,$t1,1
			jal drawPixel
			
			#pixels
			addi $a1,$t0,3
			addi $a2,$t1,3
			jal drawPixel
			
			#pixels
			addi $a1,$t0,4
			addi $a2,$t1,4
			jal drawPixel
			
			#pixels
			addi $a1,$t0,5
			addi $a2,$t1,3
			jal drawPixel
			
			#pixels
			addi $a1,$t0,6
			addi $a2,$t1,2
			jal drawPixel
			
			#pixels
			addi $a1,$t0,7
			addi $a2,$t1,2
			jal drawPixel
			
			#pixels
			addi $a1,$t0,8
			addi $a2,$t1,1
			jal drawPixel
			
			#pixels
			addi $a1,$t0,9
			addi $a2,$t1,1
			jal drawPixel
			
			#pixels
			addi $a1,$t0,10
			addi $a2,$t1,1
			jal drawPixel
			
			#pixels
			addi $a1,$t0,11
			addi $a2,$t1,1
			jal drawPixel
			
			#pixels
			addi $a1,$t0,12
			addi $a2,$t1,1
			jal drawPixel
			
			#pixels
			addi $a1,$t0,17
			addi $a2,$t1,4
			jal drawPixel
			
			#pixels
			addi $a1,$t0,17
			addi $a2,$t1,5
			jal drawPixel
			
			#pixels
			addi $a1,$t0,17
			addi $a2,$t1,6
			jal drawPixel
			
		drawPixelsAmareloEscuro:
			lw $a0,amarelo_escuro
			
			#pixels
			addi $a1,$t0,1
			addi $a2,$t1,6
			jal drawPixel
			
			#pixels
			addi $a1,$t0,1
			addi $a2,$t1,7
			jal drawPixel
			
			#pixels
			addi $a1,$t0,1
			addi $a2,$t1,8
			jal drawPixel
			
			#pixels
			addi $a1,$t0,2
			addi $a2,$t1,8
			jal drawPixel
			
			#pixels
			addi $a1,$t0,3
			addi $a2,$t1,7
			jal drawPixel
			
			#pixels
			addi $a1,$t0,4
			addi $a2,$t1,6
			jal drawPixel
			
			#pixels
			addi $a1,$t0,5
			addi $a2,$t1,7
			jal drawPixel
			
			#pixels
			addi $a1,$t0,6
			addi $a2,$t1,8
			jal drawPixel
			
			#pixels
			addi $a1,$t0,7
			addi $a2,$t1,8
			jal drawPixel
			
			#pixels
			addi $a1,$t0,8
			addi $a2,$t1,9
			jal drawPixel
			
			#pixels
			addi $a1,$t0,9
			addi $a2,$t1,9
			jal drawPixel
			
			#pixels
			addi $a1,$t0,10
			addi $a2,$t1,9
			jal drawPixel
			
			#pixels
			addi $a1,$t0,11
			addi $a2,$t1,9
			jal drawPixel
			
			#pixels
			addi $a1,$t0,12
			addi $a2,$t1,9
			jal drawPixel
			
			#pixels
			addi $a1,$t0,13
			addi $a2,$t1,9
			jal drawPixel
			
			#pixels
			addi $a1,$t0,10
			addi $a2,$t1,4
			jal drawPixel
			
			#pixels
			addi $a1,$t0,10
			addi $a2,$t1,5
			jal drawPixel
			
			#pixels
			addi $a1,$t0,10
			addi $a2,$t1,6
			jal drawPixel
			
			#pixels
			addi $a1,$t0,10
			addi $a2,$t1,7
			jal drawPixel
			
		
		drawPixelsOlho:
			lw $a0,white
			
			#pixels
			addi $a1,$t0,13
			addi $a2,$t1,2
			jal drawPixel
			
			#pixels
			addi $a1,$t0,13
			addi $a2,$t1,3
			jal drawPixel
			
			#pixels
			addi $a1,$t0,13
			addi $a2,$t1,4
			jal drawPixel
			
			#pixels
			addi $a1,$t0,13
			addi $a2,$t1,5
			jal drawPixel
			
			#pixels
			addi $a1,$t0,14
			addi $a2,$t1,5
			jal drawPixel
			
			#pixels
			addi $a1,$t0,15
			addi $a2,$t1,4
			jal drawPixel
			
			#pixels
			addi $a1,$t0,15
			addi $a2,$t1,3
			jal drawPixel
			
			#pixels
			addi $a1,$t0,14
			addi $a2,$t1,2
			jal drawPixel
			
			
			
		lw $ra,($sp)
		lw $a0,4($sp)
		lw $a1,8($sp)
		addi $sp,$sp,12
		
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
