# 🔧 TECHNICAL SPECIFICATION - ECOS DO ABISMO
**Version 2.0 | Complete Implementation Guide**

---

## **📋 DOCUMENT OVERVIEW**

| Field | Value |
|-------|-------|
| **Document Type** | Technical Implementation Specification |
| **Scope** | Complete system architecture and implementation |
| **Audience** | Developers, Technical Reviewers |
| **Dependencies** | Game Design Document v2.0 |
| **Status** | Final - Ready for Implementation |

---

## **🏗️ SYSTEM ARCHITECTURE**

### **ARCHITECTURAL PATTERNS**

#### **MVC (Model-View-Controller) Implementation**
```
MODEL LAYER (Data & Logic)
├── Player.gd (Resource)
├── Enemy.gd (Resource)
├── Card.gd (Resource)
├── GameState.gd (Singleton)
└── GameData.gd (Configuration)

VIEW LAYER (UI & Presentation)
├── UIManager.gd (Main UI Controller)
├── PlayerUI.gd (Player stats display)
├── EnemyUI.gd (Enemy stats display)
├── CardUI.gd (Card interaction)
└── VFXManager.gd (Visual effects)

CONTROLLER LAYER (Game Logic)
├── GameController.gd (Main orchestrator)
├── BattleManager.gd (Combat logic)
├── InputManager.gd (Input handling)
└── AudioManager.gd (Sound management)
```

#### **Observer Pattern (Signal-Based)**
```gdscript
# Event Bus Architecture
extends Node  # GameEvents.gd (Autoload)

# Combat Events
signal card_played(card: Card, target: Enemy)
signal enemy_damaged(enemy: Enemy, damage: int)
signal enemy_died(enemy: Enemy)
signal player_damaged(damage: int)
signal player_died()

# Resource Events
signal hp_changed(new_hp: int, max_hp: int)
signal vontade_changed(new_vontade: int, max_vontade: int)
signal corruption_changed(new_corruption: float)

# UI Events
signal card_hovered(card: Card)
signal card_unhovered(card: Card)
signal ui_updated()

# Game State Events
signal game_started()
signal battle_started(enemy: Enemy)
signal turn_started(turn_number: int)
signal turn_ended(turn_number: int)
signal game_over(reason: String)
```

---

## **💾 DATA STRUCTURES**

### **CORE RESOURCE CLASSES**

#### **Player Resource**
```gdscript
class_name Player
extends Resource

# Core Stats
@export var max_hp: int = 100
@export var current_hp: int = 100
@export var max_vontade: int = 10
@export var current_vontade: int = 10
@export var corruption: float = 0.0

# Derived Properties
var hp_percentage: float:
    get: return float(current_hp) / max_hp

var vontade_percentage: float:
    get: return float(current_vontade) / max_vontade

var corruption_percentage: float:
    get: return corruption / 100.0

var is_alive: bool:
    get: return current_hp > 0 and corruption < 100.0

# Methods
func take_damage(amount: int) -> void:
    current_hp = max(0, current_hp - amount)
    GameEvents.hp_changed.emit(current_hp, max_hp)
    if current_hp <= 0:
        GameEvents.player_died.emit()

func spend_vontade(amount: int) -> bool:
    if current_vontade >= amount:
        current_vontade -= amount
        GameEvents.vontade_changed.emit(current_vontade, max_vontade)
        return true
    return false

func add_corruption(amount: float) -> void:
    corruption = min(100.0, corruption + amount)
    GameEvents.corruption_changed.emit(corruption)
    if corruption >= 100.0:
        GameEvents.player_died.emit()

func regenerate_vontade() -> void:
    current_vontade = min(max_vontade, current_vontade + 2)
    GameEvents.vontade_changed.emit(current_vontade, max_vontade)

func heal(amount: int) -> void:
    current_hp = min(max_hp, current_hp + amount)
    GameEvents.hp_changed.emit(current_hp, max_hp)
```

