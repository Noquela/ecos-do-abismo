# 🎮 Roadmap Detalhado – Projeto Hack 'n' Slash + Bullet Hell Egípcio [MIGRAÇÃO ISOMÉTRICA]

## 📋 Visão Geral do Projeto
**Conceito:** Hack 'n' slash isométrico 2D inspirado em Hades, com temática egípcia e mecânicas bullet hell
**Duração estimada:** 5-7 meses (18 sprints de 1-2 semanas cada)
**Target:** MVP jogável de 10-15 minutos com assets gerados por IA local

## 🔄 STATUS ATUAL: MIGRAÇÃO PARA VISTA ISOMÉTRICA
**Situação:** Jogo funcionando em vista top-down, migrando para vista isométrica verdadeira
**Gameplay Core:** ✅ Completo (movimento, combat, projectiles, weapons, enemies)
**Próximo objetivo:** Implementar vista isométrica mantendo toda funcionalidade existente

---

## 🛠 Stack Técnico Detalhado

### **Engine e Desenvolvimento**
- **Godot 4.3+** (2D isométrico com projeção ortogonal)
- **Claude Code (MCP)** para automação de tarefas
- **GDScript** como linguagem principal
- **Resolução base:** 1920x1080 (escala para diferentes resoluções)

### **Pipeline de IA Local PREMIUM (RTX 5070 Otimizado)**
#### **Geração Visual Maximum Quality**
- **SDXL Base + Refiner** (qualidade cinematográfica)
- **SD3.5-Large** para assets complexos quando disponível
- **AnimateDiff v3 + SparseCtrl** para animações fluidas (16-24 frames)
- **ControlNet XL Suite**: Canny, Depth, OpenPose, Tile para consistência perfeita
- **ComfyUI + Manager** como interface principal
- **ESRGAN 4x-UltraSharp** para upscaling cristalino
- **LCM-LoRA** para speed boost quando necessário

#### **LoRAs e Embeddings Customizados**
- **Pixel Art XL** + **Isometric RPG** + **Egyptian Mythology**
- **Style mixing** entre Old Kingdom, Middle Kingdom, New Kingdom
- **Character consistency** embeddings auto-gerados
- **CLIP scoring** para quality assurance automática

#### **Pós-processamento Premium**
- **rembg** (modelo `u2net`) + **BiRefNet** para transparência perfeita
- **waifu2x** + **ESRGAN** pipeline duplo
- **Aseprite CLI** para spritesheets profissionais
- **ImageMagick** + **OpenCV** para batch processing
- **Auto-import** no Godot com metadata preservation

#### **Geração Sonora Cinematográfica**
- **MusicGen Large** (3.3B params) para trilhas épicas
- **AudioCraft** para SFX complexos e atmosféricos
- **Bark** para voiceovers e narrativas
- **RVC** para processamento vocal quando necessário
- **Audio upsampling** para qualidade studio

### **Estrutura de Pastas do Projeto**
```
projeto_egipcio/
├── godot_project/          # Projeto Godot principal
├── ai_assets/             # Assets gerados por IA
│   ├── sprites/           # Sprites individuais
│   ├── animations/        # Sequências de animação
│   ├── tiles/            # Tiles para cenários
│   ├── audio/            # Música e SFX
│   └── concepts/         # Arte conceitual
├── tools/                # Scripts de automação
│   ├── sprite_processor.py
│   ├── animation_builder.py
│   └── audio_converter.py
└── prompts/              # Prompts para IA organizados
```

---

## 📈 Fases Detalhadas - MIGRAÇÃO ISOMÉTRICA

### **🔄 Fase 1 – MIGRAÇÃO ISOMÉTRICA (3 sprints)**
> **OBJETIVO:** Converter o jogo top-down existente para vista isométrica verdadeira mantendo toda funcionalidade atual

#### **Sprint 1: Camera & Input System Isométrico (Semana 1-2)**

**Objetivos:**
- Implementar câmera isométrica (30° rotation)
- Converter input WASD para movimento diagonal isométrico
- Manter toda funcionalidade de movimento existente

