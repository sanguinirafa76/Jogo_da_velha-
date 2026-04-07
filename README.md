# 🎮 Jogo da Velha — Assembly 8086

Implementação completa do clássico **Jogo da Velha (Tic-Tac-Toe)** em linguagem Assembly para o processador Intel 8086, desenvolvido como projeto avaliativo da disciplina de **Organização de Sistemas Computacionais** na PUC-Campinas (2025).

---

## 📖 Sobre o Projeto

O programa simula o jogo da velha em modo texto, permitindo partidas entre **dois jogadores humanos** ou entre um **jogador humano e o computador**. Todo o código foi escrito em Assembly 8086 puro, explorando manipulação direta de memória, registradores, pilha e interrupções do DOS/BIOS.

---

## 📁 Estrutura do Repositório

```
├── projeto1_OS.asm       # Código-fonte em Assembly 8086
├── projeto1_OS.exe       # Executável compilado (MS-DOS)
└── README.md
```

---

## ⚙️ Como Compilar

Você precisará do **MASM** ou **TASM** instalado em um ambiente MS-DOS (ou emulador).

**Com MASM:**
```
MASM projeto1_OS.asm;
LINK projeto1_OS.obj;
```

**Com TASM:**
```
TASM projeto1_OS.asm
TLINK projeto1_OS.obj
```

---

## 🚀 Como Executar

**No MS-DOS:**
```
projeto1_OS.exe
```