#### **Enemy Resource**
```gdscript
class_name Enemy
extends Resource

@export var enemy_name: String = "Unknown"
@export var level: int = 1
@export var max_hp: int = 50
@export var current_hp: int = 50
@export var damage: int = 8

var is_alive: bool:
    get: return current_hp > 0

var hp_percentage: float:
    get: return float(current_hp) / max_hp

static func create_scaled_enemy(level: int) -> Enemy:
    var enemy = Enemy.new()
    enemy.level = level
    enemy.enemy_name = "Guardião Sombrio #%d" % level
    enemy.max_hp = int(50 * (1.0 + (level - 1) * 0.2))
    enemy.current_hp = enemy.max_hp
    enemy.damage = int(8 * (1.0 + (level - 1) * 0.15))
    return enemy

func take_damage(amount: int) -> int:
    var old_hp = current_hp
    current_hp = max(0, current_hp - amount)
    var actual_damage = old_hp - current_hp

    GameEvents.enemy_damaged.emit(self, actual_damage)

    if current_hp <= 0:
        GameEvents.enemy_died.emit(self)

    return actual_damage

func get_attack_damage() -> int:
    return damage
```

#### **Card Resource**
```gdscript
class_name Card
extends Resource

enum CardType {
    WEAK_ATTACK,
    STRONG_ATTACK,
    SUPPORT
}

@export var card_name: String = "Unknown Card"
@export var card_type: CardType = CardType.WEAK_ATTACK
@export var damage: int = 0
@export var healing: int = 0
@export var vontade_cost: int = 1
@export var corruption_cost: float = 0.0
@export var description: String = ""

func can_play(player: Player) -> bool:
    return player.current_vontade >= vontade_cost

func play(player: Player, target: Enemy = null) -> bool:
    if not can_play(player):
        return false

    # Consume resources
    if not player.spend_vontade(vontade_cost):
        return false

    if corruption_cost > 0:
        player.add_corruption(corruption_cost)

    # Apply effects
    if damage > 0 and target:
        target.take_damage(damage)

    if healing > 0:
        player.heal(healing)

    GameEvents.card_played.emit(self, target)
    return true

static func create_weak_attack() -> Card:
    var card = Card.new()
    card.card_name = "Golpe Rápido"
    card.card_type = CardType.WEAK_ATTACK
    card.damage = 12
    card.vontade_cost = 1
    card.corruption_cost = 0.0
    card.description = "Ataque seguro e eficiente"
    return card

static func create_strong_attack() -> Card:
    var card = Card.new()
    card.card_name = "Lâmina Sombria"
    card.card_type = CardType.STRONG_ATTACK
    card.damage = 25
    card.vontade_cost = 3
    card.corruption_cost = 15.0
    card.description = "Poder sombrio com alto preço"
    return card

static func create_heal_card() -> Card:
    var card = Card.new()
    card.card_name = "Regeneração Vital"
    card.card_type = CardType.SUPPORT
    card.healing = 15
    card.vontade_cost = 2
    card.corruption_cost = 0.0
    card.description = "Restaura vitalidade perdida"
    return card
```

---

## **🎮 CORE GAME SYSTEMS**

