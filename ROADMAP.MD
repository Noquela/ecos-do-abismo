# 🎮 Roadmap Detalhado – Projeto Hack 'n' Slash + Bullet Hell Egípcio

## 📋 Visão Geral do Projeto
**Conceito:** Hack 'n' slash isométrico 2D inspirado em Hades, com temática egípcia e mecânicas bullet hell
**Duração estimada:** 4-6 meses (16 sprints de 1-2 semanas cada)
**Target:** MVP jogável de 10-15 minutos com assets gerados por IA local

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

## 📈 Fases Detalhadas

### **🏗 Fase 1 – Fundamentos do Gameplay (3 sprints)**

#### **Sprint 1: Sistema de Movimento (Semana 1-2)**

**Objetivos:**
- Player controller responsivo com movimento 8-direções
- Sistema de dash com cooldown e i-frames
- Câmera que segue o player suavemente

**Tarefas técnicas:**
- [ ] Criar cena `Player.tscn` com `CharacterBody2D`
- [ ] Script de movimento usando `move_and_slide()`
- [ ] Implementar dash com `Timer` para cooldown
- [ ] Sistema de i-frames usando `Area2D` e `CollisionShape2D`
- [ ] Câmera com `Camera2D` e interpolação suave
- [ ] Input mapping configurável
- [ ] Debug visuals para hitboxes

**Critérios de aceitação:**
- Player se move fluidamente em 8 direções
- Dash funciona com feedback visual (trail/flash)
- Não há stuck em paredes ou objetos
- Performance > 60 FPS em máquina target

#### **Sprint 2: Sistema de Combate Base (Semana 3-4)**

**Objetivos:**
- 3 armas distintas com diferentes stats
- Sistema de hitbox/hurtbox
- Feedback audiovisual para ataques

**Tarefas técnicas:**
- [ ] Classe base `Weapon` com stats (damage, speed, range, knockback)
- [ ] Implementar `MeleeWeapon` que herda de `Weapon`
- [ ] Sistema de `HitBox` e `HurtBox` com layers de colisão
- [ ] Animações de ataque (placeholder retangular)
- [ ] Screen shake para impactos
- [ ] Partículas simples para acertos
- [ ] Sistema de dano com resistências

**Weapons specs:**
- **Khopesh (Espada):** 25 dano, 1.5 ataques/seg, alcance 80px
- **Lança de Rá:** 35 dano, 1.0 ataques/seg, alcance 120px  
- **Machado de Sobek:** 50 dano, 0.7 ataques/seg, alcance 100px

#### **Sprint 3: Inimigos Melee Básicos (Semana 5-6)**

**Objetivos:**
- IA básica de perseguição
- Sistema de estados para inimigos
- Balance inicial de combate

**Tarefas técnicas:**
- [ ] Classe base `Enemy` com FSM (Finite State Machine)
- [ ] Estados: Idle, Chase, Attack, Hurt, Death
- [ ] Pathfinding simples com `NavigationAgent2D`
- [ ] Inimigo básico "Múmia Guerreira" (30 HP, 15 dano)
- [ ] Mini-boss "Guardião Anubis" (100 HP, 25 dano, ataque em área)
- [ ] Spawn system básico
- [ ] Drops simples (health orbs)

---

### **⚡ Fase 2 – Mecânicas Bullet Hell (3 sprints)**

#### **Sprint 4: Inimigos Caster (Semana 7-8)**

**Objetivos:**
- Projéteis básicos que seguem física
- Inimigos que mantêm distância e atacam à distância

**Tarefas técnicas:**
- [ ] Classe `Projectile` com `RigidBody2D`
- [ ] Pool de projéteis para performance
- [ ] Inimigo "Sacerdote de Thoth" (40 HP, projéteis retos)
- [ ] Sistema de mira preditiva
- [ ] Collision layers separadas para projéteis
- [ ] Efeitos visuais para trajetos de projéteis

**Specs dos projéteis:**
- **Básico:** 10 dano, velocidade 300px/s
- **Fogo (Ra):** 12 dano, velocidade 250px/s, queima por 2s
- **Gelo (Nut):** 8 dano, velocidade 200px/s, slow por 1s

#### **Sprint 5: Padrões de Projéteis Avançados (Semana 9-10)**

**Objetivos:**
- Bullet patterns complexos e visualmente interessantes
- Sistema modular para criar novos padrões

**Tarefas técnicas:**
- [ ] Sistema `BulletPattern` com diferentes tipos
- [ ] Padrão "Espiral de Khepri" (projéteis em espiral)
- [ ] Padrão "Leque de Isis" (cone de projéteis)
- [ ] Padrão "Onda de Poseidon" (ondas circulares)
- [ ] Padrão "Chuva de Meteoros" (projéteis que caem do céu)
- [ ] Editor visual para criar padrões (se tempo permitir)

#### **Sprint 6: Inimigos Híbridos (Semana 11-12)**

**Objetivos:**
- Inimigos que alternam entre melee e ranged
- Boss fight básico como teste

**Tarefas técnicas:**
- [ ] Inimigo "Guerreiro-Mago de Seth" (80 HP)
- [ ] FSM expandido com estados de transição
- [ ] Mini-boss "Avatar de Hórus" (150 HP, 3 fases)
- [ ] Telegraphing para ataques especiais
- [ ] Sistema de fases para bosses

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

**ESTRATÉGIA: Gameplay primeiro, Assets depois - INÍCIO CONFIRMADO SPRINT 4**

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