**🚨 SISTEMAS A MIGRAR:**
- [x] **BASE FUNCIONAL:** Sistema top-down completo ✅
- [ ] **CAMERA:** Rotação 30° para vista isométrica
- [ ] **INPUT:** Conversão WASD → coordenadas isométricas
- [ ] **COORDINATE SYSTEM:** Funções world_to_iso() e iso_to_world()
- [ ] **MOVEMENT:** Ajustar CharacterBody2D para perspectiva
- [ ] **COLLISION:** Validar collision detection isométrico

**🔥 INTEGRAÇÃO ISOMÉTRICA CRÍTICA:**
- [ ] Camera2D com rotação Z = 30° (ou 26.565°)
- [ ] Input vector conversion para diagonal movement
- [ ] Manter smooth camera following
- [ ] Preservar dash e i-frames functionality
- [ ] Debug visual adaptado para perspectiva isométrica

**Critérios de aceitação:**
- [ ] Vista isométrica funcionando (não mais top-down)
- [ ] WASD move diagonalmente correto na perspectiva
- [ ] Dash funciona na direção visual correta
- [ ] Camera segue player suavemente em isométrico
- [ ] Performance mantida > 60 FPS
- [ ] **VALIDAÇÃO VISUAL**: Player se move "naturalmente" na vista isométrica

#### **Sprint 2: Sprites & Collision Isométrico (Semana 3-4)**

**Objetivos:**
- Adaptar sistema visual para perspectiva isométrica
- Ajustar collision detection se necessário
- Preparar pipeline para sprites isométricos

**🚨 SISTEMAS A MIGRAR:**
- [x] **COMBAT BASE:** Sistema de armas completo ✅
- [ ] **SPRITE RENDERING:** Adaptar _draw() para perspectiva isométrica
- [ ] **WEAPON ORIENTATION:** Ajustar orientação armas para vista isométrica
- [ ] **COLLISION DETECTION:** Validar hitboxes em perspectiva
- [ ] **VISUAL FEEDBACK:** Cores e estados adaptados para isométrico
- [ ] **PLACEHOLDER SPRITES:** Redesenhar formas para perspectiva isométrica

**🔥 INTEGRAÇÃO ISOMÉTRICA CRÍTICA:**
- [ ] Sistema _draw() renderizando em coordenadas isométricas
- [ ] Weapon holder orientação correta na perspectiva
- [ ] Mouse targeting adaptado para isométrico
- [ ] Collision shapes funcionando corretamente
- [ ] Debug visuals em perspectiva isométrica
- [ ] Dash visual correto na vista isométrica

**Critérios de aceitação:**
- [ ] Sprites/formas renderizando corretamente em isométrico
- [ ] Sistema de combate funcionando na nova perspectiva
- [ ] Orientação de armas visual correta
- [ ] Collision detection preciso
- [ ] **VALIDAÇÃO VISUAL**: Combat system "natural" em vista isométrica

**Weapons specs:**
- **Khopesh (Espada):** 25 dano, 1.5 ataques/seg, alcance 80px
- **Lança de Rá:** 35 dano, 1.0 ataques/seg, alcance 120px  
- **Machado de Sobek:** 50 dano, 0.7 ataques/seg, alcance 100px

#### **Sprint 3: Projectiles & Bullet Hell Isométrico (Semana 5-6)**

**Objetivos:**
- Adaptar sistema de projéteis para vista isométrica
- Manter bullet hell patterns funcionando
- Completar migração isométrica dos sistemas core

**🚨 SISTEMAS A MIGRAR:**
- [x] **BULLET HELL BASE:** ProjectilePool e 15+ patterns ✅
- [x] **ENEMY AI BASE:** Estados e pathfinding completos ✅
- [ ] **PROJECTILE TRAJECTORY:** Adaptar trajetórias para perspectiva isométrica
- [ ] **BULLET PATTERNS:** Ajustar patterns (espiral, círculo, etc) para vista isométrica
- [ ] **ENEMY POSITIONING:** Ajustar spawn e movimento para isométrico
- [ ] **PATHFINDING:** Validar NavigationAgent2D em perspectiva

**🔥 INTEGRAÇÃO ISOMÉTRICA CRÍTICA:**
- [ ] Projéteis seguindo trajetória visual correta
- [ ] Bullet patterns mantendo elegância visual
- [ ] Enemy AI navegando corretamente na perspectiva
- [ ] Collision projétil→player precisa em isométrico
- [ ] Visual feedback de impactos adaptado
- [ ] Object pooling mantendo performance