### **GAME CONTROLLER (Main Orchestrator)**
```gdscript
class_name GameController
extends Node

enum GameState {
    MENU,
    PLAYING,
    GAME_OVER
}

# Components
@onready var battle_manager: BattleManager = $BattleManager
@onready var ui_manager: UIManager = $UIManager
@onready var vfx_manager: VFXManager = $VFXManager
@onready var audio_manager: AudioManager = $AudioManager

# State
var current_state: GameState = GameState.MENU
var player: Player
var current_enemy: Enemy
var available_cards: Array[Card] = []

func _ready():
    setup_game_systems()
    setup_event_connections()
    start_game()

func setup_game_systems():
    # Initialize player
    player = Player.new()

    # Create card pool
    available_cards = [
        Card.create_weak_attack(),
        Card.create_strong_attack(),
        Card.create_heal_card(),
        Card.create_weak_attack(),    # Duplicate for availability
        Card.create_strong_attack(),  # Duplicate for variety
        Card.create_heal_card()       # Duplicate for options
    ]

func setup_event_connections():
    # Connect to battle events
    GameEvents.enemy_died.connect(_on_enemy_died)
    GameEvents.player_died.connect(_on_player_died)
    GameEvents.card_played.connect(_on_card_played)

func start_game():
    current_state = GameState.PLAYING
    start_new_battle()
    GameEvents.game_started.emit()

func start_new_battle():
    var enemy_level = battle_manager.get_next_enemy_level()
    current_enemy = Enemy.create_scaled_enemy(enemy_level)
    battle_manager.start_battle(current_enemy)
    ui_manager.update_enemy_display(current_enemy)
    ui_manager.update_card_selection(get_random_cards(3))

func get_random_cards(count: int) -> Array[Card]:
    var selected_cards: Array[Card] = []
    for i in count:
        selected_cards.append(available_cards[i % available_cards.size()])
    return selected_cards

func _on_enemy_died(enemy: Enemy):
    vfx_manager.play_enemy_death_effect(enemy)
    await get_tree().create_timer(1.5).timeout
    start_new_battle()

func _on_player_died():
    current_state = GameState.GAME_OVER
    ui_manager.show_game_over_screen()

func _on_card_played(card: Card, target: Enemy):
    vfx_manager.play_card_effect(card, target)
    audio_manager.play_card_sound(card)
    ui_manager.update_all_displays()
```

### **BATTLE MANAGER (Combat Logic)**
```gdscript
class_name BattleManager
extends Node

var current_turn: int = 0
var current_enemy_level: int = 1
var turn_active: bool = false

func start_battle(enemy: Enemy):
    current_turn = 0
    turn_active = true
    GameEvents.battle_started.emit(enemy)
    start_turn()

func start_turn():
    current_turn += 1
    GameController.player.regenerate_vontade()
    GameEvents.turn_started.emit(current_turn)

func end_turn():
    if not turn_active:
        return

    # Enemy attacks
    var enemy_damage = GameController.current_enemy.get_attack_damage()
    GameController.player.take_damage(enemy_damage)

    GameEvents.turn_ended.emit(current_turn)

    # Check for game over
    if GameController.player.is_alive:
        await get_tree().create_timer(1.0).timeout
        start_turn()

func get_next_enemy_level() -> int:
    current_enemy_level += 1
    return current_enemy_level - 1

func process_card_play(card: Card):
    if not turn_active:
        return

    if card.play(GameController.player, GameController.current_enemy):
        end_turn()
```

### **UI MANAGER (Interface Controller)**
```gdscript
class_name UIManager
extends Control

# UI Components
@onready var player_ui: PlayerUI = $PlayerPanel
@onready var enemy_ui: EnemyUI = $EnemyPanel
@onready var cards_ui: CardsUI = $CardsPanel
@onready var game_over_ui: GameOverUI = $GameOverPanel

func _ready():
    setup_ui_connections()
    game_over_ui.visible = false

func setup_ui_connections():
    GameEvents.hp_changed.connect(_on_hp_changed)
    GameEvents.vontade_changed.connect(_on_vontade_changed)
    GameEvents.corruption_changed.connect(_on_corruption_changed)
    cards_ui.card_selected.connect(_on_card_selected)

func update_enemy_display(enemy: Enemy):
    enemy_ui.set_enemy(enemy)

func update_card_selection(cards: Array[Card]):
    cards_ui.set_cards(cards)

func update_all_displays():
    player_ui.refresh()
    enemy_ui.refresh()
    cards_ui.refresh()

func show_game_over_screen():
    game_over_ui.visible = true
    cards_ui.set_enabled(false)

func _on_hp_changed(new_hp: int, max_hp: int):
    player_ui.update_hp(new_hp, max_hp)

func _on_vontade_changed(new_vontade: int, max_vontade: int):
    player_ui.update_vontade(new_vontade, max_vontade)

func _on_corruption_changed(new_corruption: float):
    player_ui.update_corruption(new_corruption)

func _on_card_selected(card: Card):
    GameController.battle_manager.process_card_play(card)
```

---

## **🎨 UI IMPLEMENTATION**

