# ⚡ Sistema de Recursos e Gestão de Risco

## 🎮 EXPERIÊNCIA DO JOGADOR

### A Sensação Constante de Escassez
**"Nunca tenho o suficiente para fazer o que preciso"**

O jogador vive em **tensão permanente** com os recursos:
- **Vontade**: "Tenho só 3 pontos, essa carta custa 4... preciso esperar?"
- **Corrupção**: "Estou com 65%, mais 20% e é game over..."
- **HP**: "Só 12 de vida restando, se eu errar agora..."

### Momentos Psicológicos com Recursos

#### VER OS RECURSOS (sempre visível)
**Sentimento:** Ansiedade constante
- **VONTADE:** Bar azul que nunca está cheio o suficiente
- **CORRUPÇÃO:** Bar vermelho crescendo como uma ameaça
- **HP:** Números que diminuem mais rápido do que sobem
- **SENTE:** "Estou sempre no limite, sempre arriscando"

#### GASTAR VONTADE
**Sentimento:** Alívio temporário + preocupação futura
- **VÊ:** Bar diminui, carta se move
- **CALCULA:** "Vou ter o suficiente no próximo turno?"
- **PLANEJA:** "Preciso guardar para uma emergência?"

#### GANHAR CORRUPÇÃO
**Sentimento:** Prazer culposo + medo crescente
- **VÊ:** Bar vermelho sobe, tela tremula
- **SENTE:** "Valeu a pena... mas até quando posso continuar?"
- **TEME:** "Estou perdendo controle, chegando no limite"

#### REGENERAR VONTADE
**Sentimento:** Esperança + impaciência
- **VÊ:** Bar azul cresce lentamente (+2 por turno)
- **PLANEJA:** "Com 5 pontos posso jogar aquela carta..."
- **FRUSTRA:** "Demora demais, inimigo não vai esperar"

### A Dança dos Três Recursos

#### VONTADE: O Motor da Ação
- **Sensação:** "Combustível preciosos"
- **Regenera:** +2 por turno (lento, frustrante)
- **Máximo:** 10 pontos (nunca suficiente)
- **Gasto:** 1-6 por carta (sempre doloroso)

#### CORRUPÇÃO: A Espada de Damocles
- **Sensação:** "Tempo correndo contra mim"
- **Acumula:** Eco Forte adiciona 5-25 pontos
- **Decai:** NUNCA diminui naturalmente
- **Limite:** 100% = Game Over inevitável

#### HP: A Linha Final
- **Sensação:** "Última chance"
- **Diminui:** Ataques inimigos (3-8 por hit)
- **Cura:** Cartas raras de cura (custam Vontade)
- **Máximo:** 100 pontos (parece muito, acaba rápido)

## 🔗 INTEGRAÇÃO COM OUTRAS FEATURES

### Recursos ↔ Card Selection
- **cartas.md:** Cada carta tem 2 custos (só Vontade vs Vontade+Corrupção)
- **Eco Fraco:** Sempre custa só Vontade (2-4 pontos)
- **Eco Forte:** Vontade + Corrupção (mais poder, mais risco)
- **interface.md:** Custos destacados em vermelho quando insuficientes

### Recursos ↔ Enemy Adaptation
- **inimigos.md:** Inimigos reagem ao nível de Corrupção
- **0-25%:** Inimigos agressivos (jogador "fraco")
- **50-75%:** Inimigos cautelosos (jogador "perigoso")
- **80-100%:** Inimigos esperam (jogador vai se destruir)

### Recursos ↔ Visual Feedback
- **interface.md:** Corrupção distorce a tela progressivamente
- **0-25%:** Interface limpa e controlada
- **50-75%:** Tremores, cores desbotadas
- **80-100%:** Fragmentação, duplicação, caos visual

### Recursos ↔ Turn Management
- **mecanica.md:** Turnos forçam decisões sob pressão
- **Início turno:** +2 Vontade (nunca suficiente)
- **Durante turno:** Gasta Vontade, acumula Corrupção
- **Fim turno:** Inimigo ataca (força gasto defensivo)

## ⚙️ ARQUITETURA QUE SUPORTA A EXPERIÊNCIA

### PlayerResources.gd (Core do Sistema)

#### A Classe que Controla o Destino
```gdscript
class_name PlayerResources
extends Resource

# VONTADE: Motor da ação (escasso, precioso)
@export var max_vontade: int = 10
@export var current_vontade: int = 10
@export var vontade_regen_per_turn: int = 2

# CORRUPÇÃO: A ameaça crescente (irreversível, fatal)
@export var corrupcao: float = 0.0
@export var max_corrupcao: float = 100.0

# HP: A linha final (vulnerável, recuperável)
@export var hp: int = 100
@export var max_hp: int = 100

# SIGNALS: Outros sistemas reagem imediatamente
signal vontade_changed(new_value: int, max_value: int)
signal corrupcao_changed(new_value: float, percentage: float)
signal hp_changed(new_value: int, max_value: int)
signal resource_critical(resource_type: String)
signal game_over_triggered(reason: String)
```

