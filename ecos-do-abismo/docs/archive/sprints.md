# 🏃‍♂️ Plano de Sprints - Experiência do Jogador Primeiro

## FILOSOFIA DO DESENVOLVIMENTO

### Prioridade: Experiência Antes de Tecnologia
**"Cada sprint entrega uma SENSAÇÃO específica que o jogador deve sentir"**

Seguimos a estrutura dos MDs:
1. **🎮 EXPERIÊNCIA** - Como o jogador deve se sentir?
2. **🔗 INTEGRAÇÃO** - Como se conecta com outras features?
3. **⚙️ ARQUITETURA** - Código que suporta a experiência

### Critérios de Aprovação por Sprint
✅ **EXPERIÊNCIA ENTREGUE:** O jogador sente o que foi planejado?
✅ **INTEGRAÇÃO FUNCIONANDO:** Features se conectam organicamente?
✅ **ARQUITETURA SÓLIDA:** Código suporta expansão futura?

---

## Sprint 1: CORE LOOP - "Tensão de Escolha" (2 semanas)

### 🎮 EXPERIÊNCIA ALVO
**Sentimento:** "Cada carta que jogo é uma decisão pesada"

**User Story:** *Como jogador, quero sentir que cada carta que escolho tem consequências reais e permanentes, forçando-me a calcular riscos constantemente.*

#### Momentos Críticos da Experiência:
1. **VER A CARTA:** "Eco Fraco parece seguro, Eco Forte parece perigoso..."
2. **CALCULAR CUSTO:** "Tenho 6 Vontade, esta carta custa 4..."
3. **ESCOLHER ECO:** "Arrisco Corrupção ou jogo seguro?"
4. **VER CONSEQUÊNCIA:** "Funcionou! Mas perdi 15% de sanidade..."

### 📋 TAREFAS BASEADAS EM MDs

#### **Semana 1: Setup + Core Card Loop**
📖 **CONSULTAR:** `mecanica.md` (linha 73-106), `cartas.md` (linha 13-43), `interface.md` (linha 16-43)

**🎯 Meta:** Jogar carta → causar dano → feedback visual instantâneo

**Dia 1-2: Fundação da Experiência**
- ✅ Configurar projeto 3440x1440@165fps (`interface.md` linha 228-243)
- ✅ Implementar `PlayerResources.gd` (`recursos.md` linha 90-113)
- ✅ Criar `GameManager.gd` singleton (`mecanica.md` linha 108-134)

**Dia 3-4: Dual Card System**
- [ ] **CRÍTICO:** Implementar `Card.gd` com eco_fraco/eco_forte (`mecanica.md` linha 139-173)
- [ ] **CRÍTICO:** Criar `EcoEffect.gd` para efeitos duais (`mecanica.md` linha 175-211)
- [ ] **CRÍTICO:** Sistema spend_vontade() + add_corrupcao() (`recursos.md` linha 118-139, 143-167)

**Dia 5: TESTE DA EXPERIÊNCIA**
- [ ] Jogador consegue jogar carta e VER custos diferentes?
- [ ] Sente diferença entre Eco Fraco (seguro) e Forte (perigoso)?
- [ ] Feedback visual instantâneo (<200ms)?

#### **Semana 2: Interface + Basic Enemy**
📖 **CONSULTAR:** `interface.md` (linha 109-119, 142-170), `inimigos.md` (linha 16-30)

**Dia 6-7: Interface que Comunica Tensão**
- [ ] Implementar `CardDisplay.tscn` com dois botões de eco (`interface.md` linha 144-163)
- [ ] **CRÍTICO:** Custos destacados em vermelho quando insuficientes (`interface.md` linha 66)
- [ ] Sistema de hover mostra preview de efeitos (`interface.md` linha 17-19)

**Dia 8-9: Inimigo que Reage**
- [ ] Criar `Enemy.gd` básico com HP visível (`inimigos.md` linha 315-327)
- [ ] **CRÍTICO:** Dano causa screen shake + números voadores (`interface.md` linha 92-105)
- [ ] Inimigo contra-ataca para forçar pressão de recursos

**Dia 10: VALIDAÇÃO COMPLETA**
- [ ] **EXPERIÊNCIA:** Jogador sente tensão ao escolher ecos?
- [ ] **INTEGRAÇÃO:** Recursos, cartas e inimigo funcionam juntos?
- [ ] **PERFORMANCE:** 165fps em 3440x1440?

---

