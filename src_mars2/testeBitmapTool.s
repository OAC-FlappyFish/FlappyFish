# teste do BitMap display tool configurado para mostrar cores na codificação 8 bits da DE2-70  GGBBBRRR  320x240
.data   #só para testar o MIFexporte
UM: .byte 1,2,3,4,5,6,7,8,9,10

.text

la $t3,0xff000000   # Endereço da memória VGA
li $t2,256  # Número de cores para mostrar
li $t1,0  # Contador do endereço
li $t0,0x00  # Contador de cor

LOOP:
sb $t0,0($t3)     #imprime 8 linhas com a mesma cor $t0
sb $t0,320($t3)
sb $t0,640($t3)
sb $t0,960($t3)
sb $t0,1280($t3)
sb $t0,1600($t3)
sb $t0,1920($t3)
sb $t0,2240($t3)

la $t1,UM   # so para testar
lw $t1,0($t1)
addi $t3,$t3,1
addi $t0,$t0,1

bne $t2,$t1,LOOP

li $v0,10
syscall

FIM: j FIM