#### Sistema de Vontade: Escassez Controlada
```gdscript
func spend_vontade(amount: int) -> bool:
    if current_vontade >= amount:
        current_vontade -= amount
        vontade_changed.emit(current_vontade, max_vontade)

        # CRÍTICO: Feedback visual instantâneo
        if current_vontade <= 2:
            resource_critical.emit("vontade")

        return true
    else:
        # FRUSTRAÇÃO: Não ter recursos é parte da experiência
        EffectManager.play_insufficient_resources_effect()
        return false

func regenerate_vontade():
    current_vontade = min(max_vontade, current_vontade + vontade_regen_per_turn)
    vontade_changed.emit(current_vontade, max_vontade)

    # Som de alívio quando regenera
    AudioManager.play_sfx("vontade_regenerated")
```

#### Sistema de Corrupção: Tensão Crescente
```gdscript
func add_corrupcao(amount: float):
    var old_percentage = corrupcao / max_corrupcao
    corrupcao = min(max_corrupcao, corrupcao + amount)
    var new_percentage = corrupcao / max_corrupcao

    corrupcao_changed.emit(corrupcao, new_percentage)

    # MARCOS PSICOLÓGICOS: Cada 25% é um novo nível de tensão
    var old_tier = int(old_percentage * 4)
    var new_tier = int(new_percentage * 4)

    if new_tier > old_tier:
        corruption_tier_changed.emit(new_tier)
        CorruptionVisualManager.escalate_distortion(new_tier)

    # CRÍTICO: Warnings em marcos perigosos
    match new_percentage:
        var x when x >= 0.75:
            resource_critical.emit("corrupcao_critical")
        var x when x >= 0.5:
            resource_critical.emit("corrupcao_warning")

    # GAME OVER: O momento mais temido
    if corrupcao >= max_corrupcao:
        game_over_triggered.emit("corruption_limit")
```

#### Sistema de HP: Vulnerabilidade Física
```gdscript
func take_damage(amount: int):
    hp = max(0, hp - amount)
    hp_changed.emit(hp, max_hp)

    # Feedback dramático proporcional ao dano
    var damage_percentage = float(amount) / max_hp
    EffectManager.screen_shake(damage_percentage * 1.5, 0.4)

    # MARCOS DE PERIGO
    var hp_percentage = float(hp) / max_hp
    match hp_percentage:
        var x when x <= 0.2:
            resource_critical.emit("hp_critical")
        var x when x <= 0.4:
            resource_critical.emit("hp_warning")

    if hp <= 0:
        game_over_triggered.emit("hp_zero")

func heal(amount: int):
    hp = min(max_hp, hp + amount)
    hp_changed.emit(hp, max_hp)

    # Cura é rara e preciosa
    EffectManager.healing_glow()
    AudioManager.play_sfx("healing")
```

### ResourceDisplayManager.gd

