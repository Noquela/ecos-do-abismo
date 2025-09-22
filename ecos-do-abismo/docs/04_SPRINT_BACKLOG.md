# 🏃‍♂️ SPRINT BACKLOG - ECOS DO ABISMO

## **OVERVIEW**
**3 Sprints de 1 semana cada → Jogo completo e jogável**

---

# **SPRINT 1: CORE GAMEPLAY** (Semana 1)
**Objetivo**: Jogador pode jogar cartas, matar inimigos, sentir progressão
**Definition of Done**: Loop básico funciona sem bugs críticos

## **🎯 ÉPICOS**

### **E1.1: COMBAT FOUNDATION**
**Objetivo**: Sistema básico de combate funcionando
**Business Value**: **CRÍTICO** - Sem isso, não há jogo

#### **USER STORIES**

**📋 US1.1.1: Como jogador, quero atacar inimigos com cartas**
- **Story Points**: 8
- **Priority**: P0 (Must Have)
- **Acceptance Criteria**:
  - [ ] Inimigo aparece na tela com HP visível
  - [ ] 3 cartas aparecem na parte inferior
  - [ ] Clicar na carta aplica dano no inimigo
  - [ ] Número do dano aparece visualmente
  - [ ] HP do inimigo diminui corretamente

**📋 US1.1.2: Como jogador, quero ver feedback visual do dano**
- **Story Points**: 5
- **Priority**: P0 (Must Have)
- **Acceptance Criteria**:
  - [ ] Número flutuante aparece no inimigo
  - [ ] Inimigo "balança" quando toma dano
  - [ ] Barra de HP anima suavemente
  - [ ] Feedback é instantâneo (< 100ms)

**📋 US1.1.3: Como jogador, quero que inimigo morra e seja substituído**
- **Story Points**: 3
- **Priority**: P0 (Must Have)
- **Acceptance Criteria**:
  - [ ] Inimigo desaparece quando HP = 0
  - [ ] Novo inimigo aparece automaticamente
  - [ ] Novo inimigo é mais forte que o anterior
  - [ ] Transição é suave (fade out/in)

### **E1.2: RESOURCE SYSTEM**
**Objetivo**: Jogador tem recursos limitados e faz escolhas

**📋 US1.2.1: Como jogador, quero gerenciar minha Vontade**
- **Story Points**: 5
- **Priority**: P0 (Must Have)
- **Acceptance Criteria**:
  - [ ] Vontade aparece na UI (formato: 7/10)
  - [ ] Cartas custam Vontade para usar
  - [ ] Não posso usar carta sem Vontade suficiente
  - [ ] Vontade regenera +2 por turno
  - [ ] Feedback visual quando sem recursos

**📋 US1.2.2: Como jogador, quero sentir risco ao usar cartas fortes**
- **Story Points**: 8
- **Priority**: P0 (Must Have)
- **Acceptance Criteria**:
  - [ ] Cartas fortes aumentam Corrupção
  - [ ] Corrupção aparece na UI (formato: 25.5%)
  - [ ] Morro quando Corrupção ≥ 100%
  - [ ] Visual da Corrupção muda cor conforme sobe
  - [ ] Primeira vez usando carta forte = tutorial pop-up

### **E1.3: BASIC UI**
**Objetivo**: Interface funcional e clara

**📋 US1.3.1: Como jogador, quero interface clara e responsiva**
- **Story Points**: 8
- **Priority**: P0 (Must Have)
- **Acceptance Criteria**:
  - [ ] Layout funciona em 1920x1080
  - [ ] Todos os elementos são clicáveis
  - [ ] Hover effects nas cartas
  - [ ] Estados disabled/active claros
  - [ ] Não há UI clipping/overflow

## **📊 SPRINT 1 TASKS BREAKDOWN**

### **DEVELOPMENT TASKS**

| Task | Assignee | Estimate | Status |
|------|----------|----------|--------|
| **Setup project structure** | Dev | 2h | ⏳ |
| **Create Player.gd resource** | Dev | 1h | ⏳ |
| **Create Enemy.gd resource** | Dev | 1h | ⏳ |
| **Create Card.gd resource** | Dev | 2h | ⏳ |
| **Build basic UI layout** | Dev | 4h | ⏳ |
| **Implement damage system** | Dev | 3h | ⏳ |
| **Create floating damage numbers** | Dev | 2h | ⏳ |
| **Build enemy replacement logic** | Dev | 2h | ⏳ |
| **Implement Vontade system** | Dev | 2h | ⏳ |
| **Implement Corrupção system** | Dev | 3h | ⏳ |
| **Create card selection UI** | Dev | 4h | ⏳ |
| **Add basic animations** | Dev | 3h | ⏳ |
| **Manual testing & bug fixes** | Dev | 4h | ⏳ |
| **Code cleanup & documentation** | Dev | 2h | ⏳ |

**Total Estimate**: 35 horas → **5 dias de 7h**

---

# **SPRINT 2: JUICE & BALANCE** (Semana 2)
**Objetivo**: Jogo é satisfatório e balanceado
**Definition of Done**: Game feel profissional, balanceamento testado

## **🎯 ÉPICOS**

### **E2.1: GAME FEEL**
**Objetivo**: Jogo é prazeroso de jogar

