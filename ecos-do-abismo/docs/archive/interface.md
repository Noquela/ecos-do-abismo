# 🖥️ Interface e Design Visual

## 🎮 EXPERIÊNCIA VISUAL DO JOGADOR

### A Interface Como Narrativa
**"A tela é um espelho da sua sanidade"**

A interface não apenas mostra informações - ela **CONTA A HISTÓRIA** da corrupção mental:
- **0% Corrupção:** Interface limpa, cores nítidas, tudo controlado
- **50% Corrupção:** Bordas tremem, cores desbotam, elementos oscilam
- **80% Corrupção:** Tela fragmenta, elementos duplicam, realidade distorce
- **100% Corrupção:** Caos visual total, game over inevitável

### Momentos Visuais Críticos

#### FEEDBACK INSTANTÂNEO (0-200ms)
**Objetivo:** Jogador SENTE o impacto imediatamente
- **Hover carta:** Destaque + preview de efeitos em <100ms
- **Click carta:** Highlight + animação de saída instantânea
- **Dano causado:** Número grande + screen shake + flash

#### PROGRESSÃO VISUAL (200ms-2s)
**Objetivo:** Mostrar consequências claramente
- **Barra HP inimigo:** Diminui suavemente com easing
- **Barra Corrupção:** Sobe com tremor crescente
- **Carta usada:** Voa para alvo com trail visual

#### TRANSFORMAÇÃO GRADUAL (2s-permanente)
**Objetivo:** Mundo reage às suas escolhas
- **Background:** Gradualmente mais distorcido
- **UI Elements:** Começam a "sangrar" e fragmentar
- **Cards:** Aparência muda baseada na Corrupção

### Hierarquia Visual de Importância
1. **CRÍTICO:** Barras de HP (inimigo/jogador) - sempre visíveis
2. **URGENTE:** Barra de Corrupção - fica mais destacada conforme sobe
3. **TÁTICO:** Custos das cartas - destacados quando relevantes
4. **CONTEXTUAL:** Efeitos visuais - intensificam com drama

## 🔗 INTEGRAÇÃO COM OUTRAS FEATURES

### Interface ↔ Corruption System
- **recursos.md:** Define níveis de Corrupção (0-100%)
- **Interface:** Traduz números em distorção visual progressiva
- **mecanica.md:** Fornece eventos que disparam mudanças visuais

### Interface ↔ Card Interaction
- **cartas.md:** Define que cartas têm 2 ecos com custos diferentes
- **Interface:** Mostra ambos custos, destaca o viável, preview efeitos
- **mecanica.md:** Timing de feedback (<200ms para responsividade)

### Interface ↔ Enemy Adaptation
- **inimigos.md:** Inimigos mudam comportamento baseado no jogador
- **Interface:** Mostra visualmente que inimigo está "aprendendo"
- **Indicadores:** Olhos brilhando, postura mudando, aura diferente

### Interface ↔ Audio/Visual Effects
- **arte.md:** Define paleta de cores e estilo visual
- **Interface:** Aplica distorções que combinam com arte IA
- **Progressão:** Tela fica mais "pintada à mão" conforme Corrupção sobe

## ⚙️ ARQUITETURA QUE SUPORTA A EXPERIÊNCIA

### Sistema de Feedback Visual Responsivo

#### CorruptionVisualManager.gd
**Objetivo:** Distorção visual progressiva baseada em Corrupção
```gdscript
extends Node

func update_corruption_visual(corruption_percent: float):
	var intensity = corruption_percent / 100.0

	# Distorção do shader da tela inteira
	var shader_material = get_viewport().get_screen_material()
	shader_material.set_shader_parameter("distortion", intensity * 0.1)
	shader_material.set_shader_parameter("color_shift", intensity * 0.3)

	# Elementos de UI tremendo
	for ui_element in get_tree().get_nodes_in_group("corruption_affected"):
		ui_element.position += Vector2(
			randf_range(-intensity * 5, intensity * 5),
			randf_range(-intensity * 5, intensity * 5)
		)
```

#### InstantFeedbackSystem.gd
**Objetivo:** Feedback <200ms para todas as ações críticas
```gdscript
extends Node

func show_damage_feedback(amount: int, position: Vector2):
	var damage_label = preload("res://ui/DamageNumber.tscn").instantiate()
	damage_label.text = str(amount)
	damage_label.position = position

	# CRÍTICO: Aparecer em <50ms
	get_tree().current_scene.add_child(damage_label)

	# Animação dramática mas rápida
	var tween = create_tween()
	tween.tween_property(damage_label, "position", position + Vector2(0, -100), 1.0)
	tween.tween_property(damage_label, "modulate", Color.TRANSPARENT, 0.5)
	tween.tween_callback(damage_label.queue_free)
```

### Layout para Ultrawide (3440x1440)