**Critérios de aceitação:**
- [ ] Projéteis voando na direção visual correta
- [ ] Bullet patterns elegantes em vista isométrica
- [ ] Enemies perseguindo/atacando corretamente
- [ ] Performance > 60 FPS com 100+ projéteis
- [ ] **VALIDAÇÃO VISUAL**: Bullet hell "natural" em isométrico
- [ ] **MIGRAÇÃO COMPLETA**: Todos sistemas core funcionando em vista isométrica

---

### **🎨 Fase 2 – ISOMETRIC CONTENT & ASSETS (3 sprints)**
> **OBJETIVO:** Criar conteúdo específico para vista isométrica e gerar assets por IA

#### **Sprint 4: TileMap Isométrico & Level Design (Semana 7-8)**

**Objetivos:**
- Implementar TileMap isométrico (tiles em diamante)
- Criar layouts de sala específicos para vista isométrica
- Sistema de colisão isométrico para cenário

**🚨 SISTEMAS A IMPLEMENTAR:**
- [ ] **TILEMAP ISOMETRIC:** Implementar sistema de tiles diamante
- [ ] **TILE COLLISION:** Sistema de colisão para tiles isométricos
- [ ] **ROOM LAYOUTS:** Designs de sala otimizados para vista isométrica
- [ ] **NAVIGATION:** NavigationRegion2D para pathfinding isométrico
- [ ] **LIGHTING:** Sistema básico de lighting para profundidade isométrica
- [ ] **CAMERA BOUNDS:** Limites de câmera para salas isométricas

**🔥 INTEGRAÇÃO ISOMÉTRICA CRÍTICA:**
- [ ] TileMap renderizando corretamente em perspectiva
- [ ] Player navegando naturalmente no cenário isométrico
- [ ] Enemies usando pathfinding correto nos tiles
- [ ] Collision detection precisa entre player/enemies/tiles
- [ ] Visual depth cues para orientação espacial
- [ ] Performance otimizada para rendering isométrico

**Critérios de aceitação:**
- [ ] TileMap isométrico funcional e navegável
- [ ] Player não "flutua" ou clippa nos tiles
- [ ] Enemies navegam corretamente no cenário
- [ ] Visual hierarchy clara (frente/trás)
- [ ] **VALIDAÇÃO VISUAL**: Cenário isométrico convincente e jogável

**Specs dos projéteis:**
- **Básico:** 10 dano, velocidade 300px/s
- **Fogo (Ra):** 12 dano, velocidade 250px/s, queima por 2s
- **Gelo (Nut):** 8 dano, velocidade 200px/s, slow por 1s

#### **Sprint 5: Assets IA Isométricos (Semana 9-10)**

**Objetivos:**
- Gerar sprites isométricos profissionais via ComfyUI + SDXL
- Substituir placeholders por assets egípcios de alta qualidade
- Pipeline automatizado para geração isométrica

**🚨 GERAÇÃO IA ESPECÍFICA ISOMÉTRICA:**
- [ ] **PROMPTS ISOMÉTRICOS:** Adaptar prompts para "isometric view, 30-degree angle"
- [ ] **PLAYER SPRITES:** Guerreiro egípcio em perspectiva isométrica
- [ ] **ENEMY SPRITES:** Múmia, Sacerdote, etc. em vista isométrica
- [ ] **WEAPON SPRITES:** Khopesh, Spear, Axe orientados isometricamente
- [ ] **PROJECTILE SPRITES:** Fire bolt, ice shard em perspectiva correta
- [ ] **PIPELINE BATCH:** Sistema automático para geração em lote

**🔥 INTEGRAÇÃO DE ASSETS ISOMÉTRICOS:**
- [ ] ComfyUI configurado para prompts isométricos
- [ ] rembg + transparência funcionando para sprites isométricos
- [ ] Auto-import Godot preservando orientação
- [ ] Teste A/B: placeholders vs. IA sprites
- [ ] Validação visual: assets "encaixam" na perspectiva
- [ ] Performance mantida com sprites reais

**Critérios de aceitação:**
- [ ] Sprites isométricos de alta qualidade gerados
- [ ] Assets integrados mantendo funcionalidade
- [ ] Visual consistency entre todos elementos
- [ ] **VALIDAÇÃO VISUAL**: Jogo com visual profissional isométrico

