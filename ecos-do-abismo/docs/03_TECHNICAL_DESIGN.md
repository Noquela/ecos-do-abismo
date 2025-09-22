# 🔧 TECHNICAL DESIGN DOCUMENT

## **ARCHITECTURE OVERVIEW**

### **DESIGN PRINCIPLES**
1. **KISS (Keep It Simple, Stupid)** - Código claro > código inteligente
2. **YAGNI (You Aren't Gonna Need It)** - Só implementa o que está no PRD
3. **Single Responsibility** - Cada classe faz UMA coisa bem
4. **Observer Pattern** - Comunicação via signals
5. **Composition > Inheritance** - Prefere componentes

---

## **SYSTEM ARCHITECTURE**

```
┌─────────────────────────────────────────┐
│                GAME                     │
│  ┌─────────────┐  ┌─────────────────┐  │
│  │     UI      │  │   GAME LOGIC    │  │
│  │ ┌─────────┐ │  │ ┌─────────────┐ │  │
│  │ │ Cards   │ │  │ │   Player    │ │  │
│  │ │ Health  │ │◄─┤ │   Enemy     │ │  │
│  │ │ Enemy   │ │  │ │   Battle    │ │  │
│  │ └─────────┘ │  │ └─────────────┘ │  │
│  └─────────────┘  └─────────────────┘  │
│                                         │
│  ┌─────────────┐  ┌─────────────────┐  │
│  │   SYSTEMS   │  │     DATA        │  │
│  │ ┌─────────┐ │  │ ┌─────────────┐ │  │
│  │ │ VFX     │ │  │ │   Cards     │ │  │
│  │ │ Audio   │ │◄─┤ │   Config    │ │  │
│  │ │ Input   │ │  │ │   State     │ │  │
│  │ └─────────┘ │  │ └─────────────┘ │  │
│  └─────────────┘  └─────────────────┘  │
└─────────────────────────────────────────┘
```

---

## **CORE MODULES**

### **1. GAME CONTROLLER** (`GameController.gd`)
**Responsabilidade**: Orchestrator principal
```gdscript
class_name GameController
extends Node

# ESTADOS DO JOGO
enum GameState {
    MENU,
    PLAYING,
    GAME_OVER
}

# COMPONENTES
@onready var battle_manager: BattleManager
@onready var ui_manager: UIManager
@onready var vfx_manager: VFXManager

func _ready():
    setup_connections()
    start_game()
```

### **2. BATTLE MANAGER** (`BattleManager.gd`)
**Responsabilidade**: Lógica de combate
```gdscript
class_name BattleManager
extends Node

# SIGNALS
signal battle_started
signal turn_ended
signal enemy_defeated
signal player_died

# STATE
var current_turn: int = 0
var enemy_level: int = 1

func start_battle()
func end_turn()
func apply_damage(target, amount)
```

### **3. PLAYER** (`Player.gd`)
**Responsabilidade**: Estado do jogador
```gdscript
class_name Player
extends Resource

# RESOURCES
@export var max_hp: int = 100
@export var current_hp: int = 100
@export var max_vontade: int = 10
@export var current_vontade: int = 10
@export var corruption: float = 0.0

# SIGNALS
signal hp_changed(new_value, max_value)
signal vontade_changed(new_value, max_value)
signal corruption_changed(new_value)
signal player_died
```

### **4. ENEMY** (`Enemy.gd`)
**Responsabilidade**: Comportamento do inimigo
```gdscript
class_name Enemy
extends Resource

@export var name: String
@export var max_hp: int
@export var current_hp: int
@export var damage: int
@export var level: int

signal enemy_died
signal hp_changed(new_value, max_value)

func take_damage(amount: int)
func attack() -> int
```

### **5. CARD** (`Card.gd`)
**Responsabilidade**: Dados e comportamento das cartas
```gdscript
class_name Card
extends Resource

enum CardType {
    WEAK_ATTACK,    # Baixo dano, baixo custo
    STRONG_ATTACK,  # Alto dano, alta corrupção
    SUPPORT         # Utilidade/cura
}

@export var name: String
@export var type: CardType
@export var damage: int
@export var vontade_cost: int
@export var corruption_cost: float
@export var description: String

func can_play(player: Player) -> bool
func play(player: Player, target: Enemy)
```

---

## **UI ARCHITECTURE**

### **UI MANAGER** (`UIManager.gd`)
```gdscript
class_name UIManager
extends Control

# COMPONENTS
@onready var player_ui: PlayerUI
@onready var enemy_ui: EnemyUI
@onready var cards_ui: CardsUI
@onready var game_over_ui: GameOverUI

func update_player_stats(player: Player)
func update_enemy_stats(enemy: Enemy)
func show_card_selection(cards: Array[Card])
```

### **CARD UI** (`CardUI.gd`)
```gdscript
class_name CardUI
extends Control

signal card_selected(card: Card)

@export var card_data: Card
@onready var name_label: Label
@onready var damage_label: Label
@onready var cost_label: Label

func setup_card(card: Card)
func _on_button_pressed()
```

---

## **DATA FLOW**

### **TURN SEQUENCE**
```
1. Turn Start
   ├── Player gains Vontade
   ├── Cards become available
   └── UI updates

2. Player Action
   ├── Selects card
   ├── Card validation
   ├── Effect execution
   ├── Resource deduction
   └── VFX trigger

3. Enemy Action
   ├── Enemy attacks
   ├── Player takes damage
   ├── Health check
   └── UI updates

4. Turn End
   ├── Check win/lose conditions
   ├── Enemy scaling (if defeated)
   └── Next turn OR game over
```

### **STATE MANAGEMENT**
```gdscript
# GLOBAL STATE (Autoload)
extends Node

var player: Player
var current_enemy: Enemy
var game_state: GameController.GameState
var current_turn: int

# CONFIGURATION
const CARD_TEMPLATES = [
    {
        "name": "Golpe Rápido",
        "type": Card.CardType.WEAK_ATTACK,
        "damage": 12,
        "vontade_cost": 1,
        "corruption_cost": 0.0
    },
    {
        "name": "Lâmina Sombria",
        "type": Card.CardType.STRONG_ATTACK,
        "damage": 25,
        "vontade_cost": 3,
        "corruption_cost": 15.0
    }
]
```

---

## **PERFORMANCE CONSIDERATIONS**

### **OPTIMIZATION TARGETS**
- **60 FPS** constante
- **< 100ms** input lag
- **< 500MB** RAM usage
- **< 2s** load time

### **PERFORMANCE STRATEGIES**

#### **Object Pooling**
```gdscript
# FloatingNumber pool para damage numbers
class_name FloatingNumberPool
extends Node

var pool: Array[FloatingNumber] = []
var pool_size: int = 20

func get_number() -> FloatingNumber
func return_number(number: FloatingNumber)
```

#### **Efficient UI Updates**
```gdscript
# Só atualiza UI quando valores mudam
func update_hp(new_hp: int):
    if new_hp != displayed_hp:
        displayed_hp = new_hp
        hp_bar.value = new_hp
        hp_label.text = str(new_hp)
```

#### **Minimal Scene Tree**
- Máximo 50 nodes na árvore
- UI usa Control nodes, não Sprite2D
- Inimigo como Resource, não Node

---

## **ERROR HANDLING**

### **DEFENSIVE PROGRAMMING**
```gdscript
func take_damage(amount: int):
    if amount < 0:
        push_warning("Damage amount negative: " + str(amount))
        return

    if current_hp <= 0:
        push_warning("Damage applied to dead entity")
        return

    current_hp = max(0, current_hp - amount)
    hp_changed.emit(current_hp, max_hp)
```

### **GRACEFUL DEGRADATION**
- VFX failure não quebra gameplay
- UI errors mostram placeholder
- Audio failure é silencioso
- Performance issues reduzem qualidade

---

## **TESTING STRATEGY**

### **UNIT TESTS** (Manual)
```gdscript
# Test cases para cada função crítica
func test_card_validation():
    var player = Player.new()
    player.current_vontade = 2

    var cheap_card = Card.new()
    cheap_card.vontade_cost = 1

    var expensive_card = Card.new()
    expensive_card.vontade_cost = 5

    assert(cheap_card.can_play(player) == true)
    assert(expensive_card.can_play(player) == false)
```

### **INTEGRATION TESTS**
- Jogar 10 turnos sem crash
- Matar 5 inimigos sequenciais
- Perder por HP e por Corrupção
- UI responde a todos os eventos

### **PERFORMANCE TESTS**
- Profiler durante 10 minutos
- Memory leaks check
- Frame time consistency
- Input lag measurement

---

## **FILE STRUCTURE**
```
scripts/
├── core/
│   ├── GameController.gd
│   ├── BattleManager.gd
│   └── GameState.gd (autoload)
├── entities/
│   ├── Player.gd
│   ├── Enemy.gd
│   └── Card.gd
├── ui/
│   ├── UIManager.gd
│   ├── PlayerUI.gd
│   ├── EnemyUI.gd
│   └── CardUI.gd
├── systems/
│   ├── VFXManager.gd
│   └── AudioManager.gd (future)
└── utils/
    ├── FloatingNumberPool.gd
    └── Helpers.gd

scenes/
├── Main.tscn (root)
├── UI/
│   ├── PlayerPanel.tscn
│   ├── EnemyPanel.tscn
│   └── CardButton.tscn
└── VFX/
    ├── DamageNumber.tscn
    └── HitEffect.tscn
```

---

## **DEVELOPMENT WORKFLOW**

### **FEATURE DEVELOPMENT**
1. **Red**: Escreve teste que falha
2. **Green**: Implementa mínimo para passar
3. **Refactor**: Limpa código
4. **Review**: Code review + teste manual
5. **Integrate**: Merge + teste de integração

### **GIT WORKFLOW**
```
main (stable)
├── develop (integration)
│   ├── feature/combat-system
│   ├── feature/card-ui
│   └── feature/enemy-scaling
└── hotfix/critical-bug (if needed)
```

### **COMMIT CONVENTIONS**
```
feat: add card selection UI
fix: enemy HP not updating correctly
refactor: simplify damage calculation
test: add player resource validation
docs: update architecture diagram
```