## Sprint 2: CORRUPTION FEAR - "Medo Crescente" (2 semanas)

### 🎮 EXPERIÊNCIA ALVO
**Sentimento:** "Minha sanidade está escapando e posso ver isso acontecendo"

**User Story:** *Como jogador, quero VER e SENTIR minha corrupção crescer através de distorções visuais progressivas que me fazem questionar se posso continuar usando poder.*

#### Momentos Críticos da Experiência:
1. **PRIMEIRO ECO FORTE:** "Tela tremelicou... foi normal?"
2. **25% CORRUPÇÃO:** "As cores estão diferentes?"
3. **50% CORRUPÇÃO:** "Algo está muito errado com minha visão"
4. **75% CORRUPÇÃO:** "Realidade está fragmentando, preciso parar!"

### 📋 TAREFAS BASEADAS EM MDs

#### **Semana 1: Visual Corruption System**
📖 **CONSULTAR:** `recursos.md` (linha 141-168), `interface.md` (linha 66-84), `arte.md` (linha 96-225)

**Dia 1-2: Sistema de Corrupção Visual**
- [ ] Implementar `CorruptionVisualManager.gd` (`interface.md` linha 66-85)
- [ ] **CRÍTICO:** 4 tiers visuais (0-25%, 26-50%, 51-75%, 76-100%) (`arte.md` linha 104-109)
- [ ] Shaders progressivos: distorção, fragmentação, caos (`arte.md` linha 115-118)

**Dia 3-4: Feedback Dramático**
- [ ] **CRÍTICO:** Eco Forte causa corruption_pulse() visual (`recursos.md` linha 315-326)
- [ ] Barra de Corrupção treme conforme sobe (`recursos.md` linha 232-245)
- [ ] Screen shake proporcional à Corrupção ganha (`recursos.md` linha 247-268)

**Dia 5: TESTE DE MEDO**
- [ ] Jogador SENTE medo de usar Eco Forte?
- [ ] Distorção visual comunica perda de sanidade?
- [ ] Interface "respira" com a Corrupção?

#### **Semana 2: Game Over + 3 Enemy Types**
📖 **CONSULTAR:** `recursos.md` (linha 328-360), `inimigos.md` (linha 302-378)

**Dia 6-7: Morte por Loucura**
- [ ] Sistema GameOver aos 100% Corrupção (`recursos.md` linha 345-351)
- [ ] **CRÍTICO:** Game over da Corrupção mais dramático que HP (`recursos.md` linha 345-360)
- [ ] Tela de derrota específica para cada tipo de morte

**Dia 8-9: Inimigos com Personalidade**
- [ ] `GuardianAdaptivo` - fica resistente ao dano mais usado (`inimigos.md` linha 302-345)
- [ ] `ParasiteMimetico` - copia habilidades do jogador (`inimigos.md` linha 347-378)
- [ ] `EchoBasico` - reage ao nível de corrupção atual

**Dia 10: VALIDAÇÃO DE MEDO**
- [ ] **EXPERIÊNCIA:** Jogador teme chegar a 100% Corrupção?
- [ ] **INTEGRAÇÃO:** Inimigos diferentes geram tensões diferentes?
- [ ] **BALANCEAMENTO:** Game overs são justos mas ameaçadores?

---

## Sprint 3: ADAPTIVE PARANOIA - "Eles Estão Aprendendo" (2 semanas)

### 🎮 EXPERIÊNCIA ALVO
**Sentimento:** "O inimigo está estudando minha estratégia e se adaptando"

**User Story:** *Como jogador, quero sentir que nunca posso relaxar numa estratégia porque os inimigos estão constantemente aprendendo e forçando-me a evoluir meus padrões.*

#### Momentos Críticos da Experiência:
1. **PRIMEIRA ADAPTAÇÃO:** "Estranho, ele bloqueou diferente desta vez..."
2. **PADRÃO DETECTADO:** "Ele SABIA que eu ia fazer isso!"
3. **CONTRA-ADAPTAÇÃO:** "Preciso mudar completamente minha abordagem"
4. **PARANOIA:** "Não posso ter padrões ou ele me destrói"

### 📋 TAREFAS BASEADAS EM MDs

#### **Semana 1: Behavior Tracking System**
📖 **CONSULTAR:** `inimigos.md` (linha 91-189), `mecanica.md` (linha 44-67)

