# 🎯 SPRINTS ROGUELIKE EXPANSION - Ecos do Abismo

## 📋 **CONTEXTO**

### **Situação Atual (Sprint 8 Completo)**:
✅ **MVP Funcional**: Sistema de combate + progressão básica
✅ **Interface Polida**: Hub, Loja, Combate com UI premium
✅ **Mecânicas Core**: 8 cartas, upgrades, economia

### **Problema Identificado**:
❌ **"Combate infinito estranho"** - apenas um botão que leva a tela única
❌ **Sem estrutura de jornada** como Slay the Spire
❌ **Falta tensão e risco** real
❌ **Progressão linear e previsível**

### **Objetivo da Expansão**:
🎯 **Transformar em roguelike completo** com estrutura de runs
🎯 **Adicionar tensão e escolhas** significativas
🎯 **Criar progressão não-linear** com múltiplos paths

---

## 🚀 **NOVOS SPRINTS ADICIONAIS**

### **SPRINT 9 - SISTEMA DE RUNS & MAPA** 🗺️
**Objetivo**: Substituir combate infinito por sistema estruturado de runs

**Features**:
- **Mapa de Nodes**: Visual com diferentes tipos de encontros
- **Sistema de Runs**: 3 andares, 15+ nodes cada, boss obrigatório
- **Tipos de Node**: Combate, Elite, Boss, Evento, Descanso, Loja
- **Navegação**: Escolher próximo node no mapa
- **Run State**: HP persistente durante run (não regenera automaticamente)

**Critérios de Sucesso**:
- [ ] Mapa visual navegável implementado
- [ ] Sistema de runs com 3 andares funcionando
- [ ] Diferentes tipos de nodes identificáveis
- [ ] HP persiste durante toda a run
- [ ] Boss fights obrigatórios por andar

---

### **SPRINT 10 - MORTE PERMANENTE & TENSÃO** ☠️ ✅ **COMPLETO**
**Objetivo**: Adicionar risco real e consequências às decisões

**Features**:
- **Permadeath**: Morrer = perder toda a run, volta ao hub ✅
- **HP Limitado**: Não regenera entre combates ✅
- **Mapa em Árvore**: Múltiplas escolhas por layer ✅
- **Risk/Reward**: Continuar machucado vs jogar seguro ✅
- **Run Statistics**: Tracking de runs completadas/falhadas ✅

**Critérios de Sucesso**:
- [x] Sistema de morte permanente funcionando ✅
- [x] HP não regenera automaticamente ✅
- [x] Mapa com múltiplas escolhas implementado ✅
- [x] Estatísticas de runs persistentes ✅
- [x] Tensão palpável durante gameplay ✅

**Nota**: Fogueiras com escolhas movidas para Sprint 10.5

---

### **SPRINT 10.5 - PREPARAÇÃO PARA DECK BUILDING** 🛠️
**Objetivo**: Ajustes preparatórios baseados na análise comparativa com Slay the Spire

**Problema Identificado**:
- Runs são muito similares (sempre mesmas cartas)
- Mapa mostra só próxima layer (falta planejamento estratégico)
- Falta progressão de deck por run (coração do Slay the Spire)

**Features**:
- **Mapa Melhorado**: Mostrar layers futuras (transparentes/locked) para planejamento
- **Run Deck System**: Cada run tem seu próprio deck que evolui
- **Combate com Run Deck**: Usar cartas da run ao invés de cartas fixas do GameData
- **Estrutura Card Rewards**: Preparar para escolhas de cartas pós-combate
- **Fogueiras com Escolhas**: Rest (heal) vs Smith (upgrade carta)

**Critérios de Sucesso**:
- [ ] Mapa mostra contexto de layers futuras
- [ ] Sistema run_deck implementado e funcional
- [ ] Combate usa cartas do run_deck
- [ ] Estrutura pronta para card rewards
- [ ] Fogueiras oferecem escolha heal vs upgrade

---

