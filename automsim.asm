#Simulador de Autômatos Finitos, por Ayrton Cavalieri de Almeida
#Este programa tem o intuito de utilizar autômatos finitos, determinísticos ou não-determinísticos, para validação
#de cadeia de caracteres. Para isso, ele utiliza um grafo, onde fica expresso o autômato que realizará
#o teste, e uma cadeia de caracteres contendo a sentença a ser testada.
#Entradas: Teclado
#Saídas: Monitor
	.data
vet:	.word 0
nln:	.asciiz "\n"
nulc:	.asciiz "\0"
chs:	.asciiz "s"
chn:	.asciiz "n"
eps:	.asciiz "?"
ins0:	.asciiz "Informando parâmetros do estado: "
ins1:	.asciiz "É inicial?\n(0 - Não 1 - Sim)\n"
ins2:	.asciiz	"É final?\n(0 - Não 1 - Sim)\n"
ins3:	.asciiz "Informe o caracter de transição:(? = Épsilon)\n"
ins4:	.asciiz	"Informe o estado destino:\n"
ins5:	.asciiz "Deseja inserir outra transição?\n(s - SIM n - NÃO)\n"
ins6:	.asciiz	"Deseja inserir transições?\n(s - SIM n - NÃO)\n"
asktst:	.asciiz "Digite a cadeia para teste, ou \"exit\" para sair:\n"
gratam:	.asciiz	"Digite a quantidade de estados:\n"
ext:	.asciiz "exit"
chok:	.asciiz "Cadeia reconhecida!\n"
chinv:	.asciiz "Cadeia inválida!\n"
chain:	.byte 0:201

	.text
	.globl main
	
	jal main
	li $v0, 10
	syscall
	
main:
	subu $sp, $sp, 8
	sw $ra, 0($sp)
	
	la $a0, gratam	
	jal prints	#Imprime a mensagem perguntando o tamanho do grafo
	li $v0, 5
	syscall		#Lê um inteiro com o tamanho do grafo
	
	sw $v0, 4($sp)	#Armazena a quantidade de estados localmente
	
	jal inigra #Inicializa o grafo. $v0 recebe a quantidade de estados e retorna o endereço do grafo inicializado
	sw $v0, vet
	
	lw $v0, vet	#Inserir estados, $v0 recebe o endereço do vetor de ponteiros
	lw $a0, 4($sp)	#$a0 recebe a quantidade de estados
	jal insest
Repete:
	la $a0, asktst	
	jal prints	#Imprime a mensagem pedindo para escrever uma cadeia de caracteres
	la $a0, chain
	li $a1, 201
	jal scans	#Lê a cadeia de caracteres com tamanho até 200
	
	la $v0, chain
	jal extpro	#Checa se foi digitada a cadeia de saída, a resposta retorna em $v0
	
	bne $v0, $zero, Fimpro	#Sai do programa caso o teste tenha dado VERDADEIRO
	
	lw $a0, vet
	lw $a1, 4($sp)	
	la $a2, chain
	jal fndini	#Inicia o teste da cadeia, $a0 recebe o endereço do vetor de ponteiros
			#$a1 recebe a quantidade de estados, $a2 recebe o endereço do vetor de char
			#$v0 recebe 1 caso o teste tenha dado VERDADEIRO e 0 caso FALSO
	bne $v0, $zero, Chok
	la $a0, chinv	
	jal prints	#Caso o teste tenha sido FALSO, imprime mensagem avisando
	j Rpt
Chok:	
	la $a0, chok
	jal prints	#Caso o teste tenha sido VERDADEIRO, imprime a mensagem avisando
	
Rpt:
	j Repete
	
Fimpro:
	lw $ra, 0($sp)
	addu $sp, $sp, 8
	jr $ra

extpro: #Função para testar se a palavra de saída foi digitada. Recebe o endereço do vetor em $v0
	#Retorna 1 em $v0 caso o teste seja verdadeiro
	li $t7, 4	#Copio o tamanho da palavra
	addu $t6, $zero, $zero	#Inicializo o contador
	la $s0, ext	#Pego o endereço da palavra "exit"
