TITLE jogo_da_velha_projeto1_OS
.MODEL SMALL
.STACK 100h

.DATA
    ; Tabuleiro do jogo (3x3) - inicializado com espaços
    tabuleiro DB 9 DUP(' ')
    
    ; Mensagens do jogo
    msg_titulo DB 13,10,'JOGO DA VELHA - 8086',13,10,'$'
    
    msg_menu DB 13,10,'Escolha o modo de jogo:',13,10
             DB '1 - Jogador vs Jogador',13,10
             DB '2 - Jogador vs Computador',13,10
             DB 'Opcao: $'
    
    msg_tabuleiro DB 13,10,'   1   2   3',13,10
                  DB '1  ',0,' | ',0,' | ',0,13,10
                  DB '  -----------',13,10
                  DB '2  ',0,' | ',0,' | ',0,13,10
                  DB '  -----------',13,10
                  DB '3  ',0,' | ',0,' | ',0,13,10,'$'
    
    msg_jogador1 DB 13,10,'Vez do Jogador X',13,10,'$'
    msg_jogador2 DB 13,10,'Vez do Jogador O',13,10,'$'
    msg_computador DB 13,10,'Vez do Computador (O)...',13,10,'$'
    
    msg_linha DB 'Digite a linha (1-3): $'
    msg_coluna DB 'Digite a coluna (1-3): $'
    
    msg_invalida DB 13,10,'Jogada invalida! Tente novamente.',13,10,'$'
    msg_ocupada DB 13,10,'Posicao ocupada! Tente novamente.',13,10,'$'
    
    msg_vitoria_x DB 13,10,13,10,'----JOGADOR X VENCEU!----',13,10,'$'
    msg_vitoria_o DB 13,10,13,10,'----JOGADOR O VENCEU!----',13,10,'$'
    msg_empate DB 13,10,13,10,'----EMPATE!----',13,10,'$'
    
    msg_continuar DB 13,10,'Jogar novamente? (S/N): $'
    msg_obrigado DB 13,10,'Obrigado por jogar!',13,10,'$'
    
    ; Variáveis de controle
    modo_jogo DB 0          ; 1 = PvP, 2 = PvC
    jogador_atual DB 'X'    ; 'X' ou 'O'
    jogadas_realizadas DB 0 ; Contador de jogadas
    
    ; Padrões de vitória (índices do tabuleiro)
    ; Horizontal: 0,1,2 / 3,4,5 / 6,7,8
    ; Vertical: 0,3,6 / 1,4,7 / 2,5,8
    ; Diagonal: 0,4,8 / 2,4,6
    
.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
INICIO_JOGO:
    ; Limpa a tela
    CALL LIMPAR_TELA
    
    ; Mostra título
    LEA DX, msg_titulo
    CALL IMPRIMIR_STRING
    
    ; Menu de seleção
    LEA DX, msg_menu
    CALL IMPRIMIR_STRING
    
    ; Lê opção do menu
    CALL LER_CARACTERE
    SUB AL, '0'             ; Converte ASCII para número
    MOV modo_jogo, AL
    
    ; Valida opção
    CMP AL, 1
    JB OPCAO_INVALIDA       ; Jump if Below (menor que 1)
    CMP AL, 2
    JA OPCAO_INVALIDA       ; Jump if Above (maior que 2)
    JMP VALIDADO            ; Opção válida, continua
    
OPCAO_INVALIDA:
    JMP INICIO_JOGO         ; Volta ao menu
    
VALIDADO:
    
    ; Inicializa novo jogo
    CALL INICIALIZAR_JOGO
    
LOOP_JOGO:
    ; Limpa tela e mostra tabuleiro
    CALL LIMPAR_TELA
    LEA DX, msg_titulo
    CALL IMPRIMIR_STRING
    CALL MOSTRAR_TABULEIRO
    
    ; Verifica de quem é a vez
    CMP jogador_atual, 'X'
    JE VEZ_JOGADOR_X
    
    ; Vez do jogador O ou computador
    CMP modo_jogo, 2        ; Modo PvC?
    JE VEZ_COMPUTADOR
    
    ; Jogador O (humano)
    LEA DX, msg_jogador2
    CALL IMPRIMIR_STRING
    CALL REALIZAR_JOGADA_HUMANO
    JMP APOS_JOGADA
    
