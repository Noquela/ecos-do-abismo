# 🎮 GAME DESIGN DOCUMENT - ECOS DO ABISMO
**Version 2.0 | Updated: 2025-01-20**

---

## **📋 DOCUMENT INFORMATION**

| Field | Value |
|-------|-------|
| **Project Title** | Ecos do Abismo |
| **Genre** | Roguelike Card Game |
| **Platform** | PC (Windows) |
| **Target Audience** | 18-35, Indie Game Enthusiasts |
| **Development Time** | 3 weeks (MVP) |
| **Team Size** | 1 Developer |
| **Document Owner** | Product Lead |
| **Last Updated** | 2025-01-20 |

---

## **🎯 EXECUTIVE SUMMARY**

### **ELEVATOR PITCH**
*"Slay the Spire meets Darkest Dungeon - Um jogo de cartas onde cada decisão te aproxima da vitória... ou da loucura. Sinta tensão psicológica real enquanto escolhe entre poder imediato e sobrevivência a longo prazo."*

### **CORE EXPERIENCE**
**O jogador deve sentir TENSÃO REAL a cada carta jogada:**
- 🤔 "Uso a carta forte e arrisco corrupção?"
- 😰 "Meu HP está baixo, mas a corrupção também..."
- 😤 "Só mais um inimigo, eu consigo!"

### **UNIQUE SELLING PROPOSITION**
1. **Decisões com peso emocional** - Não há escolha "certa"
2. **Feedback imediato e satisfatório** - Cada ação tem resposta visual
3. **Simplicidade elegante** - Profundo mas fácil de aprender
4. **Tensão psicológica autêntica** - Mecânicas criam estresse real

---

## **🕹️ CORE GAMEPLAY**

### **GAME LOOP PRINCIPAL**
```
1. ANÁLISE (2-5s)
   ├── Observa HP atual
   ├── Verifica Vontade disponível
   ├── Calcula risco de Corrupção
   └── Avalia força do inimigo

2. DECISÃO (3-10s)
   ├── Escolhe carta (1 de 3)
   ├── Considera trade-offs
   └── Toma ação

3. EXECUÇÃO (1-2s)
   ├── Carta voa para inimigo
   ├── Dano aparece
   ├── Recursos atualizam
   └── Feedback visual

4. CONSEQUÊNCIA (2-3s)
   ├── Inimigo reage/morre
   ├── Novo inimigo aparece OU
   └── Game over

TOTAL: 8-20 segundos por decisão
```

### **WIN CONDITIONS**
- **Curto prazo**: Matar o inimigo atual
- **Médio prazo**: Sobreviver 10+ inimigos
- **Longo prazo**: Descobrir seus limites pessoais

### **LOSE CONDITIONS**
- **HP = 0**: Dano físico acumulado
- **Corrupção ≥ 100%**: Loucura total
- **Soft lose**: Desistir por frustração (design failure)

---

## **⚔️ COMBAT SYSTEM**

### **TURN STRUCTURE**
```
INÍCIO DO TURNO
├── Regenera +2 Vontade (max 10)
├── 3 cartas ficam disponíveis
└── Jogador escolhe UMA ação

AÇÃO DO JOGADOR
├── Valida recursos necessários
├── Aplica efeitos da carta
├── Consome Vontade
├── Aumenta Corrupção (se aplicável)
└── Feedback visual

REAÇÃO DO INIMIGO
├── Inimigo ataca (dano fixo)
├── Player perde HP
├── Check win/lose conditions
└── Próximo turno OU game over
```

### **TIMING DESIGN**
- **Input Response**: < 100ms
- **Card Animation**: 800ms total
  - 300ms: Carta voa para inimigo
  - 200ms: Impacto + damage number
  - 300ms: Return + UI updates
- **Enemy Death**: 1.2s total
  - 400ms: Death animation
  - 300ms: Fade out
  - 500ms: New enemy spawns

---

## **🃏 CARD SYSTEM**

### **CARD CATEGORIES**

#### **💙 WEAK ATTACKS (Safe Choice)**
```
Golpe Rápido
├── Damage: 8-12
├── Vontade Cost: 1
├── Corruption: 0%
├── Philosophy: "Consistente e seguro"
└── Visual: Azul, efeitos suaves
```

#### **🔥 STRONG ATTACKS (Risky Choice)**
```
Lâmina Sombria
├── Damage: 20-30
├── Vontade Cost: 3
├── Corruption: +15%
├── Philosophy: "Poder com preço"
└── Visual: Vermelho, efeitos intensos
```

