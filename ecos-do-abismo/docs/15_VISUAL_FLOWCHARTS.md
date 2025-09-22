# Diagramas Visuais - Ecos do Abismo

## 1. FLUXO PRINCIPAL DO JOGO

```
[ABERTURA DO JOGO]
       ↓
[TELA DE TÍTULO]
       ↓
[MENU PRINCIPAL]
    ↙     ↘
[NOVO JOGO]  [CONTINUAR]
    ↓          ↓
[INTRODUÇÃO] → [HUB PRINCIPAL]
               ↓
    ┌─────────[SELEÇÃO DE MISSÃO]─────────┐
    ↓                ↓                    ↓
[COMBATE 1]    [COMBATE 2]         [COMBATE N]
    ↓                ↓                    ↓
    └────────→ [RECOMPENSAS] ←──────────┘
                     ↓
              [UPGRADE/LOJA]
                     ↓
              [HUB PRINCIPAL] ──→ [LOOP]
```

## 2. FLUXO DE COMBATE DETALHADO

```
[INÍCIO DO COMBATE]
       ↓
[SETUP INICIAL]
- Embaralhar deck
- HP/Vontade inicial
- Posicionamento
       ↓
[TURNO DO JOGADOR]
       ↓
┌─────[FASE DE COMPRA]─────┐
│ • Ganhar moedas          │
│ • Comprar cartas         │
│ • Adicionar ao deck      │
└─────────┬─────────────────┘
          ↓
┌─────[FASE DE AÇÃO]──────┐
│ • Sacar 5 cartas        │
│ • Jogar cartas          │
│ • Atacar inimigos       │
│ • Usar habilidades      │
└─────────┬───────────────┘
          ↓
┌─────[FASE DE DESCARTE]──┐
│ • Descartar mão         │
│ • Efeitos fim de turno  │
│ • Reset energia         │
└─────────┬───────────────┘
          ↓
[TURNO INIMIGO]
┌─────[IA INIMIGA]────────┐
│ • Escolher ações        │
│ • Executar ataques      │
│ • Aplicar efeitos       │
└─────────┬───────────────┘
          ↓
[VERIFICAR CONDIÇÕES]
    ↓       ↓       ↓
[VITÓRIA] [DERROTA] [CONTINUAR]
    ↓       ↓          ↓
[RECOMP.] [GAME OVER] [LOOP]
```

## 3. SISTEMA DE PROGRESSÃO

```
[VITÓRIA EM COMBATE]
       ↓
[CÁLCULO DE RECOMPENSAS]
┌─────────────────────────┐
│ XP = BaseXP × (1 + Dif) │
│ Moedas = Base × Combo   │
│ Cartas = RNG + Bonus    │
└─────────┬───────────────┘
          ↓
[LEVEL UP?] ─── NÃO ──→ [CONTINUAR]
    ↓ SIM
[ESCOLHER UPGRADE]
┌──────────────────────┐
│ • Novas cartas       │
│ • Stat boost         │
│ • Habilidades        │
│ • Melhorar deck      │
└──────┬───────────────┘
       ↓
[APLICAR UPGRADE]
       ↓
[ATUALIZAR PERFIL]
       ↓
[PRÓXIMO COMBATE]
```

## 4. FLUXO DE UI/UX

```
[ABERTURA] → [LOADING] → [TÍTULO]
                             ↓
┌─────────[MENU PRINCIPAL]─────────┐
│ ┌─ NOVO JOGO                     │
│ ├─ CONTINUAR                     │
│ ├─ CONFIGURAÇÕES                 │
│ └─ SAIR                          │
└─────────┬───────────────────────┘
          ↓
┌─────[HUB DO JOGADOR]─────┐
│ ┌─ Perfil/Stats          │
│ ├─ Deck Builder          │
│ ├─ Loja                  │
│ ├─ Missões Disponíveis   │
│ └─ Configurações         │
└─────┬───────────────────┘
      ↓
┌─[TELA DE COMBATE]─┐
│ ┌─ Mão de cartas  │
│ ├─ Campo batalha  │
│ ├─ Status/HP      │
│ ├─ Energia        │
│ └─ Menu pausa     │
└─┬─────────────────┘
  ↓
[RESULTADOS]
  ↓
[RETORNO HUB]
```

## 5. ARQUITETURA DE DADOS

```
[GAME MANAGER]
       ↓
┌──[PLAYER DATA]──┐    ┌──[COMBAT DATA]──┐
│ • Level         │    │ • Current HP    │
│ • XP            │    │ • Current Hand  │
│ • Deck Cards    │    │ • Field State   │
│ • Inventory     │    │ • Turn Counter  │
│ • Stats         │    │ • Enemy State   │
└────────┬────────┘    └────────┬────────┘
         ↓                      ↓
[SAVE SYSTEM] ←──────────→ [GAME STATE]
         ↓                      ↓
[LOCAL STORAGE]           [TEMP MEMORY]
```

## 6. SISTEMA DE DIFICULDADE

```
[COMBATE N]
    ↓
[CALCULAR DIFICULDADE]
┌─────────────────────────┐
│ Dif = Base + (N × 0.2)  │
│ Enemy HP *= (1 + Dif)   │
│ Enemy DMG *= (1 + Dif)  │
│ Rewards *= (1 + Dif)    │
└─────────┬───────────────┘
          ↓
[SPAWN INIMIGOS]
┌─────────────────────────┐
│ HP = 50 × (1 + Dif)     │
│ ATK = 10 × (1 + Dif)    │
│ New Cards @ Level 5,10  │
│ Special Abilities       │
└─────────┬───────────────┘
          ↓
[EXECUTAR COMBATE]
```

## 7. LOOP DE ENGAGEMENT

```
[SESSÃO DE JOGO]
       ↓
[COMBATE RÁPIDO] (2-5 min)
       ↓
[RECOMPENSA IMEDIATA]
       ↓
[DECISÃO DE UPGRADE] ──→ [DOPAMINA]
       ↓                      ↓
[PRÓXIMO DESAFIO] ←──────────┘
       ↓
[PROGRESSÃO VISÍVEL]
       ↓
[MOTIVAÇÃO CONTINUAR] ──→ [LOOP]
```

## 8. FLUXO DE ONBOARDING

```
[PRIMEIRO BOOT]
       ↓
[TUTORIAL INTERATIVO]
┌─────────────────────────┐
│ 1. Como jogar cartas    │
│ 2. Sistema de energia   │
│ 3. Combate básico       │
│ 4. Upgrade de deck      │
│ 5. Progressão           │
└─────────┬───────────────┘
          ↓
[PRIMEIRO COMBATE REAL]
          ↓
[PRIMEIRA RECOMPENSA]
          ↓
[LIBERAR HUB COMPLETO]
```

## 9. MÉTRICAS DE ENGAJAMENTO

```
[AÇÕES DO JOGADOR]
       ↓
[TELEMETRIA]
┌─────────────────────────┐
│ • Tempo por sessão      │
│ • Combates por sessão   │
│ • Taxa de vitória       │
│ • Cartas mais usadas    │
│ • Pontos de abandono    │
└─────────┬───────────────┘
          ↓
[ANÁLISE DE DADOS]
          ↓
[AJUSTES DE BALANCE]
```

## 10. ESTADOS DE JOGO

```
IDLE → LOADING → MENU → GAME → COMBAT → RESULTS → UPGRADE → GAME
 ↑                ↓                                           ↓
PAUSE ←──────────┴───────────────────────────────────────────┘
 ↓
RESUME ──→ [RETORNAR AO ESTADO ANTERIOR]
```