VEZ_JOGADOR_X:
    LEA DX, msg_jogador1
    CALL IMPRIMIR_STRING
    CALL REALIZAR_JOGADA_HUMANO
    JMP APOS_JOGADA
    
VEZ_COMPUTADOR:
    LEA DX, msg_computador
    CALL IMPRIMIR_STRING
    CALL REALIZAR_JOGADA_COMPUTADOR
    
APOS_JOGADA:
    ; Incrementa contador de jogadas
    INC jogadas_realizadas
    
    ; Verifica vitória
    CALL VERIFICAR_VITORIA
    CMP AL, 1
    JE FIM_VITORIA
    
    ; Verifica empate (9 jogadas)
    CMP jogadas_realizadas, 9
    JE FIM_EMPATE
    
    ; Troca jogador
    CALL TROCAR_JOGADOR
    JMP LOOP_JOGO
    
FIM_VITORIA:
    CALL LIMPAR_TELA
    LEA DX, msg_titulo
    CALL IMPRIMIR_STRING
    CALL MOSTRAR_TABULEIRO
    
    ; Mostra mensagem de vitória
    CMP jogador_atual, 'X'
    JE VITORIA_X
    LEA DX, msg_vitoria_o
    JMP MOSTRAR_VITORIA
    
VITORIA_X:
    LEA DX, msg_vitoria_x
    
MOSTRAR_VITORIA:
    CALL IMPRIMIR_STRING
    JMP PERGUNTAR_CONTINUAR
    
FIM_EMPATE:
    CALL LIMPAR_TELA
    LEA DX, msg_titulo
    CALL IMPRIMIR_STRING
    CALL MOSTRAR_TABULEIRO
    LEA DX, msg_empate
    CALL IMPRIMIR_STRING
    
PERGUNTAR_CONTINUAR:
    LEA DX, msg_continuar
    CALL IMPRIMIR_STRING
    CALL LER_CARACTERE
    
    CMP AL, 'S'
    JE REINICIAR_JOGO
    CMP AL, 's'
    JE REINICIAR_JOGO
    JMP FINALIZAR_PROGRAMA
    
REINICIAR_JOGO:
    JMP INICIO_JOGO
    
FINALIZAR_PROGRAMA:
    
    ; Finaliza programa
    LEA DX, msg_obrigado
    CALL IMPRIMIR_STRING
    
    MOV AH, 4Ch
    INT 21h


MAIN ENDP

; PROCEDIMENTO: INICIALIZAR_JOGO
INICIALIZAR_JOGO PROC NEAR
    PUSH AX
    PUSH CX
    PUSH DI
    
    ; Limpa o tabuleiro
    MOV CX, 9
    LEA DI, tabuleiro
    MOV AL, ' '
    
LOOP_LIMPAR:
    MOV [DI], AL
    INC DI
    LOOP LOOP_LIMPAR
    
    ; Reinicia variáveis
    MOV jogador_atual, 'X'
    MOV jogadas_realizadas, 0
    
    POP DI
    POP CX
    POP AX
    RET
INICIALIZAR_JOGO ENDP

; PROCEDIMENTO: MOSTRAR_TABULEIRO
MOSTRAR_TABULEIRO PROC NEAR
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    
    ; Imprime cabeçalho
    MOV AH, 09h
    LEA DX, msg_tabuleiro
    MOV SI, DX
    XOR BX, BX              ; Índice do tabuleiro
    
    ; Percorre a string msg_tabuleiro e substitui os bytes 0 pelos valores
LOOP_MOSTRAR:
    MOV DL, [SI]
    CMP DL, '$'
    JE FIM_MOSTRAR
    
    CMP DL, 0               ; Marcador para substituição
    JNE IMPRIMIR_CHAR
    
    ; Substitui pelo valor do tabuleiro
    PUSH SI
    LEA SI, tabuleiro
    ADD SI, BX
    MOV DL, [SI]
    POP SI
    INC BX
    