#### **💚 SUPPORT CARDS (Utility)**
```
Regeneração Vital
├── Effect: +15 HP
├── Vontade Cost: 2
├── Corruption: 0%
├── Philosophy: "Sobrevivência"
└── Visual: Verde, efeitos curativos
```

### **CARD BALANCE PHILOSOPHY**
- **Linear damage scaling**: Previsível para strategy
- **Exponential corruption cost**: Risk increases dramatically
- **Vontade as tempo**: Prevents spam, encourages planning
- **No RNG in damage**: Skill-based, not luck-based

### **CARD AVAILABILITY**
- **3 cards** sempre disponíveis
- **Pool fixo** de 6 cartas total
- **Sem deck building** - foco na decisão, não na construção
- **Sem cartas únicas** - balance consistency

---

## **💎 RESOURCE SYSTEM**

### **HP (Hit Points)**
```
Range: 0-100
├── Start: 100 HP
├── Loss: Enemy attacks (8-15 damage)
├── Recovery: Support cards (+15 HP)
├── Death: 0 HP
└── Philosophy: "Buffer de segurança física"
```

### **VONTADE (Willpower)**
```
Range: 0-10
├── Start: 10 Vontade
├── Regen: +2 per turn
├── Usage: Card costs (1-3 points)
├── Empty: Cannot play cards
└── Philosophy: "Limita ações por turno"
```

### **CORRUPÇÃO (Corruption)**
```
Range: 0-100%
├── Start: 0%
├── Gain: Strong cards (+10-25%)
├── Loss: Special support cards (-5%)
├── Death: 100%
└── Philosophy: "Preço do poder"
```

### **RESOURCE INTERDEPENDENCY**
```
HP ↔ Survivability
├── Low HP = Urgency
├── High HP = Confidence
└── Support cards heal but cost Vontade

Vontade ↔ Action Economy
├── Low Vontade = Limited options
├── High Vontade = Flexibility
└── Time pressure from regeneration

Corrupção ↔ Power Access
├── Low Corruption = Safe but weak
├── High Corruption = Powerful but deadly
└── Irreversible escalation
```

---

## **👹 ENEMY SYSTEM**

### **ENEMY PROGRESSION MODEL**
```
Enemy Level = Current Wave Number

HP Scaling:
├── Base HP: 50
├── Formula: BaseHP * (1 + Level * 0.2)
├── Level 1: 50 HP
├── Level 5: 100 HP
├── Level 10: 150 HP
└── Level 20: 250 HP (theoretical max)

Damage Scaling:
├── Base Damage: 8
├── Formula: BaseDmg * (1 + Level * 0.15)
├── Level 1: 8 damage
├── Level 5: 14 damage
├── Level 10: 20 damage
└── Level 20: 32 damage (theoretical max)
```

### **ENEMY BEHAVIOR**
- **AI Complexity**: None (pure stat scaling)
- **Attack Pattern**: Fixed damage every turn
- **Special Abilities**: None (MVP scope)
- **Visual Variety**: Name + level indicator only

### **DIFFICULTY CURVE**
```
Levels 1-3: TUTORIAL
├── Player learns mechanics
├── Forgiving mistakes
├── Build confidence
└── Success Rate: 95%+

Levels 4-7: CHALLENGE
├── Requires strategy
├── Punishes poor resource management
├── Introduces tension
└── Success Rate: 70%

Levels 8-12: MASTERY
├── Demands optimal play
├── High-stakes decisions
├── Psychological pressure
└── Success Rate: 40%

Levels 13+: SURVIVAL
├── Beyond intended balance
├── For completionist players
├── Bragging rights
└── Success Rate: 10%
```

---

## **🎨 USER INTERFACE DESIGN**

### **SCREEN LAYOUT HIERARCHY**
```
┌─────────────────────────────────────┐
│         ENEMY AREA (30%)            │
│  ┌─────────────────────────────┐    │
│  │  [Enemy Name #Level]        │    │
│  │  HP: ████████░░ 85/100      │    │
│  │  DMG: 12 per turn          │    │
│  └─────────────────────────────┘    │
├─────────────────────────────────────┤
│         PLAYER AREA (70%)           │
│  ┌───────────┬───────────────────┐  │
│  │ RESOURCES │     CARDS         │  │
│  │ HP: 78    │ ┌─────┬─────┬───┐ │  │
│  │ Vontade:  │ │Card │Card │ C │ │  │
│  │ ████░ 8/10│ │  1  │  2  │ 3 │ │  │
│  │ Corrupt:  │ │     │     │   │ │  │
│  │ ██░░ 35%  │ └─────┴─────┴───┘ │  │
│  └───────────┴───────────────────┘  │
└─────────────────────────────────────┘
```