Lopext: beq $t6, $t7, OK
	lb $t0, 0($s0)	#Leio do vetor ext
	lb $t1, 0($v0)	#Leio do vetor fornecido pelo usuário
	bne $t0, $t1, Fail	#Caso sejam diferentes, o teste pára
	addu $s0, $s0, 1	#Vai pra próxima posição do vetor ext
	addu $v0, $v0, 1	#Vai pra próxima posição do vetor fornecido pelo usuário
	addu $t6, $t6, 1	#Soma 1 no contador
	j Lopext
OK:	
	li $v0, 1
	j Extfun
Fail:
	li $v0, 0
Extfun:
	jr $ra

tstcad: #Função para testar cadeia.
	#$a0 recebe o endereço do grafo, $a1 recebe número do estado inicial(ou atual da chamada),
	#$a2 recebe o endereço do vetor com a cadeia pra teste. 
	#Resposta V ou F retornando em $v0
	subu $sp, $sp, 20
	sw $ra, 0($sp)
	
	sw $a0, 4($sp)	#Salva o endereço inicial do grafo
	
	li $t0, 4	#Carrega o "size of"
	multu $a1, $t0
	mflo $t0	#Multiplica o índice pelo "size of" para descobrir a posição do vetor que deve ser lida
	addu $t0, $a0, $t0	#Desloca o endereço
	sw $t0, 8($sp)	#Salva na memória
	
	sw $a2, 12($sp)	#Salva o apontamento do vetor de char
	
	lb $t0, 0($a2)	#Carrega caracter do vetor de char
	lw $t1, 8($sp)	#Carrega o apontamento do estado no grafo
	lw $t1, 0($t1)	#Carrega o endereço do nó da lista
	lw $t7, 8($t1)	#Carrega a flag de final
	sw $t7, 16($sp)	#Armazena a flag
	
	bne $t0, $zero, Notnul	#Desvia se não estiver no fim do vetor, ou seja, se o caracter não é 0
	
Loptst: beq $t1, $zero, Noeps	#Loop para testar se acha transição épsilon, desvia se chegar ao fim da lista
	lb $s0, eps	#Carrega o caracter épsilon pra teste
	lw $s1, 0($t1)	#Carrega caracter de transição armazenado na lista
	bne $s0, $s1, Nxtst	#Vai para o proximo estado se não for épsilon
	sw $t1, 8($sp)	#Salva o endereço do nó da lista
	lw $a0, 4($sp)	#Carrega o endereço do grafo
	lw $a1, 4($t1)	#Carrega o estado de destino
	lw $a2, 12($sp)	#Carrega o apontamento do vetor de char
	jal tstcad	#Chamada recursiva
	lw $t1, 8($sp)	#Carrega o nó que foi salvo
Nxtst:
	lw $t1, 16($t1)	#Carrega o *prox do nó
	j Loptst
Noeps:
	lw $t7, 16($sp)	#Carrega a flag de final armazenada localmente
	beq $t7, $zero, Exttst
	addu $v0, $t7, $zero	#Copia o parâmetro pra registro de retorno $v0
	j Exttst	#Sai da função
	
Notnul:	#Parte que é executada quando não se chegou ao fim da cadeia de caracteres
	#$t0 está com o caracter da chamada
Loptst2:beq $t1, $zero, Exttst
	bne $v0, $zero, Exttst	#Para o loop se a aceitação foi encontrada
	lw $t2, 0($t1)	#Carrega o caracter de transição da lista
	bne $t0, $t2, Tsteps
	sw $t1, 8($sp)	#Salva o nó atual da lista
	lw $a0, 4($sp)	#Carrega o endereço do grafo
	lw $a1, 4($t1)	#Carrega o estado de destino
	lw $a2, 12($sp)
	addu $a2, $a2, 1	#Carrega o endereço do vetor e soma 1 byte
	jal tstcad	#Chamada recursiva
	lw $t1, 8($sp)	#Carrega o nó atual da lista
	j Nxtst2