### **PLAYER UI COMPONENT**
```gdscript
class_name PlayerUI
extends Control

@onready var hp_bar: ProgressBar = $VBoxContainer/HPBar
@onready var hp_label: Label = $VBoxContainer/HPBar/HPLabel
@onready var vontade_bar: ProgressBar = $VBoxContainer/VontadeBar
@onready var vontade_label: Label = $VBoxContainer/VontadeBar/VontadeLabel
@onready var corruption_bar: ProgressBar = $VBoxContainer/CorruptionBar
@onready var corruption_label: Label = $VBoxContainer/CorruptionBar/CorruptionLabel

func update_hp(current_hp: int, max_hp: int):
    hp_bar.max_value = max_hp
    hp_bar.value = current_hp
    hp_label.text = "%d/%d" % [current_hp, max_hp]

    # Color coding
    var hp_percent = float(current_hp) / max_hp
    if hp_percent > 0.6:
        hp_bar.modulate = Color.GREEN
    elif hp_percent > 0.3:
        hp_bar.modulate = Color.YELLOW
    else:
        hp_bar.modulate = Color.RED

func update_vontade(current_vontade: int, max_vontade: int):
    vontade_bar.max_value = max_vontade
    vontade_bar.value = current_vontade
    vontade_label.text = "%d/%d" % [current_vontade, max_vontade]
    vontade_bar.modulate = Color.CYAN

func update_corruption(corruption: float):
    corruption_bar.max_value = 100.0
    corruption_bar.value = corruption
    corruption_label.text = "%.1f%%" % corruption

    # Color coding for corruption
    if corruption < 33.0:
        corruption_bar.modulate = Color.PURPLE
    elif corruption < 66.0:
        corruption_bar.modulate = Color.ORANGE
    else:
        corruption_bar.modulate = Color.RED

func refresh():
    var player = GameController.player
    update_hp(player.current_hp, player.max_hp)
    update_vontade(player.current_vontade, player.max_vontade)
    update_corruption(player.corruption)
```

### **CARD UI COMPONENT**
```gdscript
class_name CardUI
extends Control

signal card_clicked(card: Card)

@onready var card_button: Button = $CardButton
@onready var name_label: Label = $CardButton/VBox/NameLabel
@onready var damage_label: Label = $CardButton/VBox/DamageLabel
@onready var cost_label: Label = $CardButton/VBox/CostLabel
@onready var corruption_label: Label = $CardButton/VBox/CorruptionLabel

var card_data: Card

func set_card(card: Card):
    card_data = card
    update_display()

func update_display():
    if not card_data:
        return

    name_label.text = card_data.card_name

    if card_data.damage > 0:
        damage_label.text = "DMG: %d" % card_data.damage
        damage_label.visible = true
    else:
        damage_label.visible = false

    if card_data.healing > 0:
        damage_label.text = "HEAL: %d" % card_data.healing
        damage_label.visible = true

    cost_label.text = "Cost: %d" % card_data.vontade_cost

    if card_data.corruption_cost > 0:
        corruption_label.text = "Corruption: +%.1f%%" % card_data.corruption_cost
        corruption_label.visible = true
    else:
        corruption_label.visible = false

    update_interactability()

func update_interactability():
    var can_play = card_data.can_play(GameController.player)
    card_button.disabled = not can_play
    modulate = Color.WHITE if can_play else Color.GRAY

func _on_card_button_pressed():
    if card_data and card_data.can_play(GameController.player):
        card_clicked.emit(card_data)

func _ready():
    card_button.pressed.connect(_on_card_button_pressed)

    # Hover effects
    card_button.mouse_entered.connect(_on_hover_enter)
    card_button.mouse_exited.connect(_on_hover_exit)

func _on_hover_enter():
    if not card_button.disabled:
        var tween = create_tween()
        tween.tween_property(self, "scale", Vector2(1.05, 1.05), 0.1)

func _on_hover_exit():
    var tween = create_tween()
    tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
```

---

## **🎭 VISUAL EFFECTS SYSTEM**