### **VISUAL HIERARCHY PRINCIPLES**
1. **Enemy Status**: Largest, top-center (threat assessment)
2. **Player Resources**: High contrast, left side (status check)
3. **Card Actions**: Central focus, interactive (decision making)
4. **Secondary Info**: Minimal, non-distracting (noise reduction)

### **COLOR CODING SYSTEM**
```
HP (Health)
├── Green (80-100%): Safe
├── Yellow (40-79%): Caution
├── Orange (20-39%): Danger
└── Red (0-19%): Critical

Vontade (Willpower)
├── Blue: Available resource
├── Dark Blue: Consumed/unavailable
└── Pulsing: Regenerating

Corruption
├── Purple (0-33%): Manageable
├── Dark Purple (34-66%): Concerning
├── Red-Purple (67-99%): Dangerous
└── Black-Red (100%): Death
```

### **INTERACTIVE ELEMENTS**
```
Card Buttons
├── Idle: Subtle glow
├── Hover: Bright highlight + scale 1.05x
├── Disabled: Grayscale + reduced opacity
├── Pressed: Scale 0.95x + satisfaction effect
└── Cooldown: Progress bar overlay

Resource Bars
├── Animated changes (smooth interpolation)
├── Color transitions (health thresholds)
├── Shake effects (damage taken)
└── Pulse effects (regeneration)
```

---

## **🎵 AUDIO DESIGN**

### **AUDIO PHILOSOPHY**
**"Less is more" - Cada som deve ter propósito claro**

### **SOUND EFFECTS (MVP)**
```
Combat Actions
├── Card Select: Subtle "click" (50ms)
├── Card Play: "Whoosh" as flies (300ms)
├── Damage Hit: "Impact" + pitch based on damage (200ms)
├── Enemy Death: "Fade out" sound (800ms)
└── Resource Changes: Soft "ding" notifications (100ms)

UI Feedback
├── Hover: Minimal "chirp" (30ms)
├── Error: Low "buzz" for invalid actions (200ms)
├── Victory: Satisfying "chime" (400ms)
└── Game Over: Deep "thud" (600ms)
```

### **MUSIC (FUTURE)**
- **Adaptive soundtrack** based on corruption level
- **Low corruption**: Mysterious, ambient
- **High corruption**: Intense, discordant
- **Seamless loops** without jarring transitions

### **AUDIO IMPLEMENTATION**
- **2D Audio** only (no spatial)
- **Volume Control**: Master slider only
- **Audio Pool**: Reuse AudioStreamPlayer nodes
- **No Compression**: Raw audio files for quality

---

## **📱 TECHNICAL SPECIFICATIONS**

### **PLATFORM REQUIREMENTS**
```
Minimum Hardware
├── OS: Windows 10 64-bit
├── CPU: Intel i3-6100 or AMD equivalent
├── RAM: 4 GB
├── GPU: DirectX 11 compatible
├── Storage: 500 MB
└── Input: Mouse + Keyboard

Recommended Hardware
├── OS: Windows 11 64-bit
├── CPU: Intel i5-8400 or AMD equivalent
├── RAM: 8 GB
├── GPU: Dedicated graphics card
├── Storage: 1 GB SSD
└── Input: Gaming mouse (high precision)
```

### **PERFORMANCE TARGETS**
```
Framerate
├── Target: 60 FPS constant
├── Minimum: 30 FPS (degraded experience)
├── VSync: Enabled by default
└── Frame drops: < 5% during gameplay

Memory Usage
├── Target: < 300 MB RAM
├── Maximum: 500 MB RAM
├── VRAM: < 100 MB
└── Storage: < 500 MB total

Load Times
├── Game Start: < 3 seconds
├── Scene Transitions: < 1 second
├── Asset Loading: < 500ms
└── Save/Load: N/A (no save system)
```

### **ENGINE CONFIGURATION**
```
Godot 4.4+ Settings
├── Renderer: Forward+ (default)
├── MSAA: 2x (balance quality/performance)
├── Screen Space AA: FXAA (lightweight)
├── Shadows: Disabled (2D game)
├── Global Illumination: Disabled
└── VSync: Adaptive (prevent tearing)

Project Settings
├── Stretch Mode: 2D
├── Stretch Aspect: Keep (maintain ratio)
├── Target Resolution: 1920x1080
├── Window Mode: Windowed (resizable)
└── DPI Awareness: Enabled
```

---

## **🧪 GAMEPLAY BALANCING**

