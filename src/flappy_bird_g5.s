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
	P_posX:		.word 20			#nunca mais sera mudada
	P_velY:		.word 0			#inicialmente parado até receber input
	
	P_width:	.word	22		#largura
	P_height:	.word	13		#altura do peixe
	
	P_aceleracao:	.word	2			#aceleracao da gravidade, sempre constante
	
	P_force:	.word	-18			#força aplicada qnd receber o input
	
	frameCounter:	.word 1				#contar em qual frame está
	
	frequenciaForce:	.word	6		#aplicar força a cada 100 frames(teste apenas)
	
	flagPerdeu:	.word	0			#ativada qnd houver colisao
	
	pontos:		.word 	0			#inicializa pontos
	
	
	#obstaculo
	tiposDeObstaculos:	.word	0,1,2,3,4
	alturaDoTipo:		.word	15,30,45,60,75
	
	velObstaculos:		.word	-2
	obstaculosWidth:	.word	15
	obstaculosCor:		.word	0x009933
	
	obstaculo1:		.word	0,0,0		#presente	||	tipo	||	pos_x
	obstaculo2:		.word	0,0,0		#presente	||	tipo	||	pos_x
	
	obstaculoInativo:	.word	1
	deveFazerSpawn:		.word	1
	
	gapHeight:		.word	26
	
	posUltimoSpawn:		.word	0
	
	intervaloEntreSpawns:	.word	40
	
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
		#limpar a posiçao anterior do peixe
		
		lw $a0,azul_fundo
		lw $a1,P_width
		lw $a2,P_height
		lw $a3,P_posX
		lw $s0,P_posY
		jal drawRetangulo
		
		li $a0,0
		jal drawObstaculos
		
	
		jal atualizarVelocidade
		jal atualizarPosicoes
		jal atualizarObstaculos
		jal atualizarFlagsSpawn
		
	
		#jal clearScreen		#resetar o display
		
		#spawns
		jal destruirSpawns
		jal fazerSpawns
		
		
		#draws
		lw $a0,P_posX
		lw $a1,P_posY
		jal drawFlappy
		
		
		li $a0,1
		jal drawObstaculos
		
		lw $t7,frameCounter			#registrador nao guardado na pilha!!!
		bge $t7,18,naoChamaForce
		jal applyForce
		naoChamaForce:
	
		jal incFrame
		
		
		#delay pra acertar um bom frame rate
		jal wait
		jal wait
		jal wait
		jal wait
		jal wait
		jal wait
		jal wait
		jal wait
		jal wait
		jal wait
		jal wait
	
	
	j loop_principal
	
	
	j exit
	
	#procedures
	
	fazerSpawns:
		addi $sp,$sp,-36
		sw $s0,($sp)
		sw $s1,4($sp)
		sw $s2,8($sp)
		sw $s3,12($sp)
		sw $t0,16($sp)
		sw $t1,20($sp)
		sw $t2,24($sp)
		sw $t3,28($sp)
		sw $ra,32($sp)
	
		lw $s0,frameCounter
		lw $s1,intervaloEntreSpawns
		
		div $s0,$s1
		
		mfhi $t0	#t0 == resto
		
		beq $zero,$t0,podeFazerSpawn
		j naoFaz
		
		podeFazerSpawn:
		lw $s2,deveFazerSpawn
		li $t1,1
		beq $t1,$s2,fazDo1
		li $t1,2
		beq $t1,$s2,fazDo2
		j naoFaz
		
		fazDo1:
		la $s1,obstaculo1
		
		li $t0,1		#presente
		li $t1,0		#tipo
		lw $t2,bitmap_width	#posicao x
		
		sw $t0,0($s1)
		sw $t1,4($s1)
		sw $t2,8($s1)
		
		j naoFaz
		
		fazDo2:
		
		la $s1,obstaculo2
		
		li $t0,1		#presente
		li $t1,4		#tipo
		lw $t2,bitmap_width	#posicao x
		
		sw $t0,0($s1)
		sw $t1,4($s1)
		sw $t2,8($s1)
		
		j naoFaz
		
		naoFaz:
		
		lw $s0,($sp)
		lw $s1,4($sp)
		lw $s2,8($sp)
		lw $s3,12($sp)
		lw $t0,16($sp)
		lw $t1,20($sp)
		lw $t2,24($sp)
		lw $t3,28($sp)
		lw $ra,32($sp)
		addi $sp,$sp,36
		
		
		
		jr $ra
		
		
	destruirSpawns:
		addi $sp,$sp,-32
		sw $s0,($sp)
		sw $s1,4($sp)
		sw $s2,8($sp)
		sw $s3,12($sp)
		sw $t0,16($sp)
		sw $t1,20($sp)
		sw $t2,24($sp)
		sw $t3,28($sp)
		
		
		la $s1,obstaculo1
		la $s2,obstaculo2
		
		lw $t0,8($s1)		#posicao do 1
		lw $t1,8($s2)		#posicao do 2
		
		lw $t2,obstaculosWidth
		sub $t2,$zero,$t2
		
		ble $t0,$t2,destruir1
		j sair1
		
		
		destruir1:
		sw $zero,0($s1)
		
		sair1:
		
		
		#para o 2
		
		ble $t1,$t2,destruir2
		j sair2
		
		
		destruir2:
		sw $zero,0($s2)
		
		sair2:
		
		lw $s0,($sp)
		lw $s1,4($sp)
		lw $s2,8($sp)
		lw $s3,12($sp)
		lw $t0,16($sp)
		lw $t1,20($sp)
		lw $t2,24($sp)
		lw $t3,28($sp)
		addi $sp,$sp,32
		
		
		
		jr $ra
	
	
	atualizarFlagsSpawn:
		addi $sp,$sp,-32
		sw $s0,($sp)
		sw $s1,4($sp)
		sw $s2,8($sp)
		sw $s3,12($sp)
		sw $t0,16($sp)
		sw $t1,20($sp)
		sw $t2,24($sp)
		sw $t3,28($sp)
		
		lw $s0,deveFazerSpawn
		lw $s3,obstaculoInativo
		la $s1,obstaculo1
		la $s2,obstaculo2
		
		lw $t0,8($s1)		#posicao do 1
		lw $t1,8($s2)		#posicao do 2
		
		ble $t0,$t1,ultimo1
		j ultimo2
		
		ultimo1:
		
		sw $t0,posUltimoSpawn
		j saiDaqui
		
		ultimo2:
		
		sw $t1,posUltimoSpawn
		j saiDaqui
		
		
		saiDaqui:
		
		lw $t0,0($s1)		#present 1
		lw $t1,0($s2)		#presente 2
		
		beq $t0,$zero,naoPresente1
		beq $t1,$zero,naoPresente2
		
		j presentes
		
		
		
		naoPresente1:
			li $t2,1
			sw $t2,obstaculoInativo
			sw $t2,deveFazerSpawn
			j sai
			
		naoPresente2:
			li $t2,1
			sw $t2,obstaculoInativo
			li $t2,2
			sw $t2,deveFazerSpawn
			j sai
			
		
		presentes:
			sw $zero,obstaculoInativo
			sw $zero,deveFazerSpawn
			j sai
		
		sai:
		
		lw $s0,($sp)
		lw $s1,4($sp)
		lw $s2,8($sp)
		lw $s3,12($sp)
		lw $t0,16($sp)
		lw $t1,20($sp)
		lw $t2,24($sp)
		lw $t3,28($sp)
		addi $sp,$sp,32
		
		
		
		jr $ra
	
	
	atualizarObstaculos:
		addi $sp,$sp,-16
		sw $s0,($sp)
		sw $s1,4($sp)
		sw $s2,8($sp)
		sw $s3,12($sp)
		
		lw $s0,velObstaculos
		
		#obj1
		
		la $s1,obstaculo1
		
		lw $s2,8($s1)		#posicao de obs1
		
		add $s2,$s2,$s0		#incrementa posicao
		
		sw $s2,8($s1)		#guardar posicao
		
		
		
		#obj2
		
		la $s1,obstaculo2
		
		lw $s2,8($s1)		#posicao de obs1
		
		add $s2,$s2,$s0		#incrementa posicao
		
		sw $s2,8($s1)		#guardar posicao
		
		
		
		lw $s0,($sp)
		lw $s1,4($sp)
		lw $s2,8($sp)
		lw $s3,12($sp)
		addi $sp,$sp,16
		
		
		
		jr $ra
		
	
	#recebe a0:		a0 == 0 indica clear	||| 	a0 == 1 indica draw
	drawObstaculos:
		addi $sp,$sp,-44
		sw $s0,0($sp)
		sw $s1,4($sp)
		sw $s2,8($sp)
		sw $s3,12($sp)
		sw $t0,16($sp)
		sw $t1,20($sp)
		sw $t2,24($sp)
		sw $t3,28($sp)
		sw $t4,32($sp)
		sw $ra,36($sp)
		sw $a0,40($sp)
		
		la $s1,obstaculo1	#s1 == obs1
		la $s2,obstaculo2	#s2 == obs2
		
		# presente	||	tipo	||	pos_x
		#verificar atividade
		
		#desenho do 1
		
		la $t3,tiposDeObstaculos
		la $t4,alturaDoTipo
		
		lw $s0,0($s1)		#s0 == obs1 presente
		
		beq $s0,$zero,naoDesenha1
		
		#desenha1
		lw $t0,4($s1)	#tipo em t0
		sll $t0,$t0,2	#mult o tipo por 4 -> endereçamento
		
		add $t0,$t4,$t0		#end final
		
		lw $t0,($t0)		#t0 recebe a altura do obstaculo
		
		lw $t1,obstaculosWidth
		
		beq $a0,$zero,setarClear1
		
		lw $t2,obstaculosCor
		j saiClear1
		
		setarClear1:
		lw $t2,azul_fundo
		
		saiClear1:
		
		
		lw $t3,8($s1)		#t3 == posX
		
		lw $t4,bitmap_height
		
		sub $t4,$t4,$t0		#t4 recebe posicao y
		
		#arrumar argumentos para o desenho do obstaculo
		move $a0,$t2		#cor
		move $a1,$t1		#width
		move $a2,$t0		#altura
		move $a3,$t3		#pos x
		move $s0,$t4		#pos y
		
		lw $t0,bitmap_width
		add $t1,$a3,$a1
		
		bgt $t1,$t0,ajustarMaior
		blt $a3,$zero,ajustar
		j draw
		
		ajustar:
		add $a1,$a1,$a3		# pos + width
		li $a3,0
		j draw
		
		ajustarMaior:
		sub $t1,$t1,$t0
		sub $a1,$a1,$t1		#tirar tudo que sobrou para fora da tela
		j draw
		
		draw:
		jal drawRetangulo
		
		#alterar argumentos para o complemento do cano
		
		
		#set altura
		lw $t0,bitmap_height
		
		sub $t0,$t0,$a2
		
		lw $a2,gapHeight
		
		sub $a2,$t0,$a2
		###############
		
		#set pos y
		li $s0,0
		
		jal drawRetangulo
		
		naoDesenha1:
		
		
		
		#desenho do 2
		
		la $t3,tiposDeObstaculos
		la $t4,alturaDoTipo
		
		lw $s0,0($s2)		#s0 == obs2 presente
		
		beq $s0,$zero,naoDesenha2
		
		
		#desenha2
		lw $t0,4($s2)	#tipo em t0
		sll $t0,$t0,2	#mult o tipo por 4 -> endereçamento
		
		add $t0,$t4,$t0		#end final
		
		lw $t0,($t0)		#t0 recebe a altura do obstaculo
		
		lw $t1,obstaculosWidth
		
		lw $a0,40($sp)
		
		beq $a0,$zero,setarClear2
		
		lw $t2,obstaculosCor
		j saiClear2
		
		setarClear2:
		lw $t2,azul_fundo
		
		saiClear2:
		
		
		lw $t3,8($s2)		#t3 == posX
		
		lw $t4,bitmap_height
		
		sub $t4,$t4,$t0		#t4 recebe posicao y
		
		#arrumar argumentos para o desenho do obstaculo
		move $a0,$t2
		move $a1,$t1
		move $a2,$t0
		move $a3,$t3
		move $s0,$t4
		
		#ajustes para nao sair da tela
		lw $t0,bitmap_width
		add $t1,$a3,$a1
		
		bgt $t1,$t0,ajustarMaior2
		blt $a3,$zero,ajustar2
		j draw2
		
		ajustar2:
		add $a1,$a1,$a3		# pos + width
		li $a3,0
		j draw2
		
		ajustarMaior2:
		sub $t1,$t1,$t0
		sub $a1,$a1,$t1		#tirar tudo que sobrou para fora da tela
		j draw2
		
		draw2:
		jal drawRetangulo
		
		#alterar argumentos para o complemento do cano
		
		
		#set altura
		lw $t0,bitmap_height
		
		sub $t0,$t0,$a2
		
		lw $a2,gapHeight
		
		sub $a2,$t0,$a2
		###############
		
		#set pos y
		li $s0,0
		
		jal drawRetangulo
		
		
		
		
		
		naoDesenha2:
		
		
		
		lw $s0,0($sp)
		lw $s1,4($sp)
		lw $s2,8($sp)
		lw $s3,12($sp)
		lw $t0,16($sp)
		lw $t1,20($sp)
		lw $t2,24($sp)
		lw $t3,28($sp)
		lw $t4,32($sp)
		lw $ra,36($sp)
		lw $a0,40($sp)
		addi $sp,$sp,44
		
		jr $ra
	
	
	incPontos:
		addi $sp,$sp,-4
		sw $s0,0($sp)
		
		lw $s0,pontos
		
		addi $s0,$s0,1
		
		sw $s0,pontos
		
		lw $s0,0($sp)
		addi $sp,$sp,4
		
		jr $ra
	
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
		
		ble $s2,0,realocarPraZero	#se posicao nova < 0, voltar pra zero
		
		lw $s3,P_height
		lw $s1,bitmap_height
		sub $s3,$s1,$s3			#s3 = bit_height - p_height
		
		bge $s2,$s3,realocarPraBaixo
		
		
		sw $s2,P_posY			#else, sem problemas
		
		j ok
		
		
		realocarPraZero:
		
		sw $zero,P_posY
		
		j ok
		
		realocarPraBaixo:
		
		sw $s3,P_posY		#botar na posicao mais baixa possivel
		li $s1,1
		sw $s1,flagPerdeu	#se colidiu com a parte baixa (chao), setar flag de perdeu pra 1
		
		j ok
			
		
		ok:
		
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
	
	
	#a0 == cor ; a1 == width ; a2 == height ; a3 == x ; s0 == y
	drawRetangulo:
		addi $sp,$sp,-60
		sw $ra,($sp)
		sw $a0,4($sp)
		sw $a1,8($sp)
		sw $a2,12($sp)
		sw $s7,16($sp)
		sw $s6,20($sp)
		sw $t0,24($sp)
		sw $t1,28($sp)
		sw $t2,32($sp)
		sw $t3,36($sp)
		sw $t4,40($sp)
		sw $t5,44($sp)
		sw $t6,48($sp)
		sw $t7,52($sp)
		sw $a3,56($sp)
		
		
		li $t0,0
		li $t1,0
		move $t2,$a0		#t2 guarda a cor
		move $t3,$a1		#t3 == width
		move $t4,$a2		#t4 == height
		move $s6,$a3		#s6 = x
		
		lw $a1,bitmap_width
		lw $a2,bitmap_height
		
		mul $s7,$a1,$s0
		
		add $s7,$s7,$a3		#posicao linear bruta
	
		lw $a3,bitmap_address
		
		sll $s7,$s7,2		#posicao x 4
		
		add $s7,$s7,$a3		#s7 = 4 * (width * y + x) + bit_address
		
		
		
		
		loop_x2:
			beq $t3,$t0,sai_x2
			li $t1,0
			loop_y2:
				beq $t4,$t1,sai_y2
				
				add $t6,$t0,$s6		#x para printar
				add $t7,$t1,$s0		#y para printar
				
				mul $t7,$t7,$a1
				add $t7,$t6,$t7
				sll $t7,$t7,2
				
				
				add $t7,$a3,$t7		#t7 == endereço pra guardar a word de cor
				
				sw $t2,($t7)
				
				addi $t1,$t1,1   #inc y
			j loop_y2
			sai_y2:
			
			addi $t0,$t0,1	#inc x
		j loop_x2
		sai_x2:
		
		
				
		lw $ra,($sp)
		lw $a0,4($sp)
		lw $a1,8($sp)
		lw $a2,12($sp)
		lw $s7,16($sp)
		lw $s6,20($sp)
		lw $t0,24($sp)
		lw $t1,28($sp)
		lw $t2,32($sp)
		lw $t3,36($sp)
		lw $t4,40($sp)
		lw $t5,44($sp)
		lw $t6,48($sp)
		lw $t7,52($sp)
		lw $a3,56($sp)
		addi $sp,$sp,60
		
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
			
		drawAmareloGeral:
		
			#drawRetangulo
			lw $a0,amarelo_geral
			li $a1,4
			li $a2,3
			addi $a3,$t0,6
			addi $s0,$t1,3
			jal drawRetangulo
			
			#drawRetangulo
			lw $a0,amarelo_geral
			li $a1,5
			li $a2,1
			addi $a3,$t0,8
			addi $s0,$t1,2
			jal drawRetangulo
			
			#drawRetangulo
			lw $a0,amarelo_geral
			li $a1,1
			li $a2,6
			addi $a3,$t0,12
			addi $s0,$t1,3
			jal drawRetangulo
			
			#drawRetangulo
			lw $a0,amarelo_geral
			li $a1,1
			li $a2,3
			addi $a3,$t0,13
			addi $s0,$t1,6
			jal drawRetangulo
			
			#drawRetangulo
			lw $a0,amarelo_geral
			li $a1,2
			li $a2,2
			addi $a3,$t0,6
			addi $s0,$t1,6
			jal drawRetangulo
			
			#drawRetangulo
			lw $a0,amarelo_geral
			li $a1,2
			li $a2,3
			addi $a3,$t0,2
			addi $s0,$t1,4
			jal drawRetangulo
			
			#drawRetangulo
			lw $a0,amarelo_geral
			li $a1,1
			li $a2,3
			addi $a3,$t0,5
			addi $s0,$t1,4
			jal drawRetangulo
			
			
			#pixels
			addi $a1,$t0,14
			addi $a2,$t1,6
			jal drawPixel
			
			#pixels
			addi $a1,$t0,15
			addi $a2,$t1,6
			jal drawPixel
			
			#pixels
			addi $a1,$t0,15
			addi $a2,$t1,5
			jal drawPixel
			
			#pixels
			addi $a1,$t0,15
			addi $a2,$t1,4
			jal drawPixel
			
			#pixels
			addi $a1,$t0,16
			addi $a2,$t1,6
			jal drawPixel
			
			#pixels
			addi $a1,$t0,16
			addi $a2,$t1,5
			jal drawPixel
			
			#pixels
			addi $a1,$t0,16
			addi $a2,$t1,4
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
			addi $a1,$t0,10
			addi $a2,$t1,8
			jal drawPixel
			
			#pixels
			addi $a1,$t0,10
			addi $a2,$t1,3
			jal drawPixel
			
			#pixels
			addi $a1,$t0,1
			addi $a2,$t1,3
			jal drawPixel
			
			#pixels
			addi $a1,$t0,2
			addi $a2,$t1,3
			jal drawPixel
			
			#pixels
			addi $a1,$t0,1
			addi $a2,$t1,2
			jal drawPixel
			
			#pixels
			addi $a1,$t0,2
			addi $a2,$t1,2
			jal drawPixel
			
			#pixels
			addi $a1,$t0,2
			addi $a2,$t1,4
			jal drawPixel
			
			#pixels
			addi $a1,$t0,3
			addi $a2,$t1,4
			jal drawPixel
			
			#pixels
			addi $a1,$t0,2
			addi $a2,$t1,7
			jal drawPixel
			
			
			
			
		lw $ra,($sp)
		lw $a0,4($sp)
		lw $a1,8($sp)
		addi $sp,$sp,12
		
		jr $ra
	
	
	#wait some time
	wait:
		add		$sp, $sp, -8
		sw		$ra, 0($sp)
		sw		$t0, 4($sp)
		add		$ra, $zero, $zero
		addi	$t0, $zero, 9000

		## 50000
		## 100000
	
	wait_loop:		
		beq		$ra, $t0, wait_loop_end
		addi	$ra, $ra, 1		# i++
		j		wait_loop
		
	wait_loop_end:
		lw		$ra, 0($sp)
		lw		$t0, 4($sp)
		add		$sp, $sp, 4
		jr		$ra
		
	
	
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