Tsteps:
	lb $t0, eps	#Carrega o caracter épsilon
	bne $t0, $t2, Nxtst2	#Desvia se não for épsilon
	sw $t1, 8($sp)	#Salva o nó atual da lista
	lw $a0, 4($sp)	#Carrega o endereço do grafo
	lw $a1, 4($t1)	#Carrega o estado de destino
	lw $a2, 12($sp)	#Carrega o endereço do vetor de char
	jal tstcad	#Chamada recursiva
	lw $t1, 8($sp)	#Carrega o nó atual da lista
Nxtst2:
	lw $t0, 12($sp)	#Carrega endereço armazenado
	lb $t0, 0($t0)	#Carrega o caracter
	lw $t1, 16($t1)	#Carrega o *prox da lista
	j Loptst2
	
Exttst: lw $ra, 0($sp)
	addu $sp, $sp, 20
	jr $ra

fndini: #Função para encontrar o estado inicial e começar o teste.
	#$a0 recebe o endereço do grafo, $a1 recebe a quantidade de estados, $a2 recebe endereço do 
#vetor com a cadeia pra teste
	subu $sp, $sp,4
	sw $ra, 0($sp)
	
	addu $t0, $a0, $zero	#Copia o endereço do grafo	
	addu $t2, $a1, $zero	#Copia a quanidade de estados
	addu $t1, $zero, $zero	#Inicializa o contador
Lopfnd: beq $t1, $t2, Extfnd
	lw $s0, 0($a0)	#Carrega o endereço apontado por $a0
	lw $t3, 12($s0)	#Carrega o bool "inicial"
	beq $t3, $zero, Jumpfnd
	add $a1, $t1, $zero	#Copia o índice do estado inicial para o parâmetro $a1
	add $v0, $zero, $zero	#Zera o registrador $v0 para receber a resposta de aceitação de cadeia
	jal tstcad	#Chama tstcad
	j Extfnd	#Sai do loop
	
Jumpfnd:	
	addu $a0, $a0, 4	#Aponta pra próxima posição do grafo
	addu $t1, $t1, 1	#Vai para o próximo estado
	j Lopfnd
Extfnd:
	lw $ra, 0($sp)
	addu $sp, $sp, 4
	jr $ra

insest: #Escreve os estados do grafo. $v0 recebe endereço do vetor, $a0 recebe a quantidade de estados
	subu $sp, $sp, 36	#Cria espaço no stack para o $ra e para os parâmetros
	sw $ra, 0($sp)	#Salva o $ra no início do espaço reservado
	
	sw $v0, 4($sp)	#Salva o endereço do vetor no stack
	addu $s0, $v0, $zero	#Copia o endereço inicial do vetor
	sw $a0, 8($sp)	#Salva a quantidade de estados no stack
	addu $s3, $a0, $zero	#Copia a quantidade de estados
	sw $zero, 12($sp)	#Salva o valor inicial do contador
	addu $s2, $zero, $zero	#Inicializa o contador
	sw $zero, 32($sp)	#Flag de "estado inicial configurado" assume valor 0
	
Loopins:beq $s2, $s3, Fimins	#Desvia ao chegar ao fim do vetor de estados

	la $a0, ins0 
	li $v0, 4	#Imprime a mensagem perguntando qual o estado
	syscall
	addu $a0, $s2, $zero	#Copia o número do estado sendo lido
	addu $a0, $a0, 1	#Soma 1 para visualização natural
	li $v0, 1
	syscall
	la $a0, nln
	li $v0, 4
	syscall		#Imprime a nova linha
	
	lw $s7, 32($sp)	#Carrega flag avisando se o estado inicial já foi setado
	sw $zero, 28($sp)	#Zera o parâmetro inicial
	bne $s7, $zero, Inicset
	
	la $a0, ins1
	li $v0, 4
	syscall		#Imprime mensagem perguntando se é inicial
	li $v0, 5	#Pergunta se é "inicial"
	syscall
	sw $v0, 28($sp)	#Salva o parâmetro "inicial" no stack
	sw $v0, 32($sp)	#Modifica a flag