### **BALANCE PHILOSOPHY**
1. **Player agency** > Random chance
2. **Skill expression** through resource management
3. **Meaningful choices** with clear trade-offs
4. **Escalating tension** as corruption increases
5. **Fair but challenging** difficulty curve

### **MATHEMATICAL MODELS**

#### **Damage vs Corruption Balance**
```
Weak Cards (Safe)
├── Damage per Vontade: 8-12 points
├── Corruption per Damage: 0%
├── Sustainability: Infinite
└── Power Rating: 1.0x baseline

Strong Cards (Risky)
├── Damage per Vontade: 7-10 points
├── Corruption per Damage: 0.5-1.0%
├── Sustainability: 100-200 uses
└── Power Rating: 2.5x baseline

Balance Point:
Strong cards are 2.5x more efficient short-term
but unsustainable long-term due to corruption
```

#### **Enemy Scaling Model**
```
Survivability Calculation:
Player DPS = (Cards per turn * Average damage)
Enemy DPS = Fixed damage per turn
Time to kill = Enemy HP / Player DPS
Damage taken = Enemy DPS * Time to kill

Level 1 Example:
├── Enemy: 50 HP, 8 damage
├── Player DPS: ~15 (mixed card usage)
├── TTK: 3.3 turns
├── Damage taken: 26.4 HP
└── Net result: -26 HP per victory

Level 10 Example:
├── Enemy: 150 HP, 20 damage
├── Player DPS: ~15 (same cards)
├── TTK: 10 turns
├── Damage taken: 200 HP
└── Net result: Impossible without healing
```

### **DIFFICULTY TUNING PARAMETERS**
```
Easy Mode Adjustments (Future)
├── Enemy HP: -20%
├── Enemy Damage: -25%
├── Vontade Regen: +1 (total: 3)
├── Starting HP: +25 (total: 125)
└── Corruption Rate: -10%

Hard Mode Adjustments (Future)
├── Enemy HP: +30%
├── Enemy Damage: +20%
├── Vontade Regen: -1 (total: 1)
├── Starting Corruption: +15%
└── Healing Efficiency: -50%
```

---

## **🎮 PLAYER PROGRESSION**

### **SESSION-BASED PROGRESSION**
```
Within Single Session
├── Enemy levels increase
├── Player skill develops
├── Resource optimization improves
├── Confidence builds → Risk tolerance changes
└── Personal best scores

NO permanent upgrades or unlocks
NO meta-progression systems
NO character customization
Focus: Pure skill-based improvement
```

### **SKILL DEVELOPMENT CURVE**
```
Novice (Sessions 1-3)
├── Learns basic mechanics
├── Discovers card effects
├── Makes obvious mistakes
├── Reaches level 3-5 enemies
└── Fun comes from discovery

Intermediate (Sessions 4-10)
├── Understands resource management
├── Plans 2-3 turns ahead
├── Optimizes card usage
├── Reaches level 7-10 enemies
└── Fun comes from optimization

Advanced (Sessions 11+)
├── Masters risk/reward calculation
├── Adapts to emergent situations
├── Pushes personal boundaries
├── Reaches level 12+ enemies
└── Fun comes from mastery challenges
```

### **PSYCHOLOGICAL PROGRESSION**
```
Confidence Building
├── Early successes build momentum
├── Small improvements feel rewarding
├── "Just one more try" addictive loop
└── Personal achievement satisfaction

Risk Tolerance Evolution
├── Conservative → Confident → Aggressive
├── Learns corruption management
├── Develops personal play style
└── Finds optimal risk/reward balance
```

---

## **🎯 MONETIZATION STRATEGY**

### **MVP APPROACH**
```
Free/Premium Decision: TBD
├── Option A: Free game (portfolio piece)
├── Option B: $5-10 premium (indie price)
├── Option C: Pay-what-you-want
└── Option D: Steam Early Access

Current Scope: Free distribution
Focus: Portfolio and learning experience
No DLC, IAP, or expansion plans for MVP
```

### **FUTURE MONETIZATION (Post-MVP)**
```
Potential Strategies
├── Premium version: $10-15
├── Cosmetic DLC: Card art packs ($2-5)
├── Difficulty modes: Free updates
├── Platform porting: Mobile ($3), Console ($15)
└── Sequel/expansion: Full new game

Revenue Goals
├── MVP: $0 (portfolio piece)
├── Year 1: $1,000 (market validation)
├── Year 2: $5,000 (sustainable hobby)
└── Long-term: Unknown
```

---

## **📊 ANALYTICS & METRICS**

### **KEY PERFORMANCE INDICATORS**

