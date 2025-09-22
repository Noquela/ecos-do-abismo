# ⚙️ Mecânica Central

## 🎮 EXPERIÊNCIA DO JOGADOR

### O Dilema Central
**"Posso usar poder suficiente para vencer sem enlouquecer?"**

O jogador está constantemente em **tensão psicológica**:
- Vê um inimigo ameaçador
- Tem cartas que podem destruí-lo... mas há um preço
- Cada uso de poder corrompe sua mente
- A morte pode vir do inimigo... ou da própria loucura

### Momentos-Chave da Experiência

#### 1. MOMENTO DA ESCOLHA (5-10 segundos)
**Sentimento:** Ansiedade, calculismo
- **VÊ:** Inimigo com HP visível, suas cartas destacadas
- **SENTE:** "Posso arriscar? Quanto de Corrupção aguento?"
- **FAZ:** Hover nas cartas, vê custos, toma decisão

#### 2. MOMENTO DA EXECUÇÃO (1-2 segundos)
**Sentimento:** Alívio ou arrependimento
- **VÊ:** Carta voa para o centro, efeito dramático
- **SENTE:** "Consegui! / Droga, usei poder demais..."
- **VIVE:** Números voando, screen shake, audio impactante

#### 3. MOMENTO DA CONSEQUÊNCIA (2-3 segundos)
**Sentimento:** Tensão crescente
- **VÊ:** HP inimigo diminui, barra de Corrupção sobe
- **SENTE:** "Valeu a pena? Estou chegando no limite?"
- **PLANEJA:** "Próxima carta, preciso ser mais cauteloso"

#### 4. RESPOSTA DO MUNDO (3-5 segundos)
**Sentimento:** Pressão, adaptação
- **VÊ:** Inimigo reage, ataca diferente, mundo distorce
- **SENTE:** "Ele notou minha estratégia, preciso mudar"
- **APRENDE:** Padrões, consequências, limites

## 🔗 INTEGRAÇÃO COM OUTRAS FEATURES

### Como as Features se Conectam na Experiência

#### Cards ↔ Combat ↔ Corruption
**Fluxo:** Jogador escolhe carta → Sistema calcula efeitos → Interface mostra feedback
- **cartas.md:** Define que cada carta tem 2 ecos e custos diferentes
- **recursos.md:** Gerencia Vontade (gasta) e Corrupção (acumula)
- **interface.md:** Mostra custos antes, efeitos durante, consequências depois

#### Enemy ↔ Adaptation ↔ Difficulty
**Fluxo:** Jogador joga → Inimigo observa → Comportamento muda → Dificuldade escala
- **inimigos.md:** Define como inimigos reagem aos padrões do jogador
- **mecanica.md:** Fornece dados de uso de Eco Fraco vs Forte
- **interface.md:** Mostra visualmente que inimigo está "aprendendo"

#### Visual ↔ Audio ↔ Corruption
**Fluxo:** Corrupção sobe → Interface distorce → Audio muda → Tensão aumenta
- **recursos.md:** Define níveis de Corrupção (0-25%, 26-50%, etc.)
- **interface.md:** Especifica distorções visuais por nível
- **arte.md:** Define como gerar arte que reflete Corrupção

### Dependências Críticas
1. **Cards PRECISAM de Enemy** - sem alvo, não há decisão
2. **Enemy PRECISA de Adaptation** - sem reação, não há tensão
3. **Corruption PRECISA de Visual Feedback** - sem ver, não há medo
4. **Interface PRECISA responder em <200ms** - lentidão quebra imersão

## ⚙️ ARQUITETURA QUE SUPORTA A EXPERIÊNCIA

### Core Systems que Entregam a Experiência