### **VFX MANAGER**
```gdscript
class_name VFXManager
extends Node2D

# Effect pools
var floating_number_pool: Array[FloatingNumber] = []
var particle_effect_pool: Array[ParticleEffect] = []

func _ready():
    initialize_pools()

func initialize_pools():
    # Create floating number pool
    for i in 10:
        var floating_number = preload("res://scenes/vfx/FloatingNumber.tscn").instantiate()
        floating_number_pool.append(floating_number)
        add_child(floating_number)
        floating_number.visible = false

    # Create particle effect pool
    for i in 5:
        var particle_effect = preload("res://scenes/vfx/ParticleEffect.tscn").instantiate()
        particle_effect_pool.append(particle_effect)
        add_child(particle_effect)

func play_damage_number(damage: int, position: Vector2):
    var floating_number = get_available_floating_number()
    if floating_number:
        floating_number.show_damage(damage, position)

func play_card_effect(card: Card, target: Enemy):
    # Card flight animation
    var card_position = get_card_world_position(card)
    var target_position = get_enemy_world_position(target)

    animate_card_flight(card_position, target_position)

func play_enemy_death_effect(enemy: Enemy):
    var enemy_position = get_enemy_world_position(enemy)
    var particle_effect = get_available_particle_effect()
    if particle_effect:
        particle_effect.play_death_effect(enemy_position)

func animate_card_flight(from: Vector2, to: Vector2):
    var card_sprite = Sprite2D.new()
    add_child(card_sprite)
    card_sprite.position = from

    var tween = create_tween()
    tween.parallel().tween_property(card_sprite, "position", to, 0.3)
    tween.parallel().tween_property(card_sprite, "scale", Vector2(0.8, 0.8), 0.3)
    tween.tween_callback(card_sprite.queue_free)

func get_available_floating_number() -> FloatingNumber:
    for number in floating_number_pool:
        if not number.is_active:
            return number
    return null

func get_available_particle_effect() -> ParticleEffect:
    for effect in particle_effect_pool:
        if not effect.is_playing:
            return effect
    return null

func get_card_world_position(card: Card) -> Vector2:
    # Convert UI position to world position
    return Vector2(960, 800)  # Placeholder

func get_enemy_world_position(enemy: Enemy) -> Vector2:
    # Convert enemy UI position to world position
    return Vector2(960, 300)  # Placeholder
```

### **FLOATING NUMBER COMPONENT**
```gdscript
class_name FloatingNumber
extends Control

@onready var label: Label = $Label
var is_active: bool = false

func show_damage(damage: int, world_position: Vector2):
    is_active = true
    visible = true
    position = world_position

    label.text = str(damage)
    label.modulate = Color.WHITE
    scale = Vector2(1.0, 1.0)

    # Animation
    var tween = create_tween()
    tween.parallel().tween_property(self, "position", position + Vector2(0, -50), 1.0)
    tween.parallel().tween_property(label, "modulate", Color.TRANSPARENT, 1.0)
    tween.parallel().tween_property(self, "scale", Vector2(1.2, 1.2), 0.3)
    tween.tween_callback(_on_animation_finished)

func _on_animation_finished():
    is_active = false
    visible = false
```

---

## **🔊 AUDIO SYSTEM**

### **AUDIO MANAGER**
```gdscript
class_name AudioManager
extends Node

# Audio players
@onready var sfx_player: AudioStreamPlayer = $SFXPlayer
@onready var ui_player: AudioStreamPlayer = $UIPlayer

# Audio resources (placeholder paths)
var card_play_sound: AudioStream = preload("res://audio/card_play.ogg")
var damage_sound: AudioStream = preload("res://audio/damage.ogg")
var enemy_death_sound: AudioStream = preload("res://audio/enemy_death.ogg")
var button_hover_sound: AudioStream = preload("res://audio/hover.ogg")

func play_card_sound(card: Card):
    match card.card_type:
        Card.CardType.WEAK_ATTACK:
            play_sfx(card_play_sound, 0.8)
        Card.CardType.STRONG_ATTACK:
            play_sfx(card_play_sound, 1.2)
        Card.CardType.SUPPORT:
            play_sfx(card_play_sound, 1.0)

func play_damage_sound(damage: int):
    var pitch = 0.8 + (damage / 50.0) * 0.4  # Scale pitch with damage
    play_sfx(damage_sound, clamp(pitch, 0.8, 1.2))

func play_enemy_death_sound():
    play_sfx(enemy_death_sound, 1.0)

func play_ui_sound(sound: AudioStream, pitch: float = 1.0):
    ui_player.stream = sound
    ui_player.pitch_scale = pitch
    ui_player.play()

func play_sfx(sound: AudioStream, pitch: float = 1.0):
    sfx_player.stream = sound
    sfx_player.pitch_scale = pitch
    sfx_player.play()
```