#### MainMenu.tscn
```
Control (root) - anchors_preset: 15
└── CenterContainer - anchors_preset: 15
    └── VBoxContainer - alignment: 1
        ├── TitleLabel - horizontal_alignment: 1
        ├── StartButton
        ├── OptionsButton
        └── QuitButton
```

### BattleScene.tscn
```
Control (root) - anchors_preset: 15
├── BackgroundLayer (TextureRect)
├── TopUI (HBoxContainer) - anchors_preset: 1
│   ├── ResourcePanel (Panel)
│   │   ├── VontadeLabel
│   │   ├── HPLabel
│   │   └── CorrupcaoBar (ProgressBar)
│   └── TurnCounter (Label)
├── CenterField (Control) - anchors_preset: 8
│   ├── EnemyArea (Control)
│   │   ├── EnemySprite (TextureRect)
│   │   └── EnemyHealthBar (ProgressBar)
│   └── BattleEffects (Node2D)
└── BottomUI (VBoxContainer) - anchors_preset: 3
    ├── HandContainer (HBoxContainer)
    └── ActionButtons (HBoxContainer)
        ├── EndTurnButton
        └── MenuButton
```

## Sistema de Cartas UI

### CardDisplay.tscn (Prefab)
```
Control (CardBase) - custom_minimum_size: Vector2(180, 280)
├── Background (NinePatchRect) - texture: card_bg.png
├── ContentContainer (VBoxContainer)
│   ├── NameLabel - size_flags_horizontal: 3
│   ├── ArtContainer (TextureRect) - size: 160x120
│   ├── DescriptionLabel - autowrap_mode: 3
│   └── CostContainer (HBoxContainer)
│       ├── EcoFracoPanel (Panel)
│       │   ├── CostLabel
│       │   └── EffectLabel
│       └── EcoFortePanel (Panel)
│           ├── CostLabel
│           ├── CorrupcaoLabel
│           └── EffectLabel
└── HoverEffects (Control)
    ├── GlowEffect (NinePatchRect) - modulate: Color(1,1,1,0)
    └── SelectionBorder (NinePatchRect) - visible: false
```

### Estados da Carta
- **Normal**: modulate Color(1,1,1,1), escala 1.0
- **Hover**: modulate Color(1.1,1.1,1.1,1), escala 1.05
- **Selecionada**: SelectionBorder visible, GlowEffect alpha 0.8
- **Não jogável**: modulate Color(0.5,0.5,0.5,1)

## Scripts de Interface

### MainMenu.gd
```gdscript
extends Control

@onready var start_button = $CenterContainer/VBoxContainer/StartButton
@onready var options_button = $CenterContainer/VBoxContainer/OptionsButton

func _ready():
    start_button.pressed.connect(_on_start_pressed)
    options_button.pressed.connect(_on_options_pressed)

func _on_start_pressed():
    get_tree().change_scene_to_file("res://scenes/battle/BattleScene.tscn")
```

### BattleUI.gd
```gdscript
extends Control

@onready var vontade_label = $TopUI/ResourcePanel/VontadeLabel
@onready var hp_label = $TopUI/ResourcePanel/HPLabel
@onready var corrupcao_bar = $TopUI/ResourcePanel/CorrupcaoBar

func update_resources(vontade: int, hp: int, corrupcao: float):
    vontade_label.text = "Vontade: " + str(vontade)
    hp_label.text = "HP: " + str(hp)
    corrupcao_bar.value = corrupcao
    _update_corruption_visual(corrupcao)
```

## Sistema de Feedback Visual

### Corrupção Progressiva
```gdscript
func _update_corruption_visual(corruption_percent: float):
    var root_control = get_viewport().get_child(0)
    match corruption_percent:
        var x when x < 25:
            root_control.modulate = Color.WHITE
        var x when x < 50:
            root_control.modulate = Color(0.95, 0.95, 1.0)
            _add_subtle_distortion()
        var x when x < 75:
            root_control.modulate = Color(0.9, 0.85, 0.9)
            _add_glitch_effects()
        var x when x < 100:
            root_control.modulate = Color(0.8, 0.7, 0.8)
            _add_heavy_distortion()
```

### Animações de Feedback
- **Dano recebido**: shake_camera(intensity: 0.5, duration: 0.3)
- **Carta jogada**: card.position = tween_to(center) + scale(1.2) + fade_out()
- **Eco Forte usado**: screen_flash(Color.RED, 0.1) + corruption_pulse()

## Responsividade Ultrawide

### Configuração para 3440x1440
```gdscript
# project.godot
[display]
window/size/viewport_width=3440
window/size/viewport_height=1440
window/stretch/mode="canvas_items"
window/stretch/aspect="expand"
```

### Layout Adaptativo
- **Campo de batalha**: Mantém proporção 16:9 centralizado
- **UI lateral**: Aproveita espaço extra para informações expandidas
- **Cartas**: Tamanho fixo, espaçamento flexível na mão