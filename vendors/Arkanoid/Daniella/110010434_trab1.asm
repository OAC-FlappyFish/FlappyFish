####################################################################
## Trabalho 1 - Organizacao e Arquitetura de Computadores Turma C ##
####################################################################
## Daniella Albuquerque dos Angelos - 11/0010434		  ##
####################################################################
## Display grafico mapeado em memoria 				  ##
####################################################################

.data

# VARIAVEIS DE GERENCIAMENTO DO DISPLAY
bitmap_address: .word 0x10040000
bitmap_width:   .word 512
bitmap_height:  .word 512

# STRINGS DE INTERFACE COM O USUARIO: #
menutitle:	.asciiz "\n\n*** Menu Principal ***\n\n"
menu:		.asciiz "1. Setar cor padrao \n2. Desenhar ponto \n3. Desenhar linha \n4. Desenhar retangulo \n5. Preencher retangulo \n6. Desenhar circulo \n7. Sair\n"
info:		.asciiz "\nInforme o numero da opcao desejada: "
pointstr:	.asciiz "\nInforme as coordenadas x e y do ponto: "
linestr:	.asciiz "\nInforme o ponto inicial, x0 e y0, e o ponto final, x1 e y1 da linha: "
rectstr:	.asciiz "\nInforme o ponto inicial, x e y, a largura l e altura a do retangulo, respectivamente: "
circlestr:	.asciiz "\nInforme o centro x e y do circulo, e seu raio r: "
colorstr:	.asciiz "\nInforme a cor desejada: \n1. Branco \n2. Azul \n3. Vermelho \n4. Verde \n5. Amarelo \n6. Inserir codigo de outra cor\n"
colorstr1:	.asciiz "\nInforme a quantidade de vermelho (0-255): "
colorstr2:	.asciiz "\nInforme a quantidade de verde (0-255): "
colorstr3:	.asciiz "\nInforme a quantidade de azul (0-255): "
errormessage:	.asciiz "Opcao invalida! Tente novamente.\n"

# CORES DEFAULT
white:		.word 0xffffff		# cores default #
blue:		.word 0x0000ff
red:		.word 0xff0000
green:		.word 0x00ff00
yellow:		.word 0xffff00

.text
	lw $s2, blue			# Define uma cor default, caso o usuario nao defina alguma
	
main:	
	li $v0, 4			# Carrega as strings de opcoes do menu princial #
	la $a0, menutitle
	syscall
	la $a0, menu
	syscall
	la $a0, info
	syscall
	
	li $v0, 5			# Input do usuario com a opcao desejada #
	syscall
	add $t0, $v0, $0		# Insere o input do usuario no temporario $t0
	
	li $t1, 7			# Verificacao #
	beq $t0, $t1, exit
	
	li $t1, 1
	beq $t0, $t1, setcolor
	
	li $t1, 2
	beq $t0, $t1, setpoint
	
	li $t1, 3
	beq $t0, $t1, setline
	
	li $t1, 4
	beq $t0, $t1, setrect
	
	li $t1, 5
	beq $t0, $t1, setrect
	
	li $t1, 6
	beq $t0, $t1, setcircle
	
	li $v0, 4
	la $a0, errormessage
	syscall
	
	j main				# Loop infinito #

exit:
	li $v0, 10
	syscall