#### 1. MOMENTO DA ESCOLHA → CardInteractionSystem
**Objetivo:** Jogador precisa SENTIR o peso de cada decisão
```gdscript
# Em CardDisplay.gd - resposta imediata ao hover
func _on_mouse_entered():
	show_cost_preview()  # Mostra Vontade + Corrupção que vai gastar
	highlight_affected_enemy()  # Destaca quem vai ser atingido
	play_hover_sound()  # Audio feedback imediato

func show_cost_preview():
	# CRÍTICO: <100ms de resposta ou quebra imersão
	cost_label.modulate = Color.RED if not_enough_resources() else Color.WHITE
```

#### 2. MOMENTO DA EXECUÇÃO → CombatEffectSystem
**Objetivo:** Feedback dramático que justifica o risco
```gdscript
# Em Card.gd - executar com impacto visual máximo
func play_eco_forte(target):
	# 1. Gasta recursos imediatamente
	GameManager.player_resources.spend_vontade(eco_forte.vontade_cost)
	GameManager.player_resources.add_corrupcao(eco_forte.corrupcao_cost)

	# 2. Efeito visual dramático (tela treme, flash vermelho)
	EffectManager.screen_shake(intensity: 0.8, duration: 0.3)
	EffectManager.corruption_pulse()  # Tela pisca vermelho

	# 3. Carta voa para o alvo com trail de corrupção
	animate_card_to_target(target)

	# 4. Só então aplica dano (timing é crucial)
	await get_tree().create_timer(0.5).timeout
	target.take_damage(eco_forte.power)
```

### PlayerResources.gd (Resource)
```gdscript
class_name PlayerResources
extends Resource

@export var max_vontade: int = 10
@export var current_vontade: int = 10
@export var hp: int = 100
@export var max_hp: int = 100
@export var corrupcao: float = 0.0

signal vontade_changed(new_value: int)
signal hp_changed(new_value: int)
signal corrupcao_changed(new_value: float)

func spend_vontade(amount: int) -> bool:
    if current_vontade >= amount:
        current_vontade -= amount
        vontade_changed.emit(current_vontade)
        return true
    return false

func add_corrupcao(amount: float):
    corrupcao = min(100.0, corrupcao + amount)
    corrupcao_changed.emit(corrupcao)
    if corrupcao >= 100.0:
        GameManager.trigger_corruption_game_over()
```

## Sistema de Cartas Duplas

### Card.gd (Base Class)
```gdscript
class_name Card
extends Resource

@export var card_id: String
@export var name: String
@export var description: String
@export var art_texture: Texture2D

@export var eco_fraco: EcoEffect
@export var eco_forte: EcoEffect

func can_play_eco_fraco() -> bool:
    return GameManager.player_resources.current_vontade >= eco_fraco.vontade_cost

func can_play_eco_forte() -> bool:
    return GameManager.player_resources.current_vontade >= eco_forte.vontade_cost

func play_eco_fraco(target = null):
    if not can_play_eco_fraco():
        return false

    GameManager.player_resources.spend_vontade(eco_fraco.vontade_cost)
    eco_fraco.execute_effect(target)
    return true

func play_eco_forte(target = null):
    if not can_play_eco_forte():
        return false

    GameManager.player_resources.spend_vontade(eco_forte.vontade_cost)
    GameManager.player_resources.add_corrupcao(eco_forte.corrupcao_cost)
    eco_forte.execute_effect(target)
    return true
```

### EcoEffect.gd (Resource)
```gdscript
class_name EcoEffect
extends Resource

@export var vontade_cost: int
@export var corrupcao_cost: float = 0.0
@export var effect_type: EffectType
@export var power: int
@export var target_type: TargetType

enum EffectType {
    DAMAGE,
    HEALING,
    SHIELD,
    BUFF,
    DEBUFF,
    SPECIAL
}

enum TargetType {
    ENEMY,
    SELF,
    ALL_ENEMIES,
    AREA
}

func execute_effect(target):
    match effect_type:
        EffectType.DAMAGE:
            if target and target.has_method("take_damage"):
                target.take_damage(power)
        EffectType.HEALING:
            GameManager.player_resources.heal(power)
        EffectType.SHIELD:
            GameManager.player_resources.add_shield(power)
```