**📋 US2.1.1: Como jogador, quero feedback satisfatório**
- **Story Points**: 8
- **Priority**: P1 (Should Have)
- **Acceptance Criteria**:
  - [ ] Screen shake proporcional ao dano
  - [ ] Partículas de impacto
  - [ ] Transições suaves entre estados
  - [ ] Audio feedback (opcional)
  - [ ] Timing perfeito das animações

### **E2.2: BALANCING**
**Objetivo**: Jogo é desafiador mas justo

**📋 US2.2.1: Como jogador, quero progressão balanceada**
- **Story Points**: 5
- **Priority**: P1 (Should Have)
- **Acceptance Criteria**:
  - [ ] Primeiros 3 inimigos são tutorial
  - [ ] Inimigos 4-10 são desafio crescente
  - [ ] Inimigos 10+ são survival mode
  - [ ] Testado com 5 pessoas diferentes
  - [ ] Taxa de vitória ~30% até inimigo 10

### **E2.3: POLISH**
**Objetivo**: Jogo parece profissional

**📋 US2.3.1: Como jogador, quero interface polida**
- **Story Points**: 8
- **Priority**: P1 (Should Have)
- **Acceptance Criteria**:
  - [ ] Cores consistentes e harmoniosas
  - [ ] Typography clara e legível
  - [ ] Estados visuais bem definidos
  - [ ] Loading states para transições
  - [ ] Error states tratados

---

# **SPRINT 3: RELEASE PREPARATION** (Semana 3)
**Objetivo**: Jogo está pronto para release
**Definition of Done**: Zero bugs, performance 60+ FPS

## **🎯 ÉPICOS**

### **E3.1: QUALITY ASSURANCE**
**Objetivo**: Jogo é estável e performático

**📋 US3.1.1: Como jogador, quero jogo estável**
- **Story Points**: 8
- **Priority**: P0 (Must Have)
- **Acceptance Criteria**:
  - [ ] Zero crashes em 30min de gameplay
  - [ ] Performance 60+ FPS constante
  - [ ] Memory usage < 500MB
  - [ ] Input lag < 100ms
  - [ ] Testado em 3 hardwares diferentes

### **E3.2: USER EXPERIENCE**
**Objetivo**: Primeira experiência é perfeita

**📋 US3.2.1: Como novo jogador, quero onboarding claro**
- **Story Points**: 5
- **Priority**: P1 (Should Have)
- **Acceptance Criteria**:
  - [ ] Tutorial não-intrusivo
  - [ ] Primeira carta pisca para guiar
  - [ ] Tooltips explicam mecânicas
  - [ ] Testado com 3 pessoas que nunca jogaram
  - [ ] 90%+ entendem como jogar em 60s

### **E3.3: FINAL POLISH**
**Objetivo**: Últimos detalhes

**📋 US3.3.1: Como desenvolvedor, quero código limpo**
- **Story Points**: 3
- **Priority**: P2 (Could Have)
- **Acceptance Criteria**:
  - [ ] Code review completo
  - [ ] Documentação atualizada
  - [ ] Performance profiling
  - [ ] Build final otimizado

---

## **📈 ROADMAP VISUAL**

```
Semana 1: FUNCIONA
├── MVP Core Loop
├── Sistemas Básicos
└── UI Funcional

Semana 2: SATISFAZ
├── Game Feel
├── Balanceamento
└── Polish Visual

Semana 3: SHIP
├── QA Completo
├── Performance
└── Release Ready
```

---

## **🔄 SCRUM CEREMONIES**

### **DAILY STANDUPS** (15 min/dia)
**Formato**: Async em texto
- O que fiz ontem?
- O que vou fazer hoje?
- Algum blocker?

### **SPRINT PLANNING** (2h início cada sprint)
- Review do backlog
- Story point estimation
- Task breakdown
- Commitment do sprint

### **SPRINT REVIEW** (1h final cada sprint)
- Demo das features
- Feedback collection
- Retrospective rápida

### **RETROSPECTIVE** (30 min final cada sprint)
- What went well?
- What could improve?
- Action items para próximo sprint

---

## **📊 METRICS & KPIs**

### **DEVELOPMENT METRICS**
- **Velocity**: Story points completados por sprint
- **Burndown**: Tasks restantes vs tempo
- **Quality**: Bugs encontrados vs resolvidos
- **Cycle Time**: Tempo médio por task

### **PRODUCT METRICS**
- **User Testing**: Success rate no onboarding
- **Performance**: FPS médio durante gameplay
- **Engagement**: Tempo médio de sessão
- **Satisfaction**: NPS score (target: 7+)

---

## **🚨 RISK MANAGEMENT**

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Scope creep | High | High | Document rígido + daily review |
| Technical debt | Medium | High | Code review + refactoring time |
| Performance issues | Medium | Medium | Profiling desde Sprint 1 |
| Balancing problems | High | Medium | Playtesting frequente |
| Time overrun | Medium | High | Buffer de 20% em estimativas |

---

## **✅ DEFINITION OF READY**

**Para Story entrar em Sprint:**
- [ ] Acceptance criteria claramente definidos
- [ ] Story points estimados
- [ ] Dependencies identificadas
- [ ] Wireframes/mockups (se UI)
- [ ] Technical approach definido

**Para Task ser iniciado:**
- [ ] Story aprovada pelo PO
- [ ] Technical design finalizado
- [ ] Assignee disponível
- [ ] Blocker dependencies resolvidos