IMPRIMIR_CHAR:
    MOV AH, 02h
    INT 21h
    INC SI
    JMP LOOP_MOSTRAR
    
FIM_MOSTRAR:
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
MOSTRAR_TABULEIRO ENDP

; PROCEDIMENTO: REALIZAR_JOGADA_HUMANO
REALIZAR_JOGADA_HUMANO PROC NEAR
    PUSH AX
    PUSH BX
    PUSH DX
    
PEDIR_JOGADA:
    ; Solicita linha
    LEA DX, msg_linha
    CALL IMPRIMIR_STRING
    CALL LER_CARACTERE
    SUB AL, '0'
    MOV BL, AL
    
    ; Valida linha
    CMP BL, 1
    JL JOGADA_INVALIDA
    CMP BL, 3
    JG JOGADA_INVALIDA
    
    ; Solicita coluna
    LEA DX, msg_coluna
    CALL IMPRIMIR_STRING
    CALL LER_CARACTERE
    SUB AL, '0'
    MOV BH, AL
    
    ; Valida coluna
    CMP BH, 1
    JL JOGADA_INVALIDA
    CMP BH, 3
    JG JOGADA_INVALIDA
    
    ; Calcula índice: (linha-1)*3 + (coluna-1)
    DEC BL
    DEC BH
    MOV AL, BL
    MOV CL, 3
    MUL CL
    ADD AL, BH
    MOV BL, AL              ; BL = índice
    
    ; Verifica se posição está livre
    LEA SI, tabuleiro
    XOR BH, BH
    ADD SI, BX
    CMP BYTE PTR [SI], ' '
    JNE POSICAO_OCUPADA
    
    ; Marca a posição
    MOV AL, jogador_atual
    MOV [SI], AL
    
    POP DX
    POP BX
    POP AX
    RET
    
JOGADA_INVALIDA:
    LEA DX, msg_invalida
    CALL IMPRIMIR_STRING
    CALL PAUSAR
    JMP PEDIR_JOGADA
    
POSICAO_OCUPADA:
    LEA DX, msg_ocupada
    CALL IMPRIMIR_STRING
    CALL PAUSAR
    JMP PEDIR_JOGADA
    
REALIZAR_JOGADA_HUMANO ENDP

; PROCEDIMENTO: REALIZAR_JOGADA_COMPUTADOR
REALIZAR_JOGADA_COMPUTADOR PROC NEAR
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH SI
    
    ; Tenta vencer
    MOV AL, 'O'
    CALL TENTAR_COMPLETAR_LINHA
    CMP BL, 0FFh
    JNE FAZER_JOGADA_PC
    
    ; Tenta bloquear
    MOV AL, 'X'
    CALL TENTAR_COMPLETAR_LINHA
    CMP BL, 0FFh
    JNE FAZER_JOGADA_PC
    
    ; Tenta jogar no centro (posição 4)
    LEA SI, tabuleiro
    ADD SI, 4
    CMP BYTE PTR [SI], ' '
    JNE JOGAR_LIVRE
    MOV BL, 4
    JMP FAZER_JOGADA_PC
    
JOGAR_LIVRE:
    ; Joga em primeira posição livre
    LEA SI, tabuleiro
    XOR BX, BX
    
BUSCAR_LIVRE:
    CMP BYTE PTR [SI], ' '
    JE FAZER_JOGADA_PC
    INC SI
    INC BL
    CMP BL, 9
    JL BUSCAR_LIVRE
    
FAZER_JOGADA_PC:
    ; Marca posição
    LEA SI, tabuleiro
    XOR BH, BH
    ADD SI, BX
    MOV BYTE PTR [SI], 'O'
    
    ; Pausa para dar tempo de ver a jogada
    MOV CX, 0FFFFh

PAUSA_PC:
    LOOP PAUSA_PC
    
    POP SI
    POP CX
    POP BX
    POP AX
    RET
