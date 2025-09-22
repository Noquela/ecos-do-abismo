# 👹 Sistema de Inimigos e Adaptação Psicológica

## 🎮 EXPERIÊNCIA DO JOGADOR

### A Sensação de Estar Sendo Observado
**"Ele está aprendendo comigo... preciso mudar"**

O jogador sente que **nunca está seguro** porque:
- **Primeira luta:** "Isso é fácil, só atacar"
- **Segunda luta:** "Estranho, ele se defendeu melhor..."
- **Terceira luta:** "Ele SABIA que eu ia fazer isso!"
- **Quarta luta:** "Preciso mudar completamente minha estratégia"

### Momentos Psicológicos com Inimigos

#### PRIMEIRO CONTATO (ingenuidade)
**Sentimento:** Confiança, rotina
- **VÊ:** Inimigo básico, padrões previsíveis
- **PENSA:** "Sei como vencer esse tipo"
- **FAZ:** Usa mesma estratégia que funcionou antes
- **RESULTADO:** Funciona... por enquanto

#### MOMENTO DA ADAPTAÇÃO (surpresa)
**Sentimento:** Confusão, desconforto
- **VÊ:** Inimigo reage diferente do esperado
- **PENSA:** "Ele bloqueou? Não fez isso antes..."
- **SENTE:** "Algo mudou, ele aprendeu"
- **FORÇA:** Jogador a repensar abordagem

#### ESCALADA ADAPTATIVA (paranoia)
**Sentimento:** Tensão crescente, incerteza
- **VÊ:** Inimigo antecipa movimentos
- **PENSA:** "Ele está prevendo tudo que faço"
- **SENTE:** "Estou sendo estudado, dissecado"
- **ADAPTA:** Muda estratégia desesperadamente

#### CONTRA-ADAPTAÇÃO (satisfação)
**Sentimento:** Alívio, triunfo intelectual
- **FAZ:** Muda padrão completamente
- **VÊ:** Inimigo confuso, vulnerável
- **SENTE:** "Consegui! Quebrei o padrão dele!"
- **APRENDE:** Adaptação é uma dança, não uma corrida

### A Psicologia da Adaptação

#### TIPOS DE PRESSÃO PSICOLÓGICA

**PRESSÃO DE EFICIÊNCIA**
- **Inimigo:** Guardian Adaptativo
- **Sensação:** "Preciso ser rápido ou ele fica forte demais"
- **Comportamento:** Força uso de Eco Forte (risco de Corrupção)

**PRESSÃO DE IMPREVISIBILIDADE**
- **Inimigo:** Parasite Mimético
- **Sensação:** "Não posso ter padrões ou ele copia"
- **Comportamento:** Força variação de estratégias

**PRESSÃO DE ESCALADA**
- **Inimigo:** Echo Corrompido
- **Sensação:** "Quanto mais corrupto fico, mais forte ele fica"
- **Comportamento:** Dilema entre poder e segurança

## 🔗 INTEGRAÇÃO COM OUTRAS FEATURES

### Inimigos ↔ Player Behavior Tracking
- **mecanica.md:** Sistema observa padrões de eco_fraco vs eco_forte
- **Eco Fraco 80%+:** Inimigos se tornam mais defensivos/resilientes
- **Eco Forte 60%+:** Inimigos se tornam mais agressivos/rápidos
- **Padrão fixo:** Inimigos antecipam próximos movimentos

### Inimigos ↔ Corruption Levels
- **recursos.md:** Nível de Corrupção afeta comportamento inimigo
- **0-25% Corrupção:** Inimigos testam jogador (agressivos)
- **50-75% Corrupção:** Inimigos respeitam jogador (cautelosos)
- **80-100% Corrupção:** Inimigos esperam jogador se destruir

### Inimigos ↔ Visual Adaptation Feedback
- **interface.md:** Jogador VÊ que inimigo está adaptando
- **Olhos brilhando:** Inimigo analisando padrões
- **Postura mudando:** Inimigo se preparando contra estratégia
- **Aura diferente:** Novo nível de adaptação alcançado

### Inimigos ↔ Card Selection Pressure
- **cartas.md:** Adaptação força uso de diferentes tipos de carta
- **Inimigo resistente:** Força uso de cartas de penetração
- **Inimigo rápido:** Força uso de cartas de controle
- **Inimigo copycat:** Força uso de cartas únicas/inesperadas