**Dia 1-2: O Observador**
- [ ] Implementar `PlayerBehaviorTracker.gd` (`inimigos.md` linha 94-189)
- [ ] **CRÍTICO:** Rastrear eco_fraco_count vs eco_forte_count (`inimigos.md` linha 115-122)
- [ ] Detectar padrões nas últimas 10 ações (`inimigos.md` linha 131-137)

**Dia 3-4: Perfis de Jogador**
- [ ] Sistema de classificação: berserker, conservative, predictable (`inimigos.md` linha 155-171)
- [ ] **CRÍTICO:** Inimigos reagem diferente a cada perfil (`inimigos.md` linha 212-218)
- [ ] Feedback visual: olhos brilhando quando observando (`inimigos.md` linha 256-270)

**Dia 5: TESTE DE OBSERVAÇÃO**
- [ ] Jogador PERCEBE que está sendo estudado?
- [ ] Sente necessidade de variar estratégias?
- [ ] Feedback visual comunica adaptação inimiga?

#### **Semana 2: Enemy Evolution**
📖 **CONSULTAR:** `inimigos.md` (linha 191-298)

**Dia 6-7: Escalada Adaptativa**
- [ ] 5 níveis: NAIVE → LEARNING → ADAPTING → COUNTERING → MASTERING (`inimigos.md` linha 198-205)
- [ ] **CRÍTICO:** Cada nível tem visual distinto (`inimigos.md` linha 256-270)
- [ ] Inimigos modificam ações baseado no nível (`inimigos.md` linha 272-297)

**Dia 8-9: Counter-Strategies**
- [ ] Defensive Wall contra jogadores agressivos (`inimigos.md` linha 337-344)
- [ ] Aggression Ramp contra jogadores conservadores
- [ ] **CRÍTICO:** Jogador SENTE a mudança de comportamento

**Dia 10: VALIDAÇÃO DE PARANOIA**
- [ ] **EXPERIÊNCIA:** Jogador sente paranoia adaptativa?
- [ ] **INTEGRAÇÃO:** Adaptação conecta com outros sistemas?
- [ ] **BALANCEAMENTO:** Nunca impossível, sempre desafiador?

---

## Sprint 4: LIVING WORLD - "O Abismo Reage" (2 semanas)

### 🎮 EXPERIÊNCIA ALVO
**Sentimento:** "Este lugar é vivo e está reagindo às minhas ações"

**User Story:** *Como jogador, quero sentir que exploro um mundo consciente que muda baseado no meu comportamento, criando uma sensação de estar numa relação simbiótica com o ambiente.*

#### Momentos Críticos da Experiência:
1. **PRIMEIRA MUDANÇA:** "Esta sala era diferente antes..."
2. **RECONHECIMENTO:** "O mundo está reagindo ao que faço"
3. **ADAPTAÇÃO MÚTUA:** "Preciso mudar porque o lugar mudou"
4. **SIMBIOSE:** "Estamos numa dança psicológica"

### 📋 TAREFAS BASEADAS EM MDs

#### **Semana 1: World Memory System**
📖 **CONSULTAR:** `mundo.md` (linha 90-154), `lore.md` (linha 112-126)

**Dia 1-2: Abismo Consciente**
- [ ] Implementar `AbyssWorldManager.gd` (`mundo.md` linha 92-154)
- [ ] **CRÍTICO:** Mundo "lembra" de ações do jogador (`mundo.md` linha 97-125)
- [ ] Sistema de hostilidade/adaptação baseado em comportamento

**Dia 3-4: Geração Procedural Psicológica**
- [ ] Salas mudam layout baseado em visitas anteriores (`mundo.md` linha 156-210)
- [ ] **CRÍTICO:** Primeira visita = normal, retorno = adaptado
- [ ] Elementos se movem quando jogador não está olhando

**Dia 5: TESTE DE VIDA**
- [ ] Jogador SENTE que mundo é vivo?
- [ ] Percebe mudanças baseadas em suas ações?
- [ ] Ambiente comunica personalidade?

#### **Semana 2: Environmental Storytelling**
📖 **CONSULTAR:** `mundo.md` (linha 212-271), `lore.md` (linha 212-271)

**Dia 6-7: Narrativa Ambiental**
- [ ] Implementar `EnvironmentNarrative.gd` (`mundo.md` linha 214-271)
- [ ] **CRÍTICO:** Fragmentos de lore descobertos organicamente (`lore.md` linha 147-175)
- [ ] Objetos interativos revelam história