REALIZAR_JOGADA_COMPUTADOR ENDP

; PROCEDIMENTO: TENTAR_COMPLETAR_LINHA
TENTAR_COMPLETAR_LINHA PROC NEAR
    PUSH AX
    PUSH CX
    PUSH DX
    PUSH SI
    
    MOV DL, AL              ; Salva símbolo
    LEA SI, tabuleiro
    
    ; Verifica linhas horizontais
    CALL VERIFICAR_LINHA_0_1_2
    CMP BL, 0FFh
    JNE FIM_TENTAR
    
    CALL VERIFICAR_LINHA_3_4_5
    CMP BL, 0FFh
    JNE FIM_TENTAR
    
    CALL VERIFICAR_LINHA_6_7_8
    CMP BL, 0FFh
    JNE FIM_TENTAR
    
    ; Verifica colunas verticais
    CALL VERIFICAR_COLUNA_0_3_6
    CMP BL, 0FFh
    JNE FIM_TENTAR
    
    CALL VERIFICAR_COLUNA_1_4_7
    CMP BL, 0FFh
    JNE FIM_TENTAR
    
    CALL VERIFICAR_COLUNA_2_5_8
    CMP BL, 0FFh
    JNE FIM_TENTAR
    
    ; Verifica diagonais
    CALL VERIFICAR_DIAGONAL_0_4_8
    CMP BL, 0FFh
    JNE FIM_TENTAR
    
    CALL VERIFICAR_DIAGONAL_2_4_6
    
FIM_TENTAR:
    POP SI
    POP DX
    POP CX
    POP AX
    RET
TENTAR_COMPLETAR_LINHA ENDP

; Procedimento: VERIFICAR_LINHA_0_1_2
VERIFICAR_LINHA_0_1_2 PROC NEAR
    MOV BL, 0FFh               ; Inicializa BL como "não encontrado"
    MOV CX, 0                  ; Zera contador de peças encontradas
    
    ; Verifica posição 0
    CMP BYTE PTR [SI+0], DL    ; Compara posição 0 com símbolo procurado
    JE INC_COUNT_012           ; Se igual, pula para incrementar contador
    CMP BYTE PTR [SI+0], ' '   ; Verifica se é espaço vazio
    JNE FIM_012                ; Se não é espaço nem símbolo, padrão inválido
    MOV BL, 0                  ; Salva índice 0 como posição vazia

INC_COUNT_012:
    INC CX                     ; Incrementa contador (match ou espaço)
    
    ; Verifica posição 1
    CMP BYTE PTR [SI+1], DL    ; Compara posição 1 com símbolo
    JE INC_COUNT2_012          ; Se igual, pula para incrementar
    CMP BYTE PTR [SI+1], ' '   ; Verifica se é espaço
    JNE FIM_012                ; Se não, padrão inválido
    MOV BL, 1                  ; Salva índice 1 como posição vazia

INC_COUNT2_012:
    INC CX                     ; Incrementa contador
    
    ; Verifica posição 2
    CMP BYTE PTR [SI+2], DL    ; Compara posição 2 com símbolo
    JE CHECK_012               ; Se igual, vai verificar resultado
    CMP BYTE PTR [SI+2], ' '   ; Verifica se é espaço
    JNE FIM_012                ; Se não, padrão inválido
    MOV BL, 2                  ; Salva índice 2 como posição vazia

CHECK_012:
    INC CX                     ; Incrementa contador
    CMP CX, 3                  ; Verifica se contou 3 (2 peças + 1 espaço)
    JNE FIM_012                ; Se não, não é padrão válido
    RET                        ; Retorna com BL contendo índice do espaço

FIM_012:
    MOV BL, 0FFh               ; Define como não encontrado
    RET                        ; Retorna
VERIFICAR_LINHA_0_1_2 ENDP