---

## **📊 PERFORMANCE OPTIMIZATION**

### **OBJECT POOLING STRATEGY**
```gdscript
# Generic Pool Manager
class_name ObjectPool
extends Node

var pool: Array = []
var pool_size: int
var scene_path: String

func _init(path: String, size: int):
    scene_path = path
    pool_size = size
    initialize_pool()

func initialize_pool():
    for i in pool_size:
        var instance = load(scene_path).instantiate()
        pool.append(instance)
        add_child(instance)
        instance.set_active(false)

func get_object():
    for obj in pool:
        if not obj.is_active():
            return obj

    # Pool exhausted, return first object anyway
    return pool[0]

func return_object(obj):
    obj.reset()
    obj.set_active(false)
```

### **MEMORY MANAGEMENT**
```gdscript
# Memory monitoring for development
class_name MemoryProfiler
extends Node

var frame_count: int = 0

func _ready():
    if OS.is_debug_build():
        set_process(true)

func _process(_delta):
    frame_count += 1
    if frame_count % 300 == 0:  # Every 5 seconds at 60 FPS
        print_memory_usage()

func print_memory_usage():
    var memory_mb = OS.get_static_memory_usage_by_type()
    print("Memory Usage: %d MB" % (memory_mb / 1024 / 1024))

    var fps = Engine.get_frames_per_second()
    if fps < 55:
        print("WARNING: FPS dropped to %d" % fps)
```

### **RENDERING OPTIMIZATION**
```gdscript
# project.godot settings for performance
[rendering]
renderer/rendering_method="forward_plus"
textures/canvas_textures/default_texture_filter=1
anti_aliasing/quality/msaa_2d=1
anti_aliasing/quality/screen_space_aa=1

[physics]
2d/run_on_separate_thread=true

[debug]
gdscript/warnings/untyped_declaration=1
gdscript/warnings/integer_division=1
```

---

## **🧪 TESTING FRAMEWORK**

### **UNIT TEST STRUCTURE**
```gdscript
# TestPlayer.gd - Unit test for Player class
class_name TestPlayer
extends "res://addons/gut/test.gd"

var player: Player

func before_each():
    player = Player.new()

func test_player_initialization():
    assert_eq(player.current_hp, 100)
    assert_eq(player.current_vontade, 10)
    assert_eq(player.corruption, 0.0)
    assert_true(player.is_alive)

func test_take_damage():
    player.take_damage(30)
    assert_eq(player.current_hp, 70)
    assert_true(player.is_alive)

func test_death_by_damage():
    player.take_damage(100)
    assert_eq(player.current_hp, 0)
    assert_false(player.is_alive)

func test_corruption_death():
    player.add_corruption(100.0)
    assert_eq(player.corruption, 100.0)
    assert_false(player.is_alive)

func test_vontade_spending():
    var success = player.spend_vontade(3)
    assert_true(success)
    assert_eq(player.current_vontade, 7)

func test_insufficient_vontade():
    var success = player.spend_vontade(15)
    assert_false(success)
    assert_eq(player.current_vontade, 10)
```

### **INTEGRATION TEST STRUCTURE**
```gdscript
# TestCombatFlow.gd - Integration test for combat
class_name TestCombatFlow
extends "res://addons/gut/test.gd"

var game_controller: GameController
var player: Player
var enemy: Enemy
var card: Card

func before_each():
    game_controller = GameController.new()
    add_child(game_controller)
    player = game_controller.player
    enemy = Enemy.create_scaled_enemy(1)
    card = Card.create_weak_attack()

func test_successful_card_play():
    var initial_enemy_hp = enemy.current_hp
    var success = card.play(player, enemy)

    assert_true(success)
    assert_eq(player.current_vontade, 9)  # Cost 1
    assert_lt(enemy.current_hp, initial_enemy_hp)

func test_card_play_without_vontade():
    player.current_vontade = 0
    var success = card.play(player, enemy)

    assert_false(success)
    assert_eq(enemy.current_hp, enemy.max_hp)

func test_enemy_death_progression():
    # Kill enemy with multiple attacks
    while enemy.is_alive:
        card.play(player, enemy)
        player.regenerate_vontade()

    assert_false(enemy.is_alive)
    assert_eq(enemy.current_hp, 0)
```

