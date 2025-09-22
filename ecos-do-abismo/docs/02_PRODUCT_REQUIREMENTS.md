# 📋 PRODUCT REQUIREMENTS DOCUMENT (PRD)

## **GAME CONCEPT**
**"Slay the Spire meets Darkest Dungeon" - Cartas + Tensão Psicológica**

---

## **CORE PILLARS**

### **1. DECISÕES TENSAS** 🤔
Cada carta tem trade-off real: poder vs corrupção
**Como medir**: Jogador hesita 2+ segundos antes de usar carta forte

### **2. FEEDBACK IMEDIATO** ⚡
Toda ação tem resposta visual instantânea
**Como medir**: Delay < 100ms entre clique e resposta visual

### **3. SIMPLICIDADE ELEGANTE** ✨
Mecânicas profundas com interface minimalista
**Como medir**: Jogador entende tudo em < 60 segundos

---

## **FUNCTIONAL REQUIREMENTS**

### **🎯 MVP FEATURES (Must Have)**

#### **F1: COMBAT SYSTEM**
**User Story**: "Como jogador, quero jogar cartas para derrotar inimigos"
**Acceptance Criteria**:
- [ ] 3 cartas disponíveis por turno
- [ ] Cartas causam dano ao inimigo
- [ ] Inimigo morre quando HP = 0
- [ ] Novo inimigo aparece automaticamente
**Priority**: P0 (Blocker)

#### **F2: RESOURCE MANAGEMENT**
**User Story**: "Como jogador, quero sentir tensão ao gastar recursos"
**Acceptance Criteria**:
- [ ] HP: 100 máximo, morre em 0
- [ ] Vontade: 10 máximo, regenera +2/turno
- [ ] Corrupção: 0-100%, morre em 100%
- [ ] Cartas consomem Vontade
- [ ] Cartas fortes aumentam Corrupção
**Priority**: P0 (Blocker)

#### **F3: CARD MECHANICS**
**User Story**: "Como jogador, quero escolher entre poder e segurança"
**Acceptance Criteria**:
- [ ] Carta Fraca: Baixo dano, baixo custo, 0 corrupção
- [ ] Carta Forte: Alto dano, alto custo, +corrupção
- [ ] Carta Suporte: Cura/utilidade
- [ ] Visual claro da diferença entre tipos
**Priority**: P0 (Blocker)

#### **F4: ENEMY SCALING**
**User Story**: "Como jogador, quero enfrentar desafio crescente"
**Acceptance Criteria**:
- [ ] Inimigo 1: 50 HP, 8 dano
- [ ] Cada inimigo: +20% HP, +15% dano
- [ ] Display claro do nível do inimigo
- [ ] Máximo 20 inimigos (evita scaling infinito)
**Priority**: P0 (Blocker)

#### **F5: VISUAL FEEDBACK**
**User Story**: "Como jogador, quero ver impacto das minhas ações"
**Acceptance Criteria**:
- [ ] Número de dano flutuante
- [ ] Carta voa para o inimigo
- [ ] Barra de HP animada
- [ ] Shake effect no dano
- [ ] Efeito de morte do inimigo
**Priority**: P0 (Blocker)

---

### **🚀 ENHANCEMENT FEATURES (Should Have)**

#### **E1: JUICE & POLISH**
- [ ] Partículas nos ataques
- [ ] Screen shake proporcional ao dano
- [ ] Transições suaves entre inimigos
- [ ] Hover effects nas cartas
**Priority**: P1

#### **E2: ADVANCED FEEDBACK**
- [ ] Corrupção muda cor da UI
- [ ] HP baixo pisca vermelho
- [ ] Som de feedback (opcional)
- [ ] Animações de idle
**Priority**: P1

#### **E3: QOL IMPROVEMENTS**
- [ ] Botão de restart
- [ ] Estatísticas simples (inimigos mortos)
- [ ] Pause/resume
- [ ] Configurações básicas
**Priority**: P2

---

### **💡 FUTURE FEATURES (Could Have)**
- [ ] Diferentes tipos de carta
- [ ] Diferentes tipos de inimigo
- [ ] Power-ups temporários
- [ ] Sistema de score
**Priority**: P3 (Backlog)

---

## **NON-FUNCTIONAL REQUIREMENTS**

### **PERFORMANCE**
- **Framerate**: 60 FPS constante
- **Memory**: < 500MB RAM
- **Loading**: < 2 segundos para iniciar
- **Response**: < 100ms input lag

### **USABILITY**
- **Learning Curve**: Jogável em < 60 segundos
- **Accessibility**: Cores não são única diferenciação
- **Resolution**: 1920x1080 minimum
- **Controls**: Mouse + Keyboard

### **RELIABILITY**
- **Stability**: 0 crashes em 30 minutos
- **Data Loss**: Impossível (no save system)
- **Recovery**: Reset automático em erro

---

## **USER INTERFACE REQUIREMENTS**

### **LAYOUT HIERARCHY**
```
[ENEMY AREA]     - 30% da tela, topo
   HP Bar
   Name/Level

[PLAYER AREA]    - 70% da tela, bottom
   Resources
   Cards (3x)
   Turn Button
```

### **VISUAL DESIGN PRINCIPLES**
1. **High Contrast**: Elementos importantes se destacam
2. **Minimal UI**: Máximo 7 elementos visíveis
3. **Clear States**: Hover, disabled, active bem definidos
4. **Consistent**: Mesmo padrão visual em tudo

---

## **TECHNICAL CONSTRAINTS**

### **ARCHITECTURE**
- **Engine**: Godot 4.4+ (GDScript)
- **Patterns**: Observer pattern para events
- **Structure**: Modular, cada feature = script
- **Testing**: Manual QA + automated onde possível

### **DEPENDENCIES**
- **Zero External**: Só Godot built-ins
- **Assets**: Placeholder art apenas
- **Fonts**: System fonts
- **Audio**: Opcional (sem assets)

---

## **ACCEPTANCE CRITERIA GLOBAL**

### **DEFINITION OF DONE**
- [ ] Feature implementada e testada
- [ ] Code review aprovado
- [ ] Performance requirements atendidos
- [ ] UI/UX requirements atendidos
- [ ] Zero bugs críticos
- [ ] Testado em hardware mínimo

### **RELEASE CRITERIA**
- [ ] Todas P0 features completas
- [ ] 60+ FPS em hardware médio
- [ ] Teste de usabilidade com 3 pessoas
- [ ] Zero crashes em 30min de gameplay
- [ ] Input responsivo (< 100ms)

---

## **RISK MATRIX**

| Feature | Technical Risk | UX Risk | Business Risk | Mitigation |
|---------|---------------|---------|---------------|------------|
| Combat System | Low | Medium | High | Prototype first |
| Resource Mgmt | Medium | High | High | User testing |
| Card Mechanics | Low | Medium | Medium | Clear visual diff |
| Enemy Scaling | Low | Low | Low | Configurable values |
| Visual Feedback | Medium | Low | Low | Incremental polish |