Inicset: #Ponto de desvio se o inicial já foi setado
	la $a0, ins2
	li $v0, 4
	syscall		#Imprime mensagem perguntando se é final
	li $v0, 5	#Pergunta se é "final"
	syscall
	sw $v0, 24($sp)	#Salva o parâmetro "final" no stack
	
	addu $t0, $zero, $zero
	addu $t7, $zero, 1
	
	la $a0, ins6
	jal prints	#Imprime a mensagem perguntando se deseja inserir transições
	
	la $a0, 16($sp)	
	li $a1, 2
	jal scans	#Recebe resposta perguntando se deseja inserir transições
	la $a0, nln
	jal prints
	lb $t3, 16($sp)	#Carrega a resposta
	lb $t4, chn	#Carrega caracter 'n'
	bne $t3, $t4, Agn	#Vai para o Loop de inserção de transições, caso contrário, insere uma transição NULL
	sw $zero, 16($sp)	#Carrega o caracter de transição NULL
	sw $zero, 20($sp)	#Carrega transição "Zero"
	lw $v0, 0($s0)	#Lê o endereço armazenado na posição do vetor
	la $a0, 16($sp)	#Carrega o endereço onde começa os parâmetros
	jal inslis	#Chama inslis
	lw $s0, 4($sp)	#Carrega posição atual
	sw $v0, 0($s0)	#Salva o enderço no vetor
	j Ext
	
Agn:	beq $t0, $t7, Ext	#Loop para inserir transições no mesmo estado
	
	la $a0, ins3
	li $v0, 4
	syscall		#Imprime mensagem perguntando qual o caracter de transição
	la $a0, 16($sp)	#Informa o endereço do caracter de transição
	li $a1, 2	#Indica o tamanho do buffer
	jal scans	#Chama scans, parâmetro já está salvo na memória
	
	la $a0, nln
	li $v0, 4
	syscall		#Imprime uma nova linha
	
	la $a0, ins4
	li $v0, 4
	syscall		#Imprime mensagem perguntando qual a transição de destino
	li $v0, 5	#Informa o destino
	syscall
	subu $v0, $v0, 1
	sw $v0, 20($sp)	#Salva o parâmetro "destino" no stack
	
	lw $v0, 0($s0)	#Lê o endereço armazenado na posição do vetor
	la $a0, 16($sp)	#Carrega o endereço onde começa os parâmetros
	jal inslis	#Chama inslis
	lw $s0, 4($sp)	#Carrega posição atual
	sw $v0, 0($s0)	#Salva o enderço no vetor
	
	la $a0, ins5
	li $v0, 4
	syscall		#Imprime mensagem perguntando se deseja inserir mais transições
	
	lb $t7, chn	#Carrega o caracter 'n'
	la $a0, 16($sp)	#Com os parâmetros já salvos na lista, reuso espaço do char de transição para resposta do usuário
	li $a1, 2
	jal scans
	lb $t0, 16($sp)	#Carrega a resposta do usuário
	
	la $a0, nln
	li $v0, 4
	syscall		#Imprime uma nova linha
	j Agn
Ext:

	sb $zero, 16($sp)

	lw $s2, 12($sp)	#Carrego o contador
	addu $s2, $s2, 1	#Somo 1 ao contador
	sw $s2, 12($sp)	#Atualiza o contador na memória
	
	lw $s0, 4($sp)	#Lê a posição atual do vetor
	addu $s0, $s0, 4	#Aponta pra próxima posição
	sw $s0, 4($sp)	#Atualiza posição atual na memória
	
	lw $s3, 8($sp)	#Carrega o total de estados para comparar
	
	j Loopins
	
Fimins:
	lw $ra, 0($sp)	#Recupera o $ra
	addu $sp, $sp, 36	#Retorna o espaço
	jr $ra

