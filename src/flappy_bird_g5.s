#Universidade de Brasília
#Organização e Arquitetura de Computadores - Turma: A - 1º/2014
#Projeto Aplicativo - FlappyMIPS
#Flappy Fish - Grupo 5 - Integrantes:
#João Vitor A.Ribeiro - 12/0014491
#João Henrique Sousa - 11/0014171
#Pedro Paulo Struck Lima - 11/0073983
#Yurick Hauschild Caetano da Costa - 12/0024136
# versão: 0.02 - Editado pela última vez por João V.

.data

	#variaveis do jogo
	
	#PLAYER
	P_posY:		.word		100			#afetada pela gravidade
	P_posX:		.word		70			#nunca mais sera mudada
	P_velY:		.word		0			#inicialmente parado até receber input
	
	bmp_address: .word 0x10040000 # Setado para testar no MARS
	bmp_width:   .word 512
	bmp_height:  .word 512
.text
	
	init:
		addi $sp,$sp,-4
		sw $ra,0($sp)
		
		add $s7,$zero,$zero #s7 guarda pontuacao. Pontos = 0.
		
		jal clearScreen # Limpar a tela e printar fundo
		
		jal loop_principal # comecar o loop do jogo
		
	spawn_esponjas:
		li $a0,0 	#syscall para gerar um aleatorio entre {0,1,2,3} em $a0 talvez necessite de adaptar para implementar
		li $a1,4	#no MIPS @DE2-70
		li $v0,42
		syscall
	
		move $t6,$a0 # $t6 = tipo de conjunto de esponjas a serem printadas
		
		jal draw_img 	# chamar a funcao de desenhar imagem. Talvez seja preciso converter $t6 para um indice (endereco),
				# se todas as imagens do jogo foram indexadas (ou mudar t6 para o indice de draw_img)
				
		jr $ra		# jal's,jr's e j's podem estar incorretos	 
				#Cuidar com salvar/ler $ra na pilha, caso preciso
	loop_principal:
		
				# Pendente: fisica do peixe, chao se movimentando
				
		jal spawn_esponjas
		
				#chamar rotina que verifica colisao? como implementar? (Ideia: chama colision que verifica se os pixels
				# do peixe estao dentro do espaco em que nao ha esponjas, para o par de esponjas que foi gerado.
				#Usa o valor de t6 que define o par para poder verificar essa colisao. colision retorna em $v0 = 0 se
				# nao houve colisao e 1 caso contrario.
		
		
		bnez $v0,init # se houve colisao limpa a tela, zera os pontos e comeca o jogo de novo? se nao adaptar para "botoes
				# reiniciar ou sair do jogo
		
		addi $t7,$t7,1 # se nao incrementa a pontuacao e printa na tela
				
		#jal print score implementar print score
		
		j loop_principal
	
	
	
	draw_img: #Funcao generica de printar img
		
		jr $ra
	
	#clear screen com a cor do fundo padrao
	clearScreen:
	
		jr $ra
		
	exit: # no caso de menu RECOMEÇAR,SAÍDA
		li $v0,10
		syscall