#### **Sprint 6: Polish Isométrico & Performance (Semana 11-12)**

**Objetivos:**
- Otimizar performance para vista isométrica
- Polish visual e UX para perspectiva isométrica
- Validação completa do sistema migrado

**🚨 POLISH & OPTIMIZATION ISOMÉTRICA:**
- [ ] **PERFORMANCE:** Profiling específico para rendering isométrico
- [ ] **VISUAL POLISH:** Depth sorting, Z-ordering correto
- [ ] **UX OPTIMIZATION:** Interface adaptada para perspectiva
- [ ] **CAMERA POLISH:** Smooth follow otimizado para isométrico
- [ ] **LIGHTING EFFECTS:** Sombras e profundidade visual
- [ ] **AUDIO POSITIONING:** Som posicional adaptado para perspectiva

**🔥 INTEGRAÇÃO FINAL ISOMÉTRICA:**
- [ ] Todos sistemas funcionando harmoniosamente
- [ ] Performance > 60 FPS garantida
- [ ] Visual quality profissional mantida
- [ ] UX intuitiva na nova perspectiva
- [ ] Bug-free gameplay em vista isométrica
- [ ] Ready para próximas fases de conteúdo

**Critérios de aceitação:**
- [ ] Jogo completamente funcional em vista isométrica
- [ ] Performance otimizada e estável
- [ ] Visual polish profissional
- [ ] **VALIDAÇÃO FINAL**: Sistema isométrico completo e pronto para expansão

---

### **🏛 Fase 3 – Estrutura e Progressão (3 sprints)**

#### **Sprint 7: Sistema de Salas (Semana 13-14)**

**Objetivos:**
- Geração/carregamento de diferentes layouts de sala
- Transições suaves entre áreas

**Tarefas técnicas:**
- [ ] Classe `Room` com diferentes tipos
- [ ] Sistema de portas com triggers
- [ ] TileMap isométrico básico
- [ ] Gerador procedural simples (4-6 layouts)
- [ ] Sistema de loading entre salas
- [ ] Minimap básico

**Tipos de sala:**
- **Combate:** Inimigos obrigatórios
- **Elite:** Mini-boss + recompensa maior
- **Tesouro:** Upgrade garantido
- **Boss:** Chefão principal

#### **Sprint 8: Sistema de Upgrades "Bênçãos dos Deuses" (Semana 15-16)**

**Objetivos:**
- Sistema de power-ups inspirado em Hades
- Progressão dentro da run

**Tarefas técnicas:**
- [ ] Classe base `Blessing` com diferentes raridades
- [ ] UI de seleção de bênçãos
- [ ] 15+ bênçãos divididas por deuses
- [ ] Sistema de sinergias básicas
- [ ] Persistência temporal (durante a run)

**Bênçãos por Deus:**
- **Rá (Fogo):** +dano, projéteis flamejantes, explosões
- **Ísis (Cura):** regeneração, escudos, vida extra  
- **Thoth (Magia):** cooldown reduzido, múltiplos projéteis
- **Anúbis (Morte):** execução, vida roubada, dano crítico

#### **Sprint 9: Loop de Jogo Completo (Semana 17-18)**

**Objetivos:**
- Run completa do início ao fim
- Balance e polimento da progressão

**Tarefas técnicas:**
- [ ] Menu principal funcional
- [ ] Sequência de 8-12 salas por run
- [ ] Boss final "Set, Deus do Caos"
- [ ] Telas de vitória/derrota
- [ ] Sistema de restart rápido
- [ ] Balanceamento baseado em playtest

---

### **🎨 Integração de Assets IA por Sprint**

**ESTRATÉGIA: Gameplay primeiro, Assets depois - INTEGRAÇÃO AO LOOP PRINCIPAL É CRÍTICA**

> ⚠️ **IMPORTANTE**: Cada sistema implementado DEVE ser integrado ao loop principal do jogo e validado através de gameplay real. Não basta criar o código - tem que funcionar visualmente e ser testável pelo usuário.

**CHECKLIST DE INTEGRAÇÃO OBRIGATÓRIO:**
- ✅ Sistema funciona via código
- ✅ Sistema está conectado ao loop principal (`_ready()`, `_physics_process()`, `_process()`)
- ✅ Sistema tem feedback visual (sprite, cor, debug draw)
- ✅ Sistema responde a input do jogador
- ✅ Sistema pode ser validado em tempo real (não apenas "tela cinza")