**No Windows moderno (via [DOSBox](https://www.dosbox.com)):**
```
mount c c:\caminho\para\a\pasta
c:
projeto1_OS.exe
```

> Requisitos mínimos: MS-DOS ou emulador compatível · Processador Intel 8086 ou superior · 64 KB de RAM

---

## 🕹️ Como Jogar

### 1. Tela inicial

Ao executar, aparece o menu de seleção de modo:

```
JOGO DA VELHA - 8086

Escolha o modo de jogo:
1 - Jogador vs Jogador
2 - Jogador vs Computador
Opcao: _
```

Digite `1` ou `2` e pressione Enter.

### 2. O tabuleiro

```
   1   2   3
1    |   |
  -----------
2    |   |
  -----------
3    |   |
```

Os números no topo indicam as **colunas** e os da lateral indicam as **linhas**.

### 3. Realizando uma jogada

A cada turno, o jogo solicita:

```
Digite a linha (1-3): _
Digite a coluna (1-3): _
```

Exemplo — para jogar no centro:
- Linha: `2` → Coluna: `2`

```
   1   2   3
1    |   |
  -----------
2    | X |
  -----------
3    |   |
```

### 4. Final de partida

Ao terminar, é exibida a mensagem de vitória ou empate, seguida da opção:

```
Jogar novamente? (S/N): _
```

---

## 🤖 Inteligência Artificial (modo PvC)

No modo Jogador vs Computador, o computador joga como `O` e segue esta ordem de prioridade:

1. **Vencer** — completa a própria linha se tiver duas peças seguidas
2. **Bloquear** — impede a vitória do jogador humano
3. **Centro** — ocupa a posição central (índice 4) se disponível
4. **Primeira livre** — joga na primeira célula vazia encontrada

---

## 🏗️ Arquitetura e Módulos

O programa usa o modelo `.MODEL SMALL` e está organizado em procedimentos independentes:

| Procedimento | Descrição |
|---|---|
| `MAIN` | Fluxo principal: menu, loop de jogo, condições de término |
| `INICIALIZAR_JOGO` | Reseta o tabuleiro (9 espaços) e as variáveis de controle |
| `MOSTRAR_TABULEIRO` | Renderiza o grid na tela substituindo marcadores pelos valores do array |
| `REALIZAR_JOGADA_HUMANO` | Lê linha/coluna, valida entradas e marca a posição no tabuleiro |
| `REALIZAR_JOGADA_COMPUTADOR` | Executa a lógica de IA para escolher a melhor jogada |
| `TENTAR_COMPLETAR_LINHA` | Detecta padrão "2 peças + 1 espaço" para vencer ou bloquear |
| `VERIFICAR_VITORIA` | Verifica as 8 combinações possíveis de vitória |
| `TROCAR_JOGADOR` | Alterna o símbolo ativo entre `X` e `O` |
| `IMPRIMIR_STRING` | `INT 21h / 09h` — imprime string terminada em `$` |
| `LER_CARACTERE` | `INT 21h / 01h` — lê um caractere com eco |
| `LIMPAR_TELA` | `INT 10h / 06h` — scroll up + reposiciona cursor em (0,0) |
| `PAUSAR` | `INT 21h / 08h` — aguarda tecla sem exibir na tela |

### Segmento de dados

```asm
tabuleiro           DB 9 DUP(' ')   ; array linear simulando a matriz 3x3
modo_jogo           DB 0            ; 1 = PvP, 2 = PvC
jogador_atual       DB 'X'          ; símbolo do turno atual
jogadas_realizadas  DB 0            ; contador de jogadas (empate em 9)
```

### Conversão coordenadas → índice linear

```asm
; índice = (linha - 1) × 3 + (coluna - 1)
DEC BL       ; linha - 1
DEC BH       ; coluna - 1
MOV AL, BL
MOV CL, 3
MUL CL       ; AL = (linha-1) × 3
ADD AL, BH   ; AL = índice final
```

---

## 🔌 Interrupções Utilizadas

| Interrupção | Função | Uso |
|---|---|---|
| `INT 21h / 01h` | Lê caractere com eco | Entrada do jogador |
| `INT 21h / 02h` | Imprime caractere | Renderização do tabuleiro célula a célula |
| `INT 21h / 09h` | Imprime string (`$`-terminated) | Mensagens de interface |
| `INT 21h / 08h` | Lê caractere sem eco | Pausas entre jogadas |
| `INT 21h / 4Ch` | Termina programa | Encerramento |
| `INT 10h / 06h` | Scroll up (limpar tela) | Limpeza de tela a cada turno |
| `INT 10h / 02h` | Posiciona cursor | Reposiciona após limpar tela |

---

## 💡 Conceitos de Assembly Aplicados

- **Saltos condicionais** — `JE`, `JNE`, `JL`, `JG`, `JB`, `JA` para controle de fluxo
- **Sub-rotinas** — mais de 30 procedimentos com `CALL` / `RET`
- **Pilha** — `PUSH` / `POP` para preservação de registradores entre chamadas
- **Acesso à memória** — endereçamento via `SI`, `DI`, `BX` com `BYTE PTR`
- **Aritmética de 8 bits** — `MUL`, `ADD`, `DEC`, `INC`, `XOR` para cálculo de índices
- **Segmentação** — modelo `.MODEL SMALL` com segmentos `.DATA`, `.STACK` e `.CODE`

---

## 🏆 Dicas Estratégicas

- **Centro primeiro** — a posição (2,2) cobre 4 linhas de vitória possíveis
- **Cantos são fortes** — posições (1,1), (1,3), (3,1) e (3,3) cobrem diagonais
- **Bloqueie sempre** — se o adversário tiver 2 em linha, bloqueie imediatamente
- **Crie garfos** — tente montar duas ameaças simultâneas para forçar a vitória

---

## 📚 Referências

- ABEL, Peter. *IBM PC Assembly Language and Programming*. 5ª ed. Pearson, 2001.
- INTEL CORPORATION. *8086 Family User's Manual*. Intel Corporation, 1979.
- NORTON, Peter; SOCHA, John. *Peter Norton's Assembly Language Book for the IBM PC*. Brady Books, 1986.

---

## 👤 Autor

**Rafael Sanguini Colagrossi** — RA: 25007599  
Disciplina: Organização de Sistemas Computacionais  
Professor: Ricardo Pannain  
PUC-Campinas · 2025