setcolor:
	li $v0, 4
	la $a0, colorstr
	syscall
	la $a0, info
	syscall
	
	li $v0, 5
	syscall
	add $t0, $v0, $0
	
	li $t1, 1
	beq $t0, $t1, whited
	
	li $t1, 2
	beq $t0, $t1, blued
	
	li $t1, 3
	beq $t0, $t1, vermelhod
	
	li $t1, 4
	beq $t0, $t1, verded
	
	li $t1, 5
	beq $t0, $t1, amarelod
	
	li $t1, 6
	beq $t0, $t1, getcode

	whited:
	lw $s2, white
	j main
	
	blued:
	lw $s2, blue
	j main
	
	vermelhod:
	lw $s2, red
	j main
	
	verded:
	lw $s2, green
	j main
	
	amarelod:
	lw $s2, yellow
	j main
	
	getcode:
	li $v0, 4
	la $a0, colorstr1
	syscall
	li $v0, 5
	syscall
	add $t0, $v0, $0	# pega o codigo vermelho da cor
	
	li $v0, 4
	la $a0, colorstr2
	syscall
	li $v0, 5
	syscall
	add $t1, $v0, $0	# pega o codigo verde da cor	
	
	li $v0, 4
	la $a0, colorstr3
	syscall
	li $v0, 5
	syscall
	add $t2, $v0, $0	# pega o codigo azul da cor
	
	sll $t1, $t1, 8		# coloca o vermelho na posicao mais significativa
	sll $t0, $t0, 16	# coloca o verde no meio 
	add $s2, $t0, $t1	# soma o vermelho e o verde obtendo RRGG00
	add $s2, $s2, $t2	# soma o azul, obtendo RRGGBB
	
	j main	

drawpoint:
	add $t6, $zero, $zero	# zerando lixo de memoria ##
	add $t7, $zero, $zero
	add $t8, $zero, $zero
	add $t9, $zero, $zero
	
	lw $t6, bitmap_height
  	lw $t7, bitmap_width
  	
  	bge $s0, $t7, drawpoint_return
   	blt $s0, 0, drawpoint_return
   	bge $s1, $t6, drawpoint_return
   	blt $s1, 0, drawpoint_return
  	
  	li $t6, 4 		# 4 = espaco ocupado por uma word
   	multu $t6, $t7
   	mflo $t7 		# espaco ocupado por uma linha
   
 	mult $s0,$t6		# deslocamento pela coluna
  	mflo $t8 		# $t8 = deslocamento pela coluna
   
   				
   	mult $s1,$t7 		# calculo do deslocamento da linha
   	mflo $t9		# y*width
   
  	
   	add $t8,$t8,$t9		# calculo do deslocamento final
   
	sw $s2,bitmap_address($t8)	# desenho: escrever a cor na posicao de memoria calculada
	
	drawpoint_return:
	jr $ra

setpoint:
	li $v0, 4		# ##   	#    ## #
	la $a0, pointstr	#		#
	syscall			#		#
				#	#	#
	li $v0, 5		#     INPUT     #
	syscall			#	#	#
	add $s0, $v0, $0	#		#
	li $v0, 5		#		#
	syscall			#		#
	add $s1, $v0, $0	# ##    #    ## #
		
	jal drawpoint		# desenhar ponto em (x,y)
	
	j main

drawline:			
	addi $sp, $sp, -4	# abre espaco na pilha
	sw $ra, 0($sp)		# guarda o valor do endereco de retorno no topo da pilha
	
	add $t0, $zero, $zero	# zerando lixo de memoria ##
	add $t1, $zero, $zero	
	add $t2, $zero, $zero	
	add $t3, $zero, $zero	
	add $t4, $zero, $zero	
	add $t5, $zero, $zero	
	
	##### ALGORITMO DE BRESENHAM ######
	sub $t0, $s0, $s3	# $t0 = x1 - x2
	abs $t0, $t0		# dx = abs(x1 - x2)
	blt $s0, $s3, sx
	addi $t2, $t2, -1	# sx = -1
	j next1
	sx:
	addi $t2, $t2, 1	# sx = 1
	next1:
	sub $t1, $s1, $s4	# $t1 = y1 - y2
	abs $t1, $t1		# dy = abs(y1 - y2)
	blt $s1, $s4, sy	# $t1 < 0 ?
	addi $t3, $t3, -1	# sy = -1
	j next2
	sy:
	addi $t3, $t3, 1	# sy = 1
	next2:
	sub $t4, $t0, $t1	# err = dx - dy
	
	##### LOOP DE DESENHO #####
	plotline:
	jal drawpoint
	beq $s0, $s3, itWill
	j next4
	itWill:
	beq $s1, $s4 drawline_return	# condicao de saida do loop: x0 == x1 && y0 == y1
	next4:
	sll $t5, $t4, 1			# e2 = 2*err
	sub $a3, $zero, $t1		# $a3 = -dy
	bgt $t5, $a3, incX		# e2 > -dy ?
	j next5
	incX:
	sub $t4, $t4, $t1		# erro = -dy
	add $s0, $s0, $t2		# x = x + sx
	next5:
	blt $t5, $t0, incY		# e2 < dx
	j plotline
	incY:
	add $t4, $t4, $t0		# err = err + dx
	add $s1, $s1, $t3		# y = y + sy
	j plotline
	
	drawline_return:
	lw $ra, 0($sp)		# recupera o antigo endereco de retorno
	addi $sp, $sp, 4	# desaloca o espaco da pilha
	jr $ra			# jump to $ra, onde a funcao foi chamada em primeiro lugar