## ⚙️ ARQUITETURA QUE SUPORTA A EXPERIÊNCIA

### PlayerBehaviorTracker.gd (O Observador)

#### Sistema que Cria Paranoia
```gdscript
class_name PlayerBehaviorTracker
extends Node

# DADOS DO COMPORTAMENTO: O que inimigos "veem"
var eco_fraco_count: int = 0
var eco_forte_count: int = 0
var card_types_used: Dictionary = {}
var recent_actions: Array[String] = []
var total_corruption_gained: float = 0.0

# PADRÕES IDENTIFICADOS: "Personalidade" do jogador
var player_profile: String = "unknown"
var aggression_level: float = 0.0
var pattern_predictability: float = 0.0
var risk_tolerance: float = 0.0

signal behavior_analyzed(profile: String, confidence: float)
signal pattern_detected(pattern_type: String, strength: float)

# OBSERVAÇÃO CONTÍNUA: Cada ação é registrada
func track_card_played(card: Card, eco_type: String):
    # Registra tipo de eco usado
    match eco_type:
        "fraco":
            eco_fraco_count += 1
        "forte":
            eco_forte_count += 1
            total_corruption_gained += card.eco_forte.corrupcao_cost

    # Registra tipo de carta para detectar preferências
    var card_category = card.get_category()
    if card_types_used.has(card_category):
        card_types_used[card_category] += 1
    else:
        card_types_used[card_category] = 1

    # Mantém histórico das últimas 10 ações
    recent_actions.append(eco_type + "_" + card_category)
    if recent_actions.size() > 10:
        recent_actions.pop_front()

    # CRÍTICO: Análise em tempo real
    analyze_behavior_patterns()

func analyze_behavior_patterns():
    # AGRESSIVIDADE: Quantos Ecos Fortes vs total
    var total_actions = eco_fraco_count + eco_forte_count
    if total_actions > 0:
        aggression_level = float(eco_forte_count) / total_actions

    # PREDICTABILIDADE: Variação nas últimas ações
    pattern_predictability = calculate_pattern_strength()

    # TOLERÂNCIA AO RISCO: Corrupção ganha por ação
    if eco_forte_count > 0:
        risk_tolerance = total_corruption_gained / eco_forte_count

    # PERFIL DO JOGADOR: Classificação para inimigos
    determine_player_profile()

func determine_player_profile():
    var new_profile = "balanced"

    # PERFIS EXTREMOS: Mais fáceis de contra-atacar
    if aggression_level >= 0.7:
        new_profile = "berserker"      # Sempre Eco Forte
    elif aggression_level <= 0.3:
        new_profile = "conservative"   # Sempre Eco Fraco
    elif pattern_predictability >= 0.8:
        new_profile = "predictable"    # Padrões fixos
    elif risk_tolerance >= 20.0:
        new_profile = "reckless"       # Alto risco sempre

    # MUDANÇA DE PERFIL: Inimigos precisam saber
    if new_profile != player_profile:
        player_profile = new_profile
        behavior_analyzed.emit(new_profile, pattern_predictability)

func calculate_pattern_strength() -> float:
    # Analisa últimas 6 ações para detectar padrões
    if recent_actions.size() < 6:
        return 0.0

    var pattern_count = 0
    var total_comparisons = 0

    # Busca por padrões de repetição
    for i in range(recent_actions.size() - 3):
        for j in range(i + 3, recent_actions.size()):
            total_comparisons += 1
            if recent_actions[i] == recent_actions[j]:
                pattern_count += 1

    return float(pattern_count) / total_comparisons if total_comparisons > 0 else 0.0
```

### EnemyAdaptationSystem.gd (O Aprendiz)