#### Interface que Comunica Urgência
```gdscript
extends Control

@onready var vontade_bar = $TopUI/ResourcePanel/VontadeBar
@onready var corrupcao_bar = $TopUI/ResourcePanel/CorrupcaoBar
@onready var hp_label = $TopUI/ResourcePanel/HPLabel

func _ready():
    # CONEXÕES CRÍTICAS: Feedback instantâneo
    GameManager.player_resources.vontade_changed.connect(_on_vontade_changed)
    GameManager.player_resources.corrupcao_changed.connect(_on_corrupcao_changed)
    GameManager.player_resources.hp_changed.connect(_on_hp_changed)
    GameManager.player_resources.resource_critical.connect(_on_resource_critical)

func _on_vontade_changed(current: int, maximum: int):
    # Bar azul que representa esperança
    vontade_bar.value = current
    vontade_bar.max_value = maximum

    # Cor muda baseada na urgência
    var percentage = float(current) / maximum
    match percentage:
        var x when x < 0.3:
            vontade_bar.modulate = Color.RED      # CRÍTICO
        var x when x < 0.5:
            vontade_bar.modulate = Color.YELLOW   # WARNING
        _:
            vontade_bar.modulate = Color.CYAN     # SEGURO

func _on_corrupcao_changed(current: float, percentage: float):
    # Bar vermelho que inspira medo
    corrupcao_bar.value = current

    # Efeito visual fica mais intenso conforme sobe
    var intensity = percentage
    corrupcao_bar.modulate = Color(1.0, 1.0 - intensity * 0.5, 1.0 - intensity * 0.5)

    # Tremulação da barra aumenta com corrupção
    var shake_offset = Vector2(
        randf_range(-intensity * 3, intensity * 3),
        randf_range(-intensity * 3, intensity * 3)
    )
    corrupcao_bar.position += shake_offset

func _on_resource_critical(resource_type: String):
    # ALERTAS VISUAIS: Jogador precisa SENTIR o perigo
    match resource_type:
        "vontade":
            flash_resource_bar(vontade_bar, Color.BLUE, 0.3)
        "corrupcao_warning":
            flash_resource_bar(corrupcao_bar, Color.ORANGE, 0.5)
        "corrupcao_critical":
            flash_resource_bar(corrupcao_bar, Color.RED, 1.0)
        "hp_warning":
            flash_resource_bar(hp_label, Color.YELLOW, 0.4)
        "hp_critical":
            flash_resource_bar(hp_label, Color.RED, 0.8)

func flash_resource_bar(target: Control, color: Color, intensity: float):
    # Flash dramático que chama atenção
    var tween = create_tween()
    tween.tween_property(target, "modulate", color, 0.1)
    tween.tween_property(target, "modulate", Color.WHITE, 0.3)

    # Screen shake proporcional à urgência
    EffectManager.screen_shake(intensity, 0.2)
```

### Sistema de Balanceamento Psicológico

#### ResourceBalancer.gd
```gdscript
extends Node

# CONFIGURAÇÕES: Ajustadas para máxima tensão
const VONTADE_REGEN = 2          # Lento o suficiente para frustrarte
const VONTADE_MAX = 10           # Baixo o suficiente para forçar escolhas
const CORRUPCAO_ECO_FORTE = 15   # Alto o suficiente para dar medo
const HP_ENEMY_DAMAGE = 6        # Suficiente para pressionar

# CURVAS DE DIFICULDADE: Tensão crescente
func get_enemy_damage_by_corruption(corruption_percentage: float) -> int:
    # Inimigos ficam mais agressivos quando você está corrupto
    var base_damage = HP_ENEMY_DAMAGE
    var corruption_multiplier = 1.0 + (corruption_percentage * 0.5)
    return int(base_damage * corruption_multiplier)

func get_card_spawn_rarity(corruption_percentage: float) -> String:
    # Cartas mais poderosas (e perigosas) aparecem com mais corrupção
    match corruption_percentage:
        var x when x < 0.25:
            return "comum"          # Cartas seguras
        var x when x < 0.5:
            return "raro"           # Risco moderado
        var x when x < 0.75:
            return "epico"          # Alto risco/recompensa
        _:
            return "lendario"       # Game changers extremos
```

### Feedback Audiovisual dos Recursos

#### ResourceEffects.gd
```gdscript
extends Node

func play_vontade_spend_effect(amount: int):
    # Som proporcional ao gasto
    var pitch = 1.0 - (amount / 10.0) * 0.3  # Gastos maiores = som mais grave
    AudioManager.play_sfx("vontade_spend", pitch)

func play_corrupcao_gain_effect(amount: float):
    # Efeito visual dramático
    CorruptionVisualManager.corruption_pulse(amount / 25.0)

    # Som sinistro proporcional
    var pitch = 1.0 + (amount / 25.0) * 0.5
    AudioManager.play_sfx("corruption_gain", pitch)

    # Vibração do controller se disponível
    if Input.get_connected_joypads().size() > 0:
        var intensity = amount / 25.0
        Input.start_joy_vibration(0, intensity, intensity, 0.3)
```

### Condições de Game Over

#### GameOverConditions.gd
```gdscript
extends Node

func check_all_game_over_conditions():
    var resources = GameManager.player_resources

    # CORRUPÇÃO: A morte lenta e inevitável
    if resources.corrupcao >= resources.max_corrupcao:
        trigger_corruption_game_over()

    # HP: A morte súbita e violenta
    elif resources.hp <= 0:
        trigger_hp_game_over()

func trigger_corruption_game_over():
    # GAME OVER mais dramático - a loucura venceu
    CorruptionVisualManager.final_corruption_effect()
    AudioManager.play_corruption_game_over_music()

    await get_tree().create_timer(2.0).timeout
    GameOverManager.show_corruption_defeat_screen()

func trigger_hp_game_over():
    # GAME OVER mais direto - morte física
    EffectManager.death_screen_effect()
    AudioManager.play_death_music()

    await get_tree().create_timer(1.0).timeout
    GameOverManager.show_hp_defeat_screen()
```