### **SPRINT 11 - DRAFT DE CARTAS & RECOMPENSAS** 🃏
**Objetivo**: Implementar sistema completo de draft e recompensas pós-combate

**Features** (base já preparada no Sprint 10.5):
- **Draft Pós-Combate**: Escolher 1 de 3 cartas após vitória
- **Pool Expandido**: 25+ cartas diferentes disponíveis para draft
- **Recompensas Variadas**: Cartas + ouro + (raramente) relíquias
- **Interface de Draft**: Tela bonita para escolher cartas
- **Sinergias Básicas**: Cartas que funcionam bem juntas
- **Raridades**: Comum, Incomum, Raro (diferentes pools)
- **Remove Cards**: Opção de remover cartas ruins na loja

**Critérios de Sucesso**:
- [ ] Sistema de draft funcionando após cada combate
- [ ] Pool de 25+ cartas implementado e balanceado
- [ ] Interface de draft clara e intuitiva
- [ ] Recompensas variadas (não só cartas)
- [ ] Sinergias básicas funcionando
- [ ] Opção de skip carta se não quiser nenhuma

---

### **SPRINT 12 - RELÍQUIAS & MODIFICADORES** 💎
**Objetivo**: Adicionar modificadores passivos que alteram gameplay

**Features**:
- **Relíquias**: Modificadores passivos únicos
- **Drop em Elites/Boss**: Recompensas especiais por risco
- **Gameplay Alterations**: Relíquias que mudam regras fundamentais
- **Stacking**: Múltiplas relíquias interagindo
- **Visual Feedback**: Mostrar relíquias ativas e efeitos

**Critérios de Sucesso**:
- [ ] Sistema de relíquias implementado
- [ ] 15+ relíquias com efeitos únicos
- [ ] Drop em elite/boss fights funcionando
- [ ] Modificações de gameplay visíveis
- [ ] Interface para mostrar relíquias ativas

---

### **SPRINT 13 - EVENTOS & NARRATIVA** 📖
**Objetivo**: Adicionar eventos narrativos com escolhas significativas

**Features**:
- **Eventos Aleatórios**: Encontros não-combate no mapa
- **Escolhas Múltiplas**: 2-3 opções com consequências diferentes
- **Risk/Reward**: Eventos que oferecem ganhos vs riscos
- **Narrativa**: Textos que constroem atmosfera do jogo
- **Consequências**: Eventos que afetam resto da run

**Critérios de Sucesso**:
- [ ] 10+ eventos únicos implementados
- [ ] Sistema de escolhas funcionando
- [ ] Consequências aplicadas corretamente
- [ ] Narrativa coerente com tema
- [ ] Balanceamento risk/reward dos eventos

---

### **SPRINT 14 - BOSS FIGHTS ÚNICOS** 👹
**Objetivo**: Criar boss fights memoráveis com mecânicas especiais

**Features**:
- **Boss por Andar**: 3 bosses únicos com mecânicas diferentes
- **Padrões Únicos**: Cada boss com comportamento específico
- **Fases**: Bosses que mudam durante o combate
- **Recompensas Especiais**: Cartas/relíquias únicas de boss
- **Visual Polish**: Bosses com visual distinto

**Critérios de Sucesso**:
- [ ] 3 bosses únicos implementados
- [ ] Mecânicas especiais por boss funcionando
- [ ] Sistema de fases implementado
- [ ] Recompensas especiais balanceadas
- [ ] Visual feedback de qualidade

---

### **SPRINT 15 - META-PROGRESSÃO & UNLOCKS** 🔓
**Objetivo**: Adicionar progressão entre runs para retenção

**Features**:
- **Unlock System**: Cartas/relíquias desbloqueadas por achievements
- **Character Progress**: Múltiplos personagens com decks diferentes
- **Achievement System**: Objetivos que direcionam gameplay
- **Collection**: Ver todas as cartas/relíquias descobertas
- **Statistics**: Dados detalhados de performance