setline:
	li $v0, 4
	la $a0, linestr
	syscall
	
	li $v0, 5
	syscall
	add $s0, $v0, $0	# x0 = input
	
	li $v0, 5
	syscall
	add $s1, $v0, $0	# y0 = input
	
	li $v0, 5
	syscall
	add $s3, $v0, $0	# x1 = input
	
	li $v0, 5
	syscall
	add $s4, $v0, $0	# y1 = input
	
	jal drawline
	
	j main

drawrect:
	addi $sp, $sp, -20	# abre espaco na pilha
	sw $ra, 16($sp)		# armazena o valor do endereco de retorno
	sw $s6, 12($sp)		# armazena o valor da altura do retangulo na pilha
	sw $s5, 8($sp)		# armazena a largura do retangulo na pilha
	sw $s1, 4($sp)		# armazena o valor de y0 na pilha
	sw $s0, 0($sp)		# armazena o valor de x0, na pilha
	
	# $s0 = x0, $s1 = y0, $s3 = x1, $s4 = y1, $s5 = l, $s6 = a	
		
	add $s3, $s1, $s5	# x1 = x0 + l
	add $s4, $s1, $zero	# y1 = y0
	jal drawline		# drawline (x,y,x+l,y)
	
	lw $s0, 0($sp)		# recupera o valor de x0
	lw $s1, 4($sp)		# recupera o valor de y0
	
	add $s3, $s0, $zero	# x1 = x0
	add $s4, $s6, $s4	# y1 = a + y0
	jal drawline		# drawline (x,y,x,y+a)
	
	lw $s0, 0($sp)		# recupera o valor de x0
	lw $s1, 4($sp)		# recupera o valor de y0
	
	add $s1, $s1, $s6	# y0 = y0 + a
	add $s3, $s3, $s5	# x1 = x1 + l
	jal drawline		# drawline (x,y+a,x+l,y+a)
	
	lw $s0, 0($sp)		# recupera o valor de x0
	lw $s1, 4($sp)		# recupera o valor de y0
	
	add $s0, $s0, $s5	# x0 = x0 + l
	jal drawline		# drawline(x+l,y,x+l,y+a)

	drawrect_return:
	lw $ra, 16($sp)
	addi $sp, $sp, 20
	jr $ra
	
drawfillrect:
	addi $sp, $sp, -12	# reservar espaco na pilha
	sw $ra,8($sp)		# guardar o endereco de retorno na pilha
	
	sw $s1, 4($sp)		# guarda o valor de y0 na pilha
	sw $s0, 0($sp)		# guarda o valor de x0 na pilha
	
	add $v0, $s0, $s5	# $a2 = x + l
	add $s3, $s0, $zero
	add $s4, $s1, $s6	# $s4 = y + a
	
	rfillLoop:
	bgt $s0, $v0, drawfillrect_return
	lw $s1, 4($sp)
	jal drawline
	lw $s0, 0($sp)
	addi $s0, $s0, 1
	addi $s3, $s3, 1
	sw $s0, 0($sp)
	j rfillLoop
	
	
	drawfillrect_return:
	lw $ra, 8($sp)
	addi $sp, $sp, 12
	jr $ra