✅ **Sprint 1-3: MECÂNICAS CORE COMPLETAS**
- Sistema de movimento e dash ✅
- Sistema de combate melee ✅
- Sistema bullet hell completo ✅
- Inimigos caster e híbridos ✅
- Object pooling otimizado ✅

🎯 **INÍCIO DA GERAÇÃO IA: SPRINT 4 (AGORA)**

#### **Sprint 4: Assets Visuais Básicos [INÍCIO]**
- ⚡ **Player warrior sprite** (guerreiro egípcio com khopesh)
- ⚡ **Projéteis básicos visuais** (fire bolt, ice shard, light beam)
- ⚡ **Setup ComfyUI pipeline** com templates egípcios
- ⚡ **Teste de qualidade** RTX 5070 optimized
- **Status**: 🚀 INICIANDO

#### **Sprint 5: Inimigos e Armas**
- Múmia inimigo básico (idle, walk, attack)
- Sacerdote de Thoth caster visual
- Khopesh weapon sprite refinado
- Background tiles básicos

#### **Sprint 6-7: Assets de Combate Avançados**
- Spear of Ra e Axe of Sobek sprites
- Animações de ataque (4-8 frames)
- Efeitos de impacto e partículas
- Guerreiro-Sacerdote híbrido visual

### **🎨 Fase 4 – Integração de IA (4 sprints)**

#### **Sprint 10: Pipeline de Sprites (Semana 19-20)**

**Objetivos:**
- Workflow automatizado para geração de sprites
- Consistência visual entre assets

**Tarefas técnicas:**
- [ ] Configurar ComfyUI com modelos necessários
- [ ] Script Python para geração em batch
- [ ] Prompts organizados por categoria
- [ ] Sistema de style guide automático
- [ ] Integração com rembg para transparência
- [ ] Importação automática no Godot

**Prompts base:**
```
Player: "egyptian warrior, isometric view, pixel art style, khopesh sword, gold armor, 64x64, transparent background"
Enemy: "ancient egyptian mummy, isometric view, pixel art, bandages, glowing eyes, 48x48"
```

#### **Sprint 11: Sistema de Animações (Semana 21-22)**

**Objetivos:**
- Animações fluidas geradas por IA
- Pipeline otimizada para sprites pequenos

**Tarefas técnicas:**
- [ ] Setup do AnimateDiff no ComfyUI
- [ ] Script para conversão video → spritesheet
- [ ] Configuração automática de `AnimatedSprite2D`
- [ ] Sistema de interpolação para frames faltantes
- [ ] Otimização de tamanho dos arquivos

**Animações necessárias:**
- Player: idle, walk, dash, attack (x3 armas), hurt, death
- Inimigos: idle, walk, attack, hurt, death, special

#### **Sprint 12: Tilesets e Ambientação (Semana 23-24)**

**Objetivos:**
- Cenários coesos e atmosféricos
- Tiles modulares para diferentes biomas

**Tarefas técnicas:**
- [ ] Geração de tiles base (chão, paredes, decoração)
- [ ] Script para corte automático em grid
- [ ] Configuração de TileMap no Godot
- [ ] Sistema de variações automáticas
- [ ] Iluminação 2D básica

**Biomas planejados:**
- **Tumba Real:** Dourado, hieróglifos, tochas
- **Templo de Rá:** Vermelho/laranja, símbolos solares
- **Submundo de Osíris:** Azul escuro, cristais, água

#### **Sprint 13: Áudio Procedural (Semana 25-26)**

**Objetivos:**
- Trilha sonora dinâmica
- SFX coerentes com o tema

**Tarefas técnicas:**
- [ ] Setup MusicGen local
- [ ] Geração de loops musicais por bioma
- [ ] SFX usando AudioGen
- [ ] Sistema de música adaptativa
- [ ] Compressão e otimização de áudio

**Áudio necessário:**
- 3 trilhas de combate (por bioma)
- 1 trilha de menu
- 20+ SFX (ataques, passos, magia, UI)

---

### **🏆 Fase 5 – Conteúdo e Polimento (3 sprints)**

