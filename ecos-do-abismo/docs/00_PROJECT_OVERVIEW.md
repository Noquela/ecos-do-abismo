# 🎮 ECOS DO ABISMO - PROJECT OVERVIEW

## **VISÃO GERAL**
**Um jogo de cartas psicológico onde cada decisão te aproxima da vitória... ou da loucura.**

---

## **OBJETIVOS SMART**

### **🎯 OBJETIVO PRINCIPAL**
Criar um jogo viciante onde o jogador sente **tensão psicológica real** a cada carta jogada.

### **📊 KPIs DE SUCESSO**
- **Retenção**: Jogador joga por 15+ minutos na primeira sessão
- **Engagement**: Taxa de clique em cartas > 80%
- **Tensão**: Jogador hesita antes de usar cartas "fortes"
- **Flow**: 0 bugs que quebram o gameplay core

### **⏰ TIMELINE**
- **Sprint 1** (1 semana): Core loop funcionando
- **Sprint 2** (1 semana): Balanceamento e juice
- **Sprint 3** (1 semana): Polish e testes

---

## **SCOPE DEFINITION**

### **✅ DENTRO DO SCOPE**
- Jogo funcional com cartas e inimigos
- Sistema de recursos (HP, Vontade, Corrupção)
- Progressão de dificuldade
- Interface limpa e responsiva
- Feedback visual satisfatório

### **❌ FORA DO SCOPE**
- Sistema de save/load
- Múltiplos tipos de inimigo
- Narrativa complexa
- Arte elaborada
- Audio/música
- Multiplayer
- Mobile support

---

## **TECHNICAL CONSTRAINTS**
- **Engine**: Godot 4.4+
- **Platform**: PC Windows (desktop)
- **Performance**: 60 FPS em hardware médio
- **Resolution**: 1920x1080 (windowed)
- **Dependencies**: Zero bibliotecas externas

---

## **RISK ASSESSMENT**

| Risco | Probabilidade | Impacto | Mitigação |
|-------|---------------|---------|-----------|
| Scope creep | Alta | Alto | Documentação rígida + reviews |
| Over-engineering | Média | Alto | Protótipos simples primeiro |
| Balanceamento | Média | Médio | Testes frequentes |
| Performance | Baixa | Médio | Profiling desde o início |

---

## **DEFINIÇÃO DE "DONE"**
- [ ] Jogador pode jogar 10+ batalhas sem bugs
- [ ] Interface é intuitiva (teste com 3 pessoas)
- [ ] Cartas têm feedback visual claro
- [ ] Performance estável (60+ FPS)
- [ ] Code review completo