---

## **🚀 BUILD & DEPLOYMENT**

### **BUILD CONFIGURATION**
```gdscript
# Build script for automated builds
[Export]
name="Ecos do Abismo"
platform="Windows Desktop"
runnable=true
dedicated_server=false
custom_features=""
export_filter="all_resources"
include_filter=""
exclude_filter=""
export_path="builds/windows/EcosDoAbismo.exe"
encryption_include_filters=""
encryption_exclude_filters=""
encrypt_pck=false
encrypt_directory=false

[preset.0.options]
custom_template/debug=""
custom_template/release=""
debug/export_console_wrapper=1
binary_format/embed_pck=false
texture_format/bptc=true
texture_format/s3tc=true
texture_format/etc=false
texture_format/etc2=false
binary_format/architecture="x86_64"
codesign/enable=false
application/modify_resources=true
application/icon=""
application/console_wrapper_icon=""
application/icon_interpolation=4
application/file_version=""
application/product_version=""
application/company_name=""
application/product_name="Ecos do Abismo"
application/file_description=""
application/copyright=""
application/trademarks=""
ssh_remote_deploy/enabled=false
ssh_remote_deploy/host="user@host_ip"
ssh_remote_deploy/port="22"
ssh_remote_deploy/extra_args_ssh=""
ssh_remote_deploy/extra_args_scp=""
ssh_remote_deploy/run_script="Expand-Archive -LiteralPath '{temp_dir}\\{archive_name}' -DestinationPath '{temp_dir}'
$action = New-ScheduledTaskAction -Execute '{temp_dir}\\{exe_name}' -Argument '{cmd_args}'
$trigger = New-ScheduledTaskTrigger -Once -At 00:00
$settings = New-ScheduledTaskSettingsSet
$task = New-ScheduledTask -Action $action -Trigger $trigger -Settings $settings
Register-ScheduledTask godot_remote_debug -InputObject $task -Force:$true
Start-ScheduledTask -TaskName godot_remote_debug
while (Get-ScheduledTask -TaskName godot_remote_debug | ? State -eq running) { Start-Sleep 1 }
Unregister-ScheduledTask -TaskName godot_remote_debug -Confirm:$false -ErrorAction:SilentlyContinue"
ssh_remote_deploy/cleanup_script="Stop-ScheduledTask -TaskName godot_remote_debug -ErrorAction:SilentlyContinue
Unregister-ScheduledTask -TaskName godot_remote_debug -Confirm:$false -ErrorAction:SilentlyContinue
Remove-Item -Recurse -Force '{temp_dir}'"
```

### **AUTOMATED BUILD PIPELINE**
```batch
REM build.bat - Automated build script
@echo off
echo Building Ecos do Abismo...

REM Clean previous builds
if exist "builds\" rmdir /s /q "builds"
mkdir "builds\windows"

REM Export for Windows
"C:\Godot_v4.4.1-stable_win64.exe" --headless --export-release "Windows Desktop" "builds/windows/EcosDoAbismo.exe"

if %ERRORLEVEL% EQU 0 (
    echo Build successful!
    echo Executable: builds/windows/EcosDoAbismo.exe
) else (
    echo Build failed!
    exit /b 1
)

REM Optional: Create zip package
cd builds\windows
"C:\Program Files\7-Zip\7z.exe" a -tzip "EcosDoAbismo.zip" "EcosDoAbismo.exe"
cd ..\..

echo Build complete!
pause
```

---

**Document End - Complete Technical Implementation Guide**
**Status: Ready for Development**
**Next: Begin Sprint 1 Implementation**