## Fluxo de Turno Detalhado

### TurnManager.gd
```gdscript
class_name TurnManager
extends Node

enum TurnPhase {
    PLAYER_DRAW,
    PLAYER_ACTION,
    ENEMY_ACTION,
    END_CLEANUP
}

var current_phase: TurnPhase = TurnPhase.PLAYER_DRAW
var actions_taken: int = 0
var max_actions_per_turn: int = 3

func start_player_turn():
    current_phase = TurnPhase.PLAYER_DRAW
    GameManager.deck_manager.draw_cards(1)
    GameManager.player_resources.regenerate_vontade()
    current_phase = TurnPhase.PLAYER_ACTION
    GameManager.turn_started.emit()

func try_play_card(card: Card, eco_type: String, target = null) -> bool:
    if current_phase != TurnPhase.PLAYER_ACTION:
        return false

    if actions_taken >= max_actions_per_turn:
        return false

    var success = false
    match eco_type:
        "fraco":
            success = card.play_eco_fraco(target)
        "forte":
            success = card.play_eco_forte(target)

    if success:
        actions_taken += 1
        GameManager.hand_manager.remove_card(card)

    return success

func end_player_turn():
    current_phase = TurnPhase.ENEMY_ACTION
    actions_taken = 0
    start_enemy_turn()

func start_enemy_turn():
    for enemy in GameManager.battle_state.enemies:
        if enemy.is_alive():
            enemy.take_turn()

    current_phase = TurnPhase.END_CLEANUP
    cleanup_turn()

func cleanup_turn():
    GameManager.battle_state.check_win_conditions()
    current_phase = TurnPhase.PLAYER_DRAW
    start_player_turn()
```

## Sistema de Deck e Mão

### DeckManager.gd
```gdscript
class_name DeckManager
extends Node

var deck: Array[Card] = []
var discard_pile: Array[Card] = []
var hand_limit: int = 7

func shuffle_deck():
    deck.shuffle()

func draw_cards(amount: int):
    for i in amount:
        if deck.is_empty():
            if discard_pile.is_empty():
                break
            deck = discard_pile.duplicate()
            discard_pile.clear()
            shuffle_deck()

        var drawn_card = deck.pop_back()
        GameManager.hand_manager.add_card_to_hand(drawn_card)

func add_card_to_deck(card: Card):
    deck.append(card)
```

### HandManager.gd
```gdscript
class_name HandManager
extends Node

var hand: Array[Card] = []
var max_hand_size: int = 7

signal hand_updated
signal card_selected(card: Card)

func add_card_to_hand(card: Card):
    if hand.size() < max_hand_size:
        hand.append(card)
        hand_updated.emit()

func remove_card(card: Card):
    hand.erase(card)
    GameManager.deck_manager.discard_pile.append(card)
    hand_updated.emit()

func can_play_any_card() -> bool:
    for card in hand:
        if card.can_play_eco_fraco() or card.can_play_eco_forte():
            return true
    return false
```

## Condições de Vitória/Derrota

### GameOverManager.gd
```gdscript
class_name GameOverManager
extends Node

enum GameOverReason {
    CORRUPTION_LIMIT,
    HP_ZERO,
    VICTORY
}

func check_game_over_conditions():
    if GameManager.player_resources.corrupcao >= 100.0:
        trigger_game_over(GameOverReason.CORRUPTION_LIMIT)
    elif GameManager.player_resources.hp <= 0:
        trigger_game_over(GameOverReason.HP_ZERO)
    elif GameManager.battle_state.all_enemies_defeated():
        trigger_game_over(GameOverReason.VICTORY)

func trigger_game_over(reason: GameOverReason):
    GameManager.game_over.emit()
    match reason:
        GameOverReason.VICTORY:
            show_victory_screen()
        _:
            show_defeat_screen(reason)
```