**Critérios de Sucesso**:
- [ ] Sistema de unlocks funcionando
- [ ] 2+ personagens com decks únicos
- [ ] Achievement system implementado
- [ ] Collection/gallery completa
- [ ] Estatísticas detalhadas persistentes

---

## 📊 **CRONOGRAMA EXPANDIDO**

### **Fases Atuais (Completas)**:
- ✅ **SPRINT 1-4**: Fundação do combate
- ✅ **SPRINT 5-6**: Progressão permanente
- ✅ **SPRINT 7-8**: Polish visual e UX

### **Expansão Roguelike (Novos)**:
- 🎯 **SPRINT 9**: Sistema de Runs & Mapa (1 semana)
- 🎯 **SPRINT 10**: Morte Permanente & Tensão (1 semana)
- 🎯 **SPRINT 11**: Draft de Cartas & Builds (1 semana)
- 🎯 **SPRINT 12**: Relíquias & Modificadores (1 semana)
- 🎯 **SPRINT 13**: Eventos & Narrativa (1 semana)
- 🎯 **SPRINT 14**: Boss Fights Únicos (1 semana)
- 🎯 **SPRINT 15**: Meta-Progressão & Unlocks (1 semana)

**Total Adicional**: 7 semanas para transformação completa

---

## 🎮 **TRANSFORMAÇÃO ESPERADA**

### **ANTES (Sprint 8)**:
```
Hub → [COMBATE] → Tela infinita de combate → Sair quando quiser
```

### **DEPOIS (Sprint 15)**:
```
Hub → [NOVA RUN] → Escolher personagem → Mapa com paths →
Combate/Evento/Elite → Draft carta → Fogueira (heal vs upgrade) →
Boss fight → Próximo andar → ... → Victoria ou Morte →
Unlocks/Achievements → Repeat com nova estratégia
```

### **Mudanças Fundamentais**:
- ❌ Combate infinito → ✅ Runs estruturadas
- ❌ Zero risco → ✅ Morte permanente
- ❌ Cartas fixas → ✅ Draft dinâmico
- ❌ Progressão linear → ✅ Builds únicos por run
- ❌ Sem objetivos → ✅ Bosses e achievements
- ❌ Sem tensão → ✅ Decisões significativas

---

## ⚠️ **CONSIDERAÇÕES DE IMPLEMENTAÇÃO**

### **Ordem Recomendada**:
1. **Sprint 9 PRIMEIRO** - Base do sistema de runs
2. **Sprint 10** - Adiciona tensão real
3. **Sprint 11** - Torna builds interessantes
4. **Sprint 12** - Adiciona profundidade
5. **Sprint 13** - Adiciona variedade
6. **Sprint 14** - Adiciona climax
7. **Sprint 15** - Adiciona retenção

### **Dependências**:
- Sprint 11 depende de Sprint 9 (draft precisa de runs)
- Sprint 12 depende de Sprint 9 (relíquias dropam em runs)
- Sprint 14 depende de Sprint 9 (bosses são parte do mapa)

### **Esforço vs Impacto**:
- **Sprint 9**: Alto esforço, altíssimo impacto (transforma o jogo)
- **Sprint 10**: Médio esforço, alto impacto (adiciona tensão)
- **Sprint 11**: Alto esforço, altíssimo impacto (replay value)
- **Sprint 12-15**: Médio esforço cada, alto impacto cumulativo

---

## 🎯 **RESULTADO FINAL**

### **De MVP para Roguelike Completo**:
Após os 7 sprints adicionais, "Ecos do Abismo" terá:

✅ **Estrutura de Slay the Spire**: Mapa, runs, bosses
✅ **Tensão Real**: Morte permanente, HP limitado
✅ **Replay Value**: Draft, relíquias, eventos aleatórios
✅ **Progressão Significativa**: Unlocks, achievements, múltiplos chars
✅ **Experiência Premium**: Polimento visual mantido

**Status**: 🚀 **PRONTO PARA TRANSFORMAÇÃO EM ROGUELIKE COMPLETO**