setrect:
	# Am I a filled rectangle or just its contour?
	
	addi $sp, $sp, -4
	sw $t0, 0($sp)
	
	li $v0, 4
	la $a0, rectstr
	syscall
	
	li $v0, 5
	syscall
	add $s0, $v0, $0	# x = input
	
	li $v0, 5
	syscall
	add $s1, $v0, $0	# y = input
	
	li $v0, 5
	syscall
	add $s5, $v0, $0	# l = input
	
	li $v0, 5
	syscall
	add $s6, $v0, $0	# a = input
	
	li $t1, 5		# esta secao define se devo desenhar o contorno do retangulo, ou o mesmo preenchido
	sub $t1, $t0, $t1	# usando o registrador que contem a opcao do usuario no menu principal
	bltzal $t1, drawrect
	lw $t0, 0($sp)
	li $t1, 4
	sub $t1, $t1, $t0
	bltzal $t1, drawfillrect
	
	j main	
	
drawcircle:
	addi $sp, $sp, -12	# abre espaco na pilha
	sw $ra, 8($sp)		# guarda o endereco de retorno na pilha
	sw $s1, 4($sp)		# guarda o valor de y0 na pilha
	sw $s0, 0($sp)		# guarda o valor de x0 na pilha
	
	add $t0, $zero, $zero	# zerando lixo de memoria ##
	add $t1, $zero, $zero
	add $t5, $0, $0
	
	addi $v0, $zero, 1
	sub $v0, $v0, $s7	# erro = 1 - raio
	
	add $t0, $s7, $0	# x = raio
	add $t1, $0, $0		# y = 0
	
	circleloop:
	blt $t0, $t1, drawcircle_return
	
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	
	add $s0, $s0, $t0	# x + x0
	add $s1, $s1, $t1	# y + y0
	jal drawpoint		# drawpoint(x+x0, y+y0)
	
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	
	add $s0, $s0, $t1	# y + x0
	add $s1, $s1, $t0	# x + y0
	jal drawpoint
	
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	
	sub $s0, $s0, $t0	# -x + x0
	add $s1, $s1, $t1	# y + y0
	jal drawpoint
	
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	
	sub $s0, $s0, $t1	# -y + x0
	add $s1, $s1, $t0	# x + y0
	jal drawpoint
	
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	
	sub $s0, $s0, $t0	# -x + x0
	sub $s1, $s1, $t1	# -y + y0
	jal drawpoint
	
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	
	sub $s0, $s0, $t1	# -y + x0
	sub $s1, $s1, $t0	# -x + y0
	jal drawpoint
	
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	
	add $s0, $s0, $t0	# x + x0
	sub $s1, $s1, $t1	# -y + y0
	jal drawpoint
	
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	
	add $s0, $s0, $t1	# y + x0
	sub $s1, $s1, $t0	# -x + y0
	jal drawpoint
	
	addi $t1, $t1, 1
	
	bltz $v0, rErr		# if rerr  < 0
	addi $t0, $t0, -1	# x --
	sub $t5, $t1, $t0	# $t5 = y - x
	addi $t5, $t5, 1	# $t5 = y - x + 1
	add $t5, $t5, $t5	# t5 = 2*$t5
	add $v0, $v0, $t5	# err = 2*(y - x + 1)
	j circleloop
	rErr:
	add $t5, $t1, $t1	# 2*y
	addi $t5, $t5, 1	# + 1
	add $v0, $v0, $t5	# err = err + 2*y + 1
	j circleloop	
	
	drawcircle_return:
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $ra, 8($sp)		# recupera o endereco de retorno da funcao original
	addi $sp, $sp, 12
	jr $ra

setcircle:
	li $v0, 4
	la $a0, circlestr
	syscall
	
	li $v0, 5
	syscall
	add $s0, $v0, $0	# x = input
	
	li $v0, 5
	syscall
	add $s1, $v0, $0	# y = input
	
	li $v0, 5
	syscall
	add $s7, $v0, $0	# r = input
	
	jal drawcircle
	
	j main