inslis: #Cria um nó e liga à lista. $v0 recebe o "*prox" e retorna o endereço do novo nó, 
#$a0 recebe o endereço com as variáveis locais pertencentes a função que chamou
	subu $sp, $sp, 12
	sw $ra, 0($sp)
	
	sw $v0, 4($sp)	#Salva o "*prox"
	
	sw $a0, 8($sp)	#Salva o endereço com as variáveis locais pertencentes a função que chamou
	
	li $v0, 1	#Passa o multiplicador setando pra criar 1 nó, malloc vai retornar o endereço em $v0
	li $a0, 20	#Pede 20 bytes de espaço
	jal malloc	#Chama malloc
	
	lw $s0, 4($sp)	#Carrega o "*prox" salvo
	sw $s0, 16($v0)	#Armazena o "*prox" no struct
	
	lw $a0, 8($sp)	#Carrega o endereço com as variáveis locais pertencentes a função que chamou
	
	lb $s0, 0($a0)	#Carrega o caracter de transição
	sw $s0, 0($v0)	#Salva caracter no novo nó criado
	
	lw $s0, 4($a0)	#Carrega o destino
	sw $s0, 4($v0)	#Salva o destino no nó da lista
	
	lw $s0, 8($a0)	#Carrega o bool "final"
	sw $s0, 8($v0)	#Salva o bool "final" no nó da lista
	
	lw $s0, 12($a0)	#Carrega o bool "inicial"
	sw $s0, 12($v0)	#Salva o "inicial" no nó da lista
	
	lw $ra, 0($sp)
	addu $sp, $sp, 12
	jr $ra

inigra: #Inicializa o grafo. $v0 recebe a quantidade de estados e retorna o endereço do grafo inicializado
	subu $sp, $sp, 8
	sw $ra, 0($sp)	#Salva endereço do "caller"
	
	sw $v0, 4($sp)	#Salva quantidade de estados
	li $a0, 4	#Passa o parâmetro "size of" em bytes
	jal malloc	#Chama malloc
	lw $t0, 4($sp)	#Recupera quantidade de estados
	addu $t1, $v0, $zero	#Copia o endereço inicial, que foi gravado em $v0 por "malloc"
	addu $t2, $zero, $zero 	#Inicializa o contador
Loopini:beq $t2, $t0, Fimini	#Desvia se percorreu todos os estados
	sw $zero, 0($t1)	#Grava NULL na memória
	addu $t2, $t2, 1	#Contador soma mais um
	addu $t1, $t1, 4	#Memória avança +4 (Uma palavra)
	j Loopini
	
Fimini:
	lw $ra, 0($sp)	#Recupera o endereço do "caller"
	addu $sp, $sp, 8
	jr $ra		#Retorna para o "caller"	

malloc: #$v0 = multiplicador(endereço de memória retorna aqui), $a0 = tamanho do tipo
	multu $v0, $a0	#Calcula tamanho em bytes(multiplicador * tamanho do tipo)
	mflo $a0	#Copia tamanho requerido no parâmetro do syscall
	
	li $v0, 9	#Malloc syscall(sbrk), parâmetro de tamanho passado em $a0
	syscall
	
	jr $ra #Retorna pra quem chamou

scans:	#$a0 recebe endereço do vetor de char, $a1 recebe tamanho do vetor de char
	addu $t1, $a0, $zero	#Copia o endereço inicial do vetor no stack
	addu $t0, $zero, $zero	#Inicializa o contador
	li $v0, 8	#Lê string
	syscall		#Chamada de sistema
	lbu $t4, nln	#Carrega caracter de nova-linha
	lbu $t5, nulc	#Carrega caracter NULL
Loopscn:beq $t0, $a1, Finscn	#Desvia se chegar ao fim do vetor
	lbu $t3, 0($t1)	#Carrega 1 caracter do vetor
	beq $t3, $t4, Finscn	#Desvia se encontrar caracter de nova-linha
	addiu $t0, $t0, 1	#Adiciona 1 ao contador
	addiu $t1, $t1, 1	#Aponta pra próxima letra do vetor
	j Loopscn
	
Finscn:	sb $t5, 0($t1)	#Armazena o caracter NULL no fim do vetor
	jr $ra		#Retorna pra main

prints: #$a0 recebe endereço do vetor de char
	li $v0, 4
	syscall
	jr $ra