**Dia 8-9: Progressão Visual**
- [ ] 3 tipos de sala: Bibliotecas, Campos de Batalha, Jardins (`mundo.md` linha 342-380)
- [ ] **CRÍTICO:** Cada ambiente conta parte da história (`lore.md` linha 65-87)
- [ ] Arte muda baseado na profundidade explorada

**Dia 10: VALIDAÇÃO MUNDIAL**
- [ ] **EXPERIÊNCIA:** Mundo sente vivo e reativo?
- [ ] **INTEGRAÇÃO:** Narrativa emerge naturalmente?
- [ ] **DESCOBERTA:** Lore engaja sem forçar?

---

## Sprint 5: CORRUPTION AESTHETICS - "Beleza na Loucura" (2 semanas)

### 🎮 EXPERIÊNCIA ALVO
**Sentimento:** "A corrupção é terrível mas visualmente fascinante"

**User Story:** *Como jogador, quero experimentar uma progressão visual única onde minha sanidade decadente se torna uma forma de arte perturbadora mas bela.*

#### Momentos Críticos da Experiência:
1. **BELEZA INICIAL:** "Que estilo artístico impressionante"
2. **PRIMEIRA DISTORÇÃO:** "Algo mudou... mas ainda é belo"
3. **FRAGMENTAÇÃO:** "Não consigo olhar para longe desta loucura"
4. **ACEITAÇÃO:** "Esta é minha realidade agora"

### 📋 TAREFAS BASEADAS EM MDs

#### **Semana 1: Progressive Art Corruption**
📖 **CONSULTAR:** `arte.md` (linha 96-226, 228-321)

**Dia 1-2: Tiers Visuais**
- [ ] Implementar `VisualCorruptionManager.gd` (`arte.md` linha 96-226)
- [ ] **CRÍTICO:** 4 shaders: pristine, tainted, corrupted, nightmare (`arte.md` linha 115-118)
- [ ] Cartas "sangram" baseado na corrupção do jogador (`arte.md` linha 209-225)

**Dia 3-4: AI Art Pipeline**
- [ ] Sistema `AIArtPipeline.gd` (`arte.md` linha 228-321)
- [ ] **CRÍTICO:** Paletas específicas por tier de corrupção (`arte.md` linha 246-267)
- [ ] Pós-processamento baseado no nível atual

**Dia 5: TESTE ESTÉTICO**
- [ ] Progressão visual é fascinante?
- [ ] Cada tier tem identidade única?
- [ ] Arte suporta narrativa emocional?

#### **Semana 2: Environmental Art Integration**
📖 **CONSULTAR:** `arte.md` (linha 323-432)

**Dia 6-7: Arte Ambiental**
- [ ] Implementar `EnvironmentArtManager.gd` (`arte.md` linha 323-432)
- [ ] **CRÍTICO:** Temas visuais por ambiente (`arte.md` linha 330-359)
- [ ] Iluminação dinâmica baseada em corrupção (`arte.md` linha 404-431)

**Dia 8-9: Consistency System**
- [ ] `ArtConsistencyValidator.gd` (`arte.md` linha 434-495)
- [ ] **CRÍTICO:** Validação automática de qualidade artística
- [ ] Pipeline de correção para arte inconsistente

**Dia 10: VALIDAÇÃO ESTÉTICA**
- [ ] **EXPERIÊNCIA:** Arte evoca emoções corretas?
- [ ] **INTEGRAÇÃO:** Visual suporta outros sistemas?
- [ ] **QUALIDADE:** Consistência mantida automaticamente?

---

## Sprint 6: NARRATIVE REVELATION - "Verdades Perturbadoras" (2 semanas)

### 🎮 EXPERIÊNCIA ALVO
**Sentimento:** "Cada descoberta torna o mistério mais profundo e perturbador"

**User Story:** *Como jogador, quero descobrir gradualmente uma história perturbadora sobre minha identidade e propósito, com revelações que mudam minha compreensão do mundo.*

#### Momentos Críticos da Experiência:
1. **PRIMEIRO FRAGMENTO:** "História interessante... será real?"
2. **PRIMEIRA CONEXÃO:** "Espera, isso se conecta com aquilo!"
3. **REVELAÇÃO PERTURBADORA:** "Se isso é verdade, então eu..."
4. **COMPREENSÃO FINAL:** "Entendo tudo agora, e é terrível"

### 📋 TAREFAS BASEADAS EM MDs

#### **Semana 1: Discovery System**
📖 **CONSULTAR:** `lore.md` (linha 89-238)