; Procedimento: VERIFICAR_LINHA_3_4_5
VERIFICAR_LINHA_3_4_5 PROC NEAR
    MOV BL, 0FFh               ; Inicializa como não encontrado
    MOV CX, 0                  ; Zera contador
    CMP BYTE PTR [SI+3], DL    ; Verifica posição 3
    JE INC_COUNT_345           ; Se igual ao símbolo, incrementa
    CMP BYTE PTR [SI+3], ' '   ; Verifica se é espaço
    JNE FIM_345                ; Se não, inválido
    MOV BL, 3                  ; Salva índice 3

INC_COUNT_345:
    INC CX                     ; Incrementa contador
    CMP BYTE PTR [SI+4], DL    ; Verifica posição 4
    JE INC_COUNT2_345          ; Se igual, incrementa
    CMP BYTE PTR [SI+4], ' '   ; Verifica se é espaço
    JNE FIM_345                ; Se não, inválido
    MOV BL, 4                  ; Salva índice 4

INC_COUNT2_345:
    INC CX                     ; Incrementa contador
    CMP BYTE PTR [SI+5], DL    ; Verifica posição 5
    JE CHECK_345               ; Se igual, verifica resultado
    CMP BYTE PTR [SI+5], ' '   ; Verifica se é espaço
    JNE FIM_345                ; Se não, inválido
    MOV BL, 5                  ; Salva índice 5

CHECK_345:
    INC CX                     ; Incrementa contador
    CMP CX, 3                  ; Verifica se contou 3
    JNE FIM_345                ; Se não, inválido
    RET                        ; Retorna com resultado

FIM_345:
    MOV BL, 0FFh               ; Marca como não encontrado
    RET
VERIFICAR_LINHA_3_4_5 ENDP

; Procedimento: VERIFICAR_LINHA_6_7_8
VERIFICAR_LINHA_6_7_8 PROC NEAR
    MOV BL, 0FFh               ; Inicializa como não encontrado
    MOV CX, 0                  ; Zera contador
    CMP BYTE PTR [SI+6], DL    ; Verifica posição 6
    JE INC_COUNT_678
    CMP BYTE PTR [SI+6], ' '
    JNE FIM_678
    MOV BL, 6

INC_COUNT_678:
    INC CX
    CMP BYTE PTR [SI+7], DL    ; Verifica posição 7
    JE INC_COUNT2_678
    CMP BYTE PTR [SI+7], ' '
    JNE FIM_678
    MOV BL, 7

INC_COUNT2_678:
    INC CX
    CMP BYTE PTR [SI+8], DL    ; Verifica posição 8
    JE CHECK_678
    CMP BYTE PTR [SI+8], ' '
    JNE FIM_678
    MOV BL, 8

CHECK_678:
    INC CX
    CMP CX, 3
    JNE FIM_678
    RET

FIM_678:
    MOV BL, 0FFh
    RET
VERIFICAR_LINHA_6_7_8 ENDP

; Procedimento: VERIFICAR_COLUNA_0_3_6
VERIFICAR_COLUNA_0_3_6 PROC NEAR
    MOV BL, 0FFh               ; Inicializa como não encontrado
    MOV CX, 0                  ; Zera contador
    CMP BYTE PTR [SI+0], DL    ; Verifica posição 0 (topo da coluna)
    JE INC_COUNT_036
    CMP BYTE PTR [SI+0], ' '
    JNE FIM_036
    MOV BL, 0

INC_COUNT_036:
    INC CX
    CMP BYTE PTR [SI+3], DL    ; Verifica posição 3 (meio da coluna)
    JE INC_COUNT2_036
    CMP BYTE PTR [SI+3], ' '
    JNE FIM_036
    MOV BL, 3

INC_COUNT2_036:
    INC CX
    CMP BYTE PTR [SI+6], DL    ; Verifica posição 6 (base da coluna)
    JE CHECK_036
    CMP BYTE PTR [SI+6], ' '
    JNE FIM_036
    MOV BL, 6

CHECK_036:
    INC CX
    CMP CX, 3
    JNE FIM_036
    RET

FIM_036:
    MOV BL, 0FFh
    RET
VERIFICAR_COLUNA_0_3_6 ENDP