#### Sistema que Gera Tensão Crescente
```gdscript
class_name EnemyAdaptationSystem
extends Node

# NÍVEIS DE ADAPTAÇÃO: Escalada psicológica
enum AdaptationLevel {
    NAIVE,          # Inimigo não adaptou ainda
    LEARNING,       # Começou a notar padrões
    ADAPTING,       # Mudou comportamento
    COUNTERING,     # Antecipa movimentos
    MASTERING       # Domina completamente
}

var current_level: AdaptationLevel = AdaptationLevel.NAIVE
var adaptation_confidence: float = 0.0
var turns_observing: int = 0

# COUNTER-STRATEGIES: Como inimigo reage a cada perfil
var counter_strategies: Dictionary = {
    "berserker": "defensive_wall",      # Bloqueia Ecos Fortes
    "conservative": "aggression_ramp",  # Força Ecos Fortes
    "predictable": "anticipation",      # Antecipa movimentos
    "reckless": "corruption_feeder",    # Acelera Corrupção
    "balanced": "pressure_test"         # Testa limites
}

signal adaptation_escalated(new_level: AdaptationLevel)
signal counter_strategy_activated(strategy: String)

func _ready():
    # OBSERVAÇÃO CONSTANTE: Conecta ao tracker
    PlayerBehaviorTracker.behavior_analyzed.connect(_on_behavior_analyzed)
    PlayerBehaviorTracker.pattern_detected.connect(_on_pattern_detected)

func _on_behavior_analyzed(profile: String, confidence: float):
    adaptation_confidence = confidence

    # ESCALADA BASEADA EM CONFIANÇA
    var new_level = current_level
    match confidence:
        var x when x >= 0.8:
            new_level = AdaptationLevel.MASTERING
        var x when x >= 0.6:
            new_level = AdaptationLevel.COUNTERING
        var x when x >= 0.4:
            new_level = AdaptationLevel.ADAPTING
        var x when x >= 0.2:
            new_level = AdaptationLevel.LEARNING

    # MUDANÇA DE NÍVEL: Visual feedback crítico
    if new_level != current_level:
        current_level = new_level
        adaptation_escalated.emit(new_level)

        # Inimigo mostra que está adaptando
        show_adaptation_visual_feedback()

    # ATIVA CONTRA-ESTRATÉGIA
    if counter_strategies.has(profile):
        var strategy = counter_strategies[profile]
        counter_strategy_activated.emit(strategy)

func show_adaptation_visual_feedback():
    # FEEDBACK VISUAL: Jogador VÊ que inimigo mudou
    match current_level:
        AdaptationLevel.LEARNING:
            # Olhos começam a brilhar
            EnemyVisuals.start_analysis_glow()
        AdaptationLevel.ADAPTING:
            # Postura muda, fica mais alerta
            EnemyVisuals.change_stance("alert")
        AdaptationLevel.COUNTERING:
            # Aura defensiva/ofensiva baseada na estratégia
            EnemyVisuals.activate_counter_aura()
        AdaptationLevel.MASTERING:
            # Transformação visual dramática
            EnemyVisuals.evolution_effect()

# APLICAÇÃO DA ADAPTAÇÃO: Como muda o comportamento
func modify_enemy_action(base_action: EnemyAction) -> EnemyAction:
    var modified_action = base_action.duplicate()

    match current_level:
        AdaptationLevel.NAIVE:
            # Sem modificações
            return base_action

        AdaptationLevel.LEARNING:
            # Pequenos ajustes
            modified_action.damage *= 1.1

        AdaptationLevel.ADAPTING:
            # Muda tipo de ataque baseado no perfil do jogador
            adapt_action_to_player_profile(modified_action)

        AdaptationLevel.COUNTERING:
            # Antecipa e contra movimento específico
            counter_expected_player_action(modified_action)

        AdaptationLevel.MASTERING:
            # Controla completamente o ritmo da batalha
            master_combat_flow(modified_action)

    return modified_action
```

### Tipos de Inimigos Adaptativos

#### GuardianAdaptivo.gd
```gdscript
extends Enemy
class_name GuardianAdaptivo

# PERSONALIDADE: Tanque que aprende a se defender melhor
var damage_types_received: Dictionary = {}
var preferred_defense: String = "armor"

func _ready():
    # ESPECIALIZAÇÃO: Aprende sobre tipos de dano
    EnemyAdaptationSystem.counter_strategy_activated.connect(_on_counter_strategy)

func take_damage(amount: int, damage_type: String):
    # APRENDE: Registra tipos de dano recebidos
    if damage_types_received.has(damage_type):
        damage_types_received[damage_type] += 1
    else:
        damage_types_received[damage_type] = 1

    # ADAPTA: Fica mais resistente ao tipo mais usado
    var most_common_damage = get_most_common_damage_type()
    if most_common_damage != "":
        develop_resistance(most_common_damage)

    super.take_damage(amount, damage_type)

func develop_resistance(damage_type: String):
    # FEEDBACK VISUAL: Jogador vê que está ficando resistente
    EnemyVisuals.show_resistance_buildup(damage_type)

    # MECÂNICA: Redução progressiva de dano
    var current_resistance = resistances.get(damage_type, 0.0)
    resistances[damage_type] = min(0.5, current_resistance + 0.1)

func _on_counter_strategy(strategy: String):
    match strategy:
        "defensive_wall":
            # Contra jogadores agressivos
            activate_defensive_wall()
        "aggression_ramp":
            # Força jogadores conservadores
            start_aggression_ramp()
```