**Dia 1-2: Fragmentos Narrativos**
- [ ] Implementar `NarrativeDiscoverySystem.gd` (`lore.md` linha 91-238)
- [ ] **CRÍTICO:** Controle de timing de revelações (`lore.md` linha 128-175)
- [ ] Base de dados com 4 atos narrativos (`lore.md` linha 242-323)

**Dia 3-4: Conexões Dramáticas**
- [ ] Sistema de conexão entre fragmentos (`lore.md` linha 177-200)
- [ ] **CRÍTICO:** Revelações maiores quando conecta pontos (`lore.md` linha 202-237)
- [ ] Feedback visual para descobertas (`lore.md` linha 365-426)

**Dia 5: TESTE NARRATIVO**
- [ ] Descobertas são orgânicas e satisfatórias?
- [ ] Timing das revelações é dramático?
- [ ] História emerge naturalmente?

#### **Semana 2: Narrative Integration**
📖 **CONSULTAR:** `lore.md` (linha 428-489)

**Dia 6-7: Lore Affects Gameplay**
- [ ] Implementar `NarrativeIntegration.gd` (`lore.md` linha 428-489)
- [ ] **CRÍTICO:** Revelações desbloqueiam novas mecânicas (`lore.md` linha 441-457)
- [ ] UI muda baseado em descobertas narrativas

**Dia 8-9: Complete Story Arc**
- [ ] História completa dos Arquivistas à missão final
- [ ] **CRÍTICO:** 3 revelações maiores que mudam gameplay
- [ ] Múltiplos finais baseados em escolhas e descobertas

**Dia 10: VALIDAÇÃO NARRATIVA**
- [ ] **EXPERIÊNCIA:** História é envolvente e perturbadora?
- [ ] **INTEGRAÇÃO:** Narrativa e gameplay se reforçam?
- [ ] **REVELAÇÃO:** Descobertas mudam compreensão do jogo?

---

## CRITÉRIOS DE VALIDAÇÃO FINAL

### ✅ Sprint 1: CORE LOOP Aprovado?
- [ ] **TENSÃO:** Jogador sente peso das decisões?
- [ ] **RECURSOS:** Vontade e Corrupção funcionam intuitivamente?
- [ ] **FEEDBACK:** Resposta visual <200ms?

### ✅ Sprint 2: CORRUPTION FEAR Aprovado?
- [ ] **MEDO:** Jogador teme usar Eco Forte?
- [ ] **VISUAL:** Distorção comunica perda de sanidade?
- [ ] **GAME OVER:** Morte por loucura é dramática?

### ✅ Sprint 3: ADAPTIVE PARANOIA Aprovado?
- [ ] **PARANOIA:** Jogador sente vigilância constante?
- [ ] **ADAPTAÇÃO:** Estratégias fixas são punidas?
- [ ] **EVOLUÇÃO:** Inimigos claramente aprendem?

### ✅ Sprint 4: LIVING WORLD Aprovado?
- [ ] **VIDA:** Mundo sente consciente e reativo?
- [ ] **MUDANÇA:** Ambientes se adaptam visivelmente?
- [ ] **DESCOBERTA:** Lore emerge organicamente?

### ✅ Sprint 5: CORRUPTION AESTHETICS Aprovado?
- [ ] **BELEZA:** Corrupção é fascinante visualmente?
- [ ] **PROGRESSÃO:** Cada tier tem identidade única?
- [ ] **INTEGRAÇÃO:** Arte suporta experiência emocional?

### ✅ Sprint 6: NARRATIVE REVELATION Aprovado?
- [ ] **MISTÉRIO:** História intriga e perturba?
- [ ] **DESCOBERTA:** Revelações são satisfatórias?
- [ ] **TRANSFORMAÇÃO:** Narrativa muda gameplay?

---

## FILOSOFIA DE VALIDAÇÃO

### ❌ BLOQUEAR se:
- Jogador não sente a experiência alvo
- Features não se integram organicamente
- Performance <60fps em 3440x1440
- Qualquer sistema quebra a imersão

### ✅ APROVAR apenas se:
- Experiência emocional é clara e consistente
- Todas as integrações MD funcionam
- Arquitetura suporta expansão futura
- Feedback da equipe confirma sensações alvo

### 🔄 ITERAR até que:
- Cada sistema entregue sua experiência específica
- Integração seja invisível mas essencial
- Jogador se sinta imerso na dualidade risco/poder