; Procedimento: VERIFICAR_COLUNA_1_4_7
VERIFICAR_COLUNA_1_4_7 PROC NEAR
    MOV BL, 0FFh
    MOV CX, 0
    CMP BYTE PTR [SI+1], DL    ; Posição 1
    JE INC_COUNT_147
    CMP BYTE PTR [SI+1], ' '
    JNE FIM_147
    MOV BL, 1

INC_COUNT_147:
    INC CX
    CMP BYTE PTR [SI+4], DL    ; Posição 4
    JE INC_COUNT2_147
    CMP BYTE PTR [SI+4], ' '
    JNE FIM_147
    MOV BL, 4

INC_COUNT2_147:
    INC CX
    CMP BYTE PTR [SI+7], DL    ; Posição 7
    JE CHECK_147
    CMP BYTE PTR [SI+7], ' '
    JNE FIM_147
    MOV BL, 7

CHECK_147:
    INC CX
    CMP CX, 3
    JNE FIM_147
    RET

FIM_147:
    MOV BL, 0FFh
    RET
VERIFICAR_COLUNA_1_4_7 ENDP

; Procedimento: VERIFICAR_COLUNA_2_5_8
VERIFICAR_COLUNA_2_5_8 PROC NEAR
    MOV BL, 0FFh
    MOV CX, 0
    CMP BYTE PTR [SI+2], DL    ; Posição 2
    JE INC_COUNT_258
    CMP BYTE PTR [SI+2], ' '
    JNE FIM_258
    MOV BL, 2

INC_COUNT_258:
    INC CX
    CMP BYTE PTR [SI+5], DL    ; Posição 5
    JE INC_COUNT2_258
    CMP BYTE PTR [SI+5], ' '
    JNE FIM_258
    MOV BL, 5

INC_COUNT2_258:
    INC CX
    CMP BYTE PTR [SI+8], DL    ; Posição 8
    JE CHECK_258
    CMP BYTE PTR [SI+8], ' '
    JNE FIM_258
    MOV BL, 8

CHECK_258:
    INC CX
    CMP CX, 3
    JNE FIM_258
    RET

FIM_258:
    MOV BL, 0FFh
    RET
VERIFICAR_COLUNA_2_5_8 ENDP

; Procedimento: VERIFICAR_DIAGONAL_0_4_8
VERIFICAR_DIAGONAL_0_4_8 PROC NEAR
    MOV BL, 0FFh
    MOV CX, 0
    CMP BYTE PTR [SI+0], DL    ; Canto superior esquerdo
    JE INC_COUNT_048
    CMP BYTE PTR [SI+0], ' '
    JNE FIM_048
    MOV BL, 0

INC_COUNT_048:
    INC CX
    CMP BYTE PTR [SI+4], DL    ; Centro do tabuleiro
    JE INC_COUNT2_048
    CMP BYTE PTR [SI+4], ' '
    JNE FIM_048
    MOV BL, 4

INC_COUNT2_048:
    INC CX
    CMP BYTE PTR [SI+8], DL    ; Canto inferior direito
    JE CHECK_048
    CMP BYTE PTR [SI+8], ' '
    JNE FIM_048
    MOV BL, 8

CHECK_048:
    INC CX
    CMP CX, 3
    JNE FIM_048
    RET

FIM_048:
    MOV BL, 0FFh
    RET
VERIFICAR_DIAGONAL_0_4_8 ENDP

; Procedimento: VERIFICAR_DIAGONAL_2_4_6
VERIFICAR_DIAGONAL_2_4_6 PROC NEAR
    MOV BL, 0FFh
    MOV CX, 0
    CMP BYTE PTR [SI+2], DL    ; Canto superior direito
    JE INC_COUNT_246
    CMP BYTE PTR [SI+2], ' '
    JNE FIM_246
    MOV BL, 2

INC_COUNT_246:
    INC CX
    CMP BYTE PTR [SI+4], DL    ; Centro do tabuleiro
    JE INC_COUNT2_246
    CMP BYTE PTR [SI+4], ' '
    JNE FIM_246
    MOV BL, 4