#### ParasiteMimetico.gd
```gdscript
extends Enemy
class_name ParasiteMimetico

# PERSONALIDADE: Copia e evolui baseado no jogador
var copied_abilities: Array[String] = []
var mimicry_strength: float = 0.0

func observe_player_action(card: Card, eco_type: String):
    # CÓPIA: "Aprende" habilidades do jogador
    var ability_signature = card.name + "_" + eco_type

    if not copied_abilities.has(ability_signature):
        copied_abilities.append(ability_signature)
        mimicry_strength += 0.2

        # FEEDBACK: Jogador vê que está sendo copiado
        EnemyVisuals.show_mimicry_effect(card.art_texture)

func choose_action() -> EnemyAction:
    # USA: Habilidades copiadas contra o jogador
    if copied_abilities.size() > 0 and randf() < mimicry_strength:
        return create_mimicked_action()
    else:
        return super.choose_action()

func create_mimicked_action() -> EnemyAction:
    # IRONIA: Usa poderes do jogador contra ele
    var random_ability = copied_abilities[randi() % copied_abilities.size()]
    return EnemyActionFactory.create_from_signature(random_ability)
```

### Sistema de Escalada Visual

#### EnemyVisuals.gd
```gdscript
extends Node

# COMUNICAÇÃO VISUAL: Jogador precisa VER a adaptação
func start_analysis_glow():
    # Olhos brilham = está observando
    var eyes = enemy.get_node("Eyes")
    var tween = create_tween()
    tween.set_loops()
    tween.tween_property(eyes, "modulate", Color.CYAN, 0.5)
    tween.tween_property(eyes, "modulate", Color.WHITE, 0.5)

func change_stance(stance_type: String):
    # Postura muda = mudou estratégia
    var sprite = enemy.get_node("Sprite")
    match stance_type:
        "alert":
            sprite.rotation = deg_to_rad(-5)
            sprite.scale = Vector2(1.1, 1.1)
        "defensive":
            sprite.modulate = Color.STEEL_BLUE
        "aggressive":
            sprite.modulate = Color.CRIMSON

func activate_counter_aura():
    # Aura = preparado para contra-atacar
    var aura = enemy.get_node("CounterAura")
    aura.visible = true
    aura.play("counter_ready")

func evolution_effect():
    # Transformação = nova fase da batalha
    EffectManager.screen_flash(Color.RED, 0.2)
    var sprite = enemy.get_node("Sprite")

    var tween = create_tween()
    tween.tween_property(sprite, "scale", Vector2(1.5, 1.5), 0.3)
    tween.tween_property(sprite, "scale", Vector2(1.2, 1.2), 0.2)

    # ÁUDIO: Som ameaçador
    AudioManager.play_sfx("enemy_evolution")
```

### Balanceamento da Adaptação

#### AdaptationBalancer.gd
```gdscript
extends Node

# CONFIGURAÇÕES: Adaptação que pressiona sem frustrar
const MIN_TURNS_TO_ADAPT = 3        # Não adapta muito rápido
const MAX_ADAPTATION_LEVEL = 0.8    # Nunca se torna impossível
const RESET_CHANCE_PER_TURN = 0.1   # Pode "esquecer" adaptações

func balance_adaptation_speed(enemy_type: String, current_confidence: float) -> float:
    # DIFERENTES VELOCIDADES: Alguns inimigos aprendem mais rápido
    var learning_rate = 0.1

    match enemy_type:
        "guardian":
            learning_rate = 0.05  # Lento, mas persistente
        "parasite":
            learning_rate = 0.15  # Rápido, mas instável
        "echo":
            learning_rate = 0.2   # Muito rápido

    return min(MAX_ADAPTATION_LEVEL, current_confidence + learning_rate)

func should_reset_adaptation() -> bool:
    # VÁLVULA DE ESCAPE: Adaptação pode "falhar"
    return randf() < RESET_CHANCE_PER_TURN
```