#### **Sprint 14: Boss Fights Épicos (Semana 27-28)**

**Objetivos:**
- 3 chefões únicos com mecânicas distintas
- Fights memoráveis e balanceados

**Boss roster:**
- **Set (Final):** 300 HP, 4 fases, raios + tornados
- **Sobek:** 250 HP, charges + ondas aquáticas  
- **Sekhmet:** 200 HP, chuvas de fogo + dash flamejante

#### **Sprint 15: UI/UX Polido (Semana 29-30)**

**Objetivos:**
- Interface intuitiva e responsiva
- Feedback claro para todas as ações

**Elementos UI:**
- HUD de combate (HP, cooldowns, bênçãos ativas)
- Menu de pausa funcional
- Configurações (áudio, controles, gráficos)
- Tutorial integrado (primeiros 2 minutos)

#### **Sprint 16: Build Final e Distribuição (Semana 31-32)**

**Objetivos:**
- Build otimizado para distribuição
- Testing final e correções críticas

**Tarefas finais:**
- [ ] Optimização de performance
- [ ] Builds para Windows/Linux/Web
- [ ] Documentação para jogadores
- [ ] Trailer/screenshots para divulgação

---

## 📊 Métricas de Sucesso

### **Técnicas**
- Performance: 60+ FPS estável
- Tamanho do build: < 200MB
- Tempo de loading: < 3s entre salas
- Crash rate: < 1% durante uma run

### **Gameplay**
- Duração média da run: 10-15 minutos
- Taxa de completion: > 30% (primeira tentativa)
- Tempo para aprender controles: < 2 minutos
- Rejogabilidade: 5+ runs interessantes

### **Assets IA**
- Consistência visual: 85%+ aprovação em blind test
- Tempo de geração: < 10min por asset
- Taxa de aproveitamento: > 70% dos assets gerados

---

## 🚧 Riscos e Mitigações

### **Riscos Técnicos**
- **IA local lenta:** Usar modelos menores ou cloud backup
- **Assets inconsistentes:** Style guide rígido + manual curation
- **Performance ruim:** Profiling constante + otimização iterativa

### **Riscos de Escopo**
- **Feature creep:** Manter MVP focus, lista de "nice to have"
- **Polish excessivo:** Time-box de 80/20 rule
- **Dependência de IA:** Fallbacks manuais sempre prontos

---

## 🎯 Definição de Pronto (MVP)

**Must Have:**
- ✅ Run completa jogável (entrada → boss → fim)
- ✅ 3 armas + 5 tipos de inimigo + 2 bosses
- ✅ 10+ bênçãos funcionais
- ✅ Bullet patterns variados e desafiadores
- ✅ Assets principais gerados por IA local
- ✅ Build exportável e distribuível

**Nice to Have:**
- 🎁 Mais biomas (deserto, oásis)
- 🎁 Multiplayer local
- 🎁 Sistema de unlocks permanentes
- 🎁 Cutscenes geradas por IA
- 🎁 Modo endless

---

## 📅 Cronograma Visual

```
Mês 1: [████████████] Fundamentos
Mês 2: [████████████] Bullet Hell  
Mês 3: [████████████] Estrutura
Mês 4: [████████████] Assets IA
Mês 5: [████████████] Conteúdo
Mês 6: [████████████] Polimento
```

---

## 🛠 Setup Inicial (Próximas 2 Semanas)

### **Ambiente de Desenvolvimento**
1. **Instalar Godot 4.3+** + templates de export
2. **Configurar Claude Code MCP** com filesystem access
3. **Setup ComfyUI** + baixar modelos base (SD 1.5, AnimateDiff)
4. **Instalar ferramentas:** `rembg`, `aseprite`, `ffmpeg`
5. **Criar estrutura de pastas** do projeto
6. **Testar pipeline básica** (prompt → sprite → Godot)

### **Primeiro Sprint Ready Checklist**
- [ ] Projeto Godot inicializado
- [ ] Input map configurado
- [ ] Cena Player básica criada
- [ ] Claude Code conectado ao projeto
- [ ] Pelo menos 1 sprite gerado por IA testado
- [ ] Git repository configurado
- [ ] Documentação inicial escrita

**Tempo estimado para setup:** 3-5 dias
**Primeiro playtest target:** Final da semana 2