INC_COUNT2_246:
    INC CX
    CMP BYTE PTR [SI+6], DL    ; Canto inferior esquerdo
    JE CHECK_246
    CMP BYTE PTR [SI+6], ' '
    JNE FIM_246
    MOV BL, 6

CHECK_246:
    INC CX
    CMP CX, 3                  ; Verifica se encontrou padrão válido
    JNE FIM_246
    RET

FIM_246:
    MOV BL, 0FFh
    RET
VERIFICAR_DIAGONAL_2_4_6 ENDP

; Procedimento: VERIFICAR_VITORIA
VERIFICAR_VITORIA PROC NEAR
    PUSH BX                    ; Preserva registradores
    PUSH SI
    
    LEA SI, tabuleiro          ; Aponta para o tabuleiro
    MOV BL, jogador_atual      ; Carrega símbolo do jogador atual
    
    ; Verifica as 3 linhas horizontais
    CALL VERIFICAR_LINHA_H_0   ; Verifica linha 0 (posições 0,1,2)
    CMP AL, 1                  ; Verifica se venceu
    JE FIM_VERIFICAR_V         ; Se sim, retorna vitória
    
    CALL VERIFICAR_LINHA_H_1   ; Verifica linha 1 (posições 3,4,5)
    CMP AL, 1
    JE FIM_VERIFICAR_V
    
    CALL VERIFICAR_LINHA_H_2   ; Verifica linha 2 (posições 6,7,8)
    CMP AL, 1
    JE FIM_VERIFICAR_V
    
    ; Verifica as 3 colunas verticais
    CALL VERIFICAR_LINHA_V_0   ; Verifica coluna 0 (posições 0,3,6)
    CMP AL, 1
    JE FIM_VERIFICAR_V
    
    CALL VERIFICAR_LINHA_V_1   ; Verifica coluna 1 (posições 1,4,7)
    CMP AL, 1
    JE FIM_VERIFICAR_V
    
    CALL VERIFICAR_LINHA_V_2   ; Verifica coluna 2 (posições 2,5,8)
    CMP AL, 1
    JE FIM_VERIFICAR_V
    
    ; Verifica as 2 diagonais
    CALL VERIFICAR_DIAG_PRINCIPAL    ; Diagonal 0,4,8
    CMP AL, 1
    JE FIM_VERIFICAR_V
    
    CALL VERIFICAR_DIAG_SECUNDARIA   ; Diagonal 2,4,6
    
FIM_VERIFICAR_V:
    POP SI                     ; Restaura registradores
    POP BX
    RET                        ; Retorna com resultado em AL
VERIFICAR_VITORIA ENDP

; Procedimentos auxiliares de verificação de vitória
; Cada um verifica se 3 posições específicas têm o mesmo símbolo
VERIFICAR_LINHA_H_0 PROC NEAR
    XOR AL, AL                 ; Zera AL (assume não vitória)
    CMP [SI+0], BL             ; Compara posição 0 com jogador
    JNE FIM_H0                 ; Se diferente, não venceu
    CMP [SI+1], BL             ; Compara posição 1
    JNE FIM_H0
    CMP [SI+2], BL             ; Compara posição 2
    JNE FIM_H0
    MOV AL, 1                  ; Todas iguais = vitória!

FIM_H0:
    RET
VERIFICAR_LINHA_H_0 ENDP

VERIFICAR_LINHA_H_1 PROC NEAR
    XOR AL, AL
    CMP [SI+3], BL             ; Posições 3,4,5
    JNE FIM_H1
    CMP [SI+4], BL
    JNE FIM_H1
    CMP [SI+5], BL
    JNE FIM_H1
    MOV AL, 1

FIM_H1:
    RET
VERIFICAR_LINHA_H_1 ENDP

VERIFICAR_LINHA_H_2 PROC NEAR
    XOR AL, AL
    CMP [SI+6], BL             ; Posições 6,7,8
    JNE FIM_H2
    CMP [SI+7], BL
    JNE FIM_H2
    CMP [SI+8], BL
    JNE FIM_H2
    MOV AL, 1

FIM_H2:
    RET
VERIFICAR_LINHA_H_2 ENDP