#### **Engagement Metrics**
```
Session Length
├── Target: 15+ minutes average
├── Minimum: 5+ minutes (not immediate bounce)
├── Maximum: 60+ minutes (flow state)
└── Tracking: Manual observation

Player Actions
├── Cards played per session
├── Average enemy level reached
├── Time spent deciding per card
└── Restart frequency after game over
```

#### **User Experience Metrics**
```
Learning Curve
├── Time to first victory: < 2 minutes
├── Time to understand mechanics: < 5 minutes
├── Time to strategic play: < 15 minutes
└── Confusion points: Track via observation

Emotional Response
├── Stress indicators: Decision time increase
├── Satisfaction: Victory celebration duration
├── Frustration: Rage quit frequency
└── Engagement: Return session frequency
```

### **TESTING METHODOLOGY**
```
Internal Testing
├── Daily playtests during development
├── Performance profiling each build
├── Bug tracking in development notes
└── Balance iteration based on feel

External Testing
├── 5 people minimum for usability
├── 3 people for first-time user experience
├── 2 people for extended play sessions
└── Structured feedback collection forms

A/B Testing Opportunities
├── Card damage values (±10%)
├── Enemy scaling rate (±15%)
├── UI layout variations
└── Tutorial approach differences
```

---

## **🚀 RELEASE STRATEGY**

### **DEVELOPMENT PHASES**
```
Phase 1: MVP (3 weeks)
├── Core gameplay loop
├── Basic UI/UX
├── Minimum viable balance
└── Internal testing complete

Phase 2: Polish (2 weeks) - OPTIONAL
├── Visual/audio polish
├── Extended testing
├── Performance optimization
└── Bug fixes

Phase 3: Release (1 week) - OPTIONAL
├── Platform preparation
├── Marketing materials
├── Community setup
└── Launch execution
```

### **LAUNCH CRITERIA**
```
Technical Requirements
├── 0 critical bugs
├── 60+ FPS performance
├── < 500MB memory usage
├── < 3 second load times
└── Stable 30+ minute sessions

User Experience Requirements
├── 90%+ understand game in 60 seconds
├── 70%+ play for 10+ minutes first session
├── 50%+ want to play again immediately
├── 0 confusion about core mechanics
└── Positive feedback from all testers

Business Requirements
├── Scope completed as specified
├── Documentation complete
├── Code clean and commented
├── Assets properly licensed
└── Platform requirements met
```

---

## **📝 APPENDICES**

### **APPENDIX A: COMPETITIVE ANALYSIS**
```
Slay the Spire
├── Strengths: Deep strategy, excellent progression
├── Weaknesses: Complex for newcomers, long sessions
├── Lessons: Card synergy, risk/reward balance
└── Differentiation: Simpler mechanics, shorter sessions

Darkest Dungeon
├── Strengths: Psychological tension, atmospheric
├── Weaknesses: Punishing difficulty, time investment
├── Lessons: Stress as resource, meaningful choices
└── Differentiation: Faster pace, clearer feedback

Inscryption
├── Strengths: Innovative mechanics, narrative integration
├── Weaknesses: One-time experience, complex rules
├── Lessons: Tutorial integration, mystery building
└── Differentiation: Replayable, transparent systems
```

### **APPENDIX B: RISK ASSESSMENT**
```
Technical Risks
├── Performance on low-end hardware: Medium risk
├── Godot 4.4 stability issues: Low risk
├── Cross-platform compatibility: Low risk (Windows only)
└── Asset pipeline complexity: Low risk (minimal assets)

Design Risks
├── Balancing difficulty curve: High risk
├── Player confusion about mechanics: Medium risk
├── Lack of content variety: Medium risk
└── Addiction vs engagement balance: Low risk

Business Risks
├── Market saturation: Low risk (learning project)
├── Development time overrun: Medium risk
├── Scope creep: High risk (documented mitigation)
└── Technical skill limitations: Medium risk
```

### **APPENDIX C: FUTURE FEATURES**
```
Post-MVP Enhancements
├── Multiple enemy types
├── Additional card varieties
├── Environmental effects
├── Achievement system
├── Statistics tracking
├── Difficulty modes
├── Audio/music expansion
└── Platform ports

Major Features (Sequel Territory)
├── Deck building mechanics
├── Story/campaign mode
├── Multiplayer competitions
├── Card crafting system
├── Character progression
├── Multiple game modes
└── Mod support
```

---

**Document End - Total Length: ~4,500 words**
**Status: COMPLETE for MVP Development**
**Next Review: After Sprint 1 completion**