VERIFICAR_LINHA_V_0 PROC NEAR
    XOR AL, AL
    CMP [SI+0], BL             ; Posições 0,3,6 (coluna 0)
    JNE FIM_V0
    CMP [SI+3], BL
    JNE FIM_V0
    CMP [SI+6], BL
    JNE FIM_V0
    MOV AL, 1

FIM_V0:
    RET
VERIFICAR_LINHA_V_0 ENDP

VERIFICAR_LINHA_V_1 PROC NEAR
    XOR AL, AL
    CMP [SI+1], BL             ; Posições 1,4,7 (coluna 1)
    JNE FIM_V1
    CMP [SI+4], BL
    JNE FIM_V1
    CMP [SI+7], BL
    JNE FIM_V1
    MOV AL, 1
    
FIM_V1:
    RET
VERIFICAR_LINHA_V_1 ENDP

VERIFICAR_LINHA_V_2 PROC NEAR
    XOR AL, AL
    CMP [SI+2], BL             ; Posições 2,5,8 (coluna 2)
    JNE FIM_V2
    CMP [SI+5], BL
    JNE FIM_V2
    CMP [SI+8], BL
    JNE FIM_V2
    MOV AL, 1

FIM_V2:
    RET
VERIFICAR_LINHA_V_2 ENDP

VERIFICAR_DIAG_PRINCIPAL PROC NEAR
    XOR AL, AL
    CMP [SI+0], BL             ; Diagonal principal: 0,4,8
    JNE FIM_DP
    CMP [SI+4], BL
    JNE FIM_DP
    CMP [SI+8], BL
    JNE FIM_DP
    MOV AL, 1

FIM_DP:
    RET
VERIFICAR_DIAG_PRINCIPAL ENDP

VERIFICAR_DIAG_SECUNDARIA PROC NEAR
    XOR AL, AL
    CMP [SI+2], BL             ; Diagonal secundária: 2,4,6
    JNE FIM_DS
    CMP [SI+4], BL
    JNE FIM_DS
    CMP [SI+6], BL
    JNE FIM_DS
    MOV AL, 1

FIM_DS:
    RET
VERIFICAR_DIAG_SECUNDARIA ENDP

; PROCEDIMENTO: TROCAR_JOGADOR
TROCAR_JOGADOR PROC NEAR
    PUSH AX
    
    CMP jogador_atual, 'X'
    JE MUDAR_PARA_O
    
    MOV jogador_atual, 'X'
    JMP FIM_TROCAR
    
MUDAR_PARA_O:
    MOV jogador_atual, 'O'
    
FIM_TROCAR:
    POP AX
    RET
TROCAR_JOGADOR ENDP

; PROCEDIMENTOS AUXILIARES DE ENTRADA/SAÍDA
; Imprime string terminada em '
IMPRIMIR_STRING PROC NEAR
    PUSH AX
    MOV AH, 09h
    INT 21h
    POP AX
    RET
IMPRIMIR_STRING ENDP

; Lê um caractere do teclado
LER_CARACTERE PROC NEAR
    MOV AH, 01h
    INT 21h
    RET
LER_CARACTERE ENDP

; Limpa a tela
LIMPAR_TELA PROC NEAR
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    
    MOV AH, 06h             ; Função scroll up
    MOV AL, 0               ; Limpa tela inteira
    MOV BH, 07h             ; Atributo (branco no preto)
    MOV CX, 0               ; Canto superior esquerdo
    MOV DH, 24              ; Linha inferior
    MOV DL, 79              ; Coluna direita
    INT 10h
    
    ; Posiciona cursor em (0,0)
    MOV AH, 02h
    MOV BH, 0
    MOV DX, 0
    INT 10h
    
    POP DX
    POP CX
    POP BX
    POP AX
    RET
LIMPAR_TELA ENDP

; Pausa para aguardar entrada
PAUSAR PROC NEAR
    PUSH AX
    MOV AH, 08h             ; Lê caractere sem echo
    INT 21h
    POP AX
    RET
PAUSAR ENDP

END MAIN