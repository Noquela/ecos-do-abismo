# 🌍 Mundo e Exploração do Abismo

## 🎮 EXPERIÊNCIA DO JOGADOR

### A Sensação de Estar Perdido
**"Este lugar não segue as regras... e está me observando"**

O jogador sente que está explorando **algo vivo e malévolo**:
- **Primeira entrada:** "Que lugar estranho... parece uma caverna normal"
- **Após algumas salas:** "Por que voltei para o mesmo lugar?"
- **Progressão:** "As paredes estão se movendo... ou estou imaginando?"
- **Insight:** "Este lugar reage às minhas ações"

### Momentos Psicológicos da Exploração

#### PRIMEIRA IMPRESSÃO (curiosidade)
**Sentimento:** Mistério, descoberta
- **VÊ:** Arquitetura impossível, luz vinda de lugar nenhum
- **ESCUTA:** Ecos distantes de vozes, passos que não são seus
- **SENTE:** "Há algo familiares neste lugar... mas distorcido"
- **EXPLORA:** Tenta entender as regras deste mundo

#### RECONHECIMENTO DE PADRÕES (desconforto)
**Sentimento:** Paranoia crescente
- **PERCEBE:** Salas que se repetem mas são diferentes
- **CONECTA:** "Essa batalha... já aconteceu antes?"
- **QUESTIONA:** "Por que este inimigo sabia minha estratégia?"
- **SUSPEITA:** O mundo está aprendendo com ele

#### ADAPTAÇÃO MÚTUA (tensão)
**Sentimento:** Dança psicológica
- **EXPERIMENTA:** Tenta diferentes abordagens
- **OBSERVA:** Mundo reage às mudanças
- **ADAPTA:** Muda estratégia baseado nas reações
- **REALIZA:** Está numa relação simbiótica com o Abismo

#### DOMÍNIO TEMPORÁRIO (falsa confiança)
**Sentimento:** Controle ilusório
- **MAPEIA:** Encontra padrões nas reações do mundo
- **EXPLORA:** Consegue prever algumas mudanças
- **SENTE:** "Entendi como funciona"
- **SURPRESA:** Mundo muda as regras novamente

### A Psicologia da Exploração Procedural

#### TIPOS DE TENSÃO ESPACIAL

**TENSÃO DE FAMILIARIDADE**
- **Ambiente:** Salões que parecem memórias pessoais
- **Sensação:** "Conheço este lugar... mas de onde?"
- **Efeito:** Jogador questiona próprias memórias

**TENSÃO DE IMPOSSIBILIDADE**
- **Ambiente:** Física distorcida, geometria não-euclidiana
- **Sensação:** "Isso não deveria ser possível"
- **Efeito:** Desorienta e força adaptação mental

**TENSÃO DE OBSERVAÇÃO**
- **Ambiente:** Elementos que mudam quando não observados
- **Sensação:** "Algo mudou quando não estava olhando"
- **Efeito:** Paranoia e hipervigilância

## 🔗 INTEGRAÇÃO COM OUTRAS FEATURES

### Mundo ↔ Corruption Levels
- **recursos.md:** Nível de Corrupção altera aparência do mundo
- **0-25%:** Ambientes relativamente normais, levemente distorcidos
- **50-75%:** Realidade instável, objetos se movem
- **80-100%:** Mundo completamente irreconhecível, physics quebradas

### Mundo ↔ Enemy Adaptation
- **inimigos.md:** Ambientes "lembram" de batalhas anteriores
- **Primeira visita:** Disposição padrão dos inimigos
- **Retorno:** Layout mudou baseado em como jogador lutou
- **Escalada:** Armadilhas colocadas onde jogador costuma se posicionar

### Mundo ↔ Card Discovery
- **cartas.md:** Ambiente determina tipos de carta encontradas
- **Bibliotecas:** Cartas de conhecimento e magia
- **Campos de Batalha:** Cartas de combate e táticas
- **Jardins Corrompidos:** Cartas de natureza e transformação

### Mundo ↔ Visual Narrative
- **lore.md:** Cada ambiente conta parte da história
- **arte.md:** Estilo visual muda baseado na profundidade
- **interface.md:** UI se adapta ao ambiente atual

## ⚙️ ARQUITETURA QUE SUPORTA A EXPERIÊNCIA

### AbyssWorldManager.gd (O Mundo Vivo)

#### Sistema que Cria Sensação de Entidade Viva
```gdscript
class_name AbyssWorldManager
extends Node

# MEMÓRIA DO MUNDO: O que o Abismo "lembra"
var player_history: Dictionary = {}
var room_visit_count: Dictionary = {}
var battle_outcomes: Array[BattleResult] = []
var corruption_snapshots: Array[float] = []

# PERSONALIDADE DO ABISMO: Como reage ao jogador
var world_hostility: float = 0.0
var adaptation_level: float = 0.0
var reality_stability: float = 1.0

signal world_adapted(adaptation_type: String)
signal reality_shifted(severity: float)
signal abyss_reaction(reaction_type: String)

# OBSERVAÇÃO CONSTANTE: Mundo vê tudo que o jogador faz
func record_player_action(action_type: String, context: Dictionary):
    # Registra no histórico do jogador
    if not player_history.has(action_type):
        player_history[action_type] = []

    player_history[action_type].append({
        "timestamp": Time.get_ticks_msec(),
        "context": context,
        "corruption_level": GameManager.player_resources.corrupcao
    })

    # REAÇÃO IMEDIATA: Mundo responde em tempo real
    process_world_reaction(action_type, context)

func process_world_reaction(action_type: String, context: Dictionary):
    match action_type:
        "eco_forte_used":
            # Mundo fica mais hostil com uso de poder corrupto
            world_hostility += 0.1
            if context.corruption_gained > 15:
                trigger_reality_distortion(0.3)

        "pattern_detected":
            # Mundo adapta quando jogador é previsível
            adaptation_level += 0.2
            adapt_environment_layout()

        "new_room_entered":
            # Registra visitas para personalização futura
            var room_id = context.room_id
            room_visit_count[room_id] = room_visit_count.get(room_id, 0) + 1
            personalize_room_experience(room_id)

func trigger_reality_distortion(intensity: float):
    # FEEDBACK VISUAL: Jogador VÊ que mundo está reagindo
    reality_stability = max(0.1, reality_stability - intensity)

    EnvironmentVisuals.start_reality_distortion(intensity)
    AudioManager.play_abyss_reaction_sfx()

    reality_shifted.emit(intensity)
```

#### Sistema de Geração Procedural Psicológica
```gdscript
func generate_room_layout(room_type: String, visit_number: int) -> RoomLayout:
    var base_layout = RoomTemplates.get_template(room_type)

    # PRIMEIRA VISITA: Layout padrão, familiar
    if visit_number == 1:
        return base_layout

    # ADAPTAÇÃO BASEADA EM HISTÓRICO
    var adapted_layout = base_layout.duplicate()

    # Adapta baseado em como o jogador se comportou antes
    adapt_layout_to_player_behavior(adapted_layout)

    # Adiciona elementos psicológicos baseados na corrupção
    add_corruption_influences(adapted_layout)

    # Aplica distorção da realidade
    apply_reality_distortion(adapted_layout)

    return adapted_layout

func adapt_layout_to_player_behavior(layout: RoomLayout):
    # PADRÕES DE MOVIMENTO: Muda layout baseado em como jogador se move
    var movement_pattern = analyze_movement_patterns()

    match movement_pattern:
        "cautious":
            # Jogador cauteloso: força movimento rápido
            layout.add_pressure_elements()
        "aggressive":
            # Jogador agressivo: adiciona armadilhas
            layout.add_defensive_challenges()
        "predictable":
            # Jogador previsível: muda posições completamente
            layout.randomize_key_positions()

func add_corruption_influences(layout: RoomLayout):
    var corruption_percent = GameManager.player_resources.corrupcao / 100.0

    match corruption_percent:
        var x when x < 0.25:
            # Baixa corrupção: sutis alterações
            layout.add_subtle_wrongness()
        var x when x < 0.5:
            # Média corrupção: geometria instável
            layout.add_impossible_geometry()
        var x when x < 0.75:
            # Alta corrupção: physics quebradas
            layout.break_physical_laws()
        _:
            # Corrupção extrema: realidade fragmentada
            layout.fragment_reality()
```

### EnvironmentNarrative.gd (Contador de Histórias)

#### Sistema que Revela Lore Através do Ambiente
```gdscript
class_name EnvironmentNarrative
extends Node

# FRAGMENTOS DE HISTÓRIA: Revelados através da exploração
var discovered_fragments: Array[String] = []
var current_narrative_thread: String = ""
var story_progression: float = 0.0

# NARRATIVA AMBIENTAL: História contada pelo espaço
func setup_room_narrative(room_type: String, corruption_level: float):
    # Escolhe fragmentos de história apropriados
    var available_fragments = NarrativeDatabase.get_fragments_for_room(room_type)
    var corruption_tier = int(corruption_level / 25.0)

    # Filtra por nível de corrupção (histórias mais sombrias em níveis altos)
    var filtered_fragments = filter_by_corruption_tier(available_fragments, corruption_tier)

    # Seleciona baseado no que o jogador já descobriu
    var selected_fragment = choose_narrative_fragment(filtered_fragments)

    if selected_fragment:
        place_narrative_elements(selected_fragment)

func place_narrative_elements(fragment: NarrativeFragment):
    # ELEMENTOS VISUAIS: Objetos que contam história
    for element in fragment.visual_elements:
        place_interactive_object(element)

    # ATMOSFERA: Ajusta clima baseado na história
    adjust_room_atmosphere(fragment.mood)

    # ÁUDIO: Sons ambientes que complementam narrativa
    setup_narrative_audio(fragment.audio_cues)

func place_interactive_object(element: NarrativeElement):
    # DESCOBERTA ORGÂNICA: Jogador encontra história explorando
    var object = InteractiveObjectFactory.create(element.type)
    object.narrative_payload = element.story_fragment
    object.interaction_triggered.connect(_on_narrative_discovered)

    # Posiciona de forma que jogador encontre naturalmente
    var position = find_natural_discovery_position(element.discovery_context)
    CurrentRoom.add_child(object)
    object.global_position = position

func _on_narrative_discovered(fragment: String):
    # PROGRESSO NARRATIVO: Jogador desvenda mistério
    discovered_fragments.append(fragment)
    story_progression = calculate_story_completion()

    # FEEDBACK: Jogador sabe que descobriu algo importante
    UIManager.show_lore_discovery_notification(fragment)

    # CONEXÕES: Fragmentos se conectam para formar história maior
    check_for_narrative_connections()
```

### EnvironmentVisuals.gd (Feedback Visual do Mundo)

#### Sistema que Mostra Reações do Mundo
```gdscript
class_name EnvironmentVisuals
extends Node

# SHADER EFFECTS: Distorções visuais que comunicam estado do mundo
@onready var reality_distortion_shader = preload("res://shaders/reality_distortion.gdshader")
@onready var corruption_influence_shader = preload("res://shaders/corruption_influence.gdshader")

func start_reality_distortion(intensity: float):
    # DISTORÇÃO VISUAL: Jogador VÊ que realidade está instável
    var screen_material = get_viewport().get_screen_material()
    if not screen_material:
        screen_material = ShaderMaterial.new()
        screen_material.shader = reality_distortion_shader
        get_viewport().set_screen_material(screen_material)

    # Parâmetros baseados na intensidade
    screen_material.set_shader_parameter("distortion_strength", intensity)
    screen_material.set_shader_parameter("wave_frequency", intensity * 3.0)
    screen_material.set_shader_parameter("color_shift", intensity * 0.5)

func show_world_adaptation(adaptation_type: String):
    # FEEDBACK VISUAL: Mundo está mudando em resposta ao jogador
    match adaptation_type:
        "layout_shift":
            # Paredes sutilmente se movem
            animate_wall_repositioning()
        "hostility_increase":
            # Ambiente fica mais ameaçador
            darken_ambient_lighting(0.2)
            add_threatening_particles()
        "reality_break":
            # Physics começam a falhar
            enable_impossible_geometry_effects()

func animate_wall_repositioning():
    # MOVIMENTO SUTIL: Jogador percebe que algo mudou
    var walls = get_tree().get_nodes_in_group("environment_walls")

    for wall in walls:
        var original_pos = wall.position
        var tween = create_tween()

        # Movimento quase imperceptível mas perturbador
        tween.tween_property(wall, "position", original_pos + Vector2(randf_range(-2, 2), 0), 2.0)
        tween.tween_property(wall, "position", original_pos, 1.0)

func apply_corruption_visual_influence(corruption_percent: float):
    # CORRUPÇÃO AMBIENTAL: Mundo muda com a corrupção do jogador
    var room_materials = get_tree().get_nodes_in_group("room_materials")

    for material in room_materials:
        var shader_material = material.get_surface_override_material(0)
        if shader_material and shader_material.shader == corruption_influence_shader:
            shader_material.set_shader_parameter("corruption_level", corruption_percent)
            shader_material.set_shader_parameter("decay_intensity", corruption_percent * 0.8)
```

### ProceduralRoomGenerator.gd (Geração Inteligente)

#### Sistema que Gera Experiências Únicas
```gdscript
class_name ProceduralRoomGenerator
extends Node

# TEMPLATES PSICOLÓGICOS: Salas que evocam emoções específicas
var room_templates: Dictionary = {
    "memory_library": {
        "base_emotion": "nostalgia",
        "corruption_variants": ["knowledge_forbidden", "books_bleeding", "words_crawling"]
    },
    "battle_echo": {
        "base_emotion": "heroism",
        "corruption_variants": ["glory_tarnished", "victory_pyrrhic", "defeat_eternal"]
    },
    "nature_twisted": {
        "base_emotion": "peace",
        "corruption_variants": ["growth_malignant", "beauty_predatory", "life_parasitic"]
    }
}

func generate_psychologically_appropriate_room(context: RoomContext) -> Room:
    # CONTEXTUALIZAÇÃO: Sala apropriada para o estado psicológico
    var room_type = choose_room_type_for_context(context)
    var corruption_variant = choose_corruption_variant(room_type, context.corruption_level)

    # GERAÇÃO BASEADA EM EMOÇÃO ALVO
    var room = create_base_room(room_type)
    apply_corruption_influence(room, corruption_variant)
    add_adaptive_elements(room, context.player_behavior)

    return room

func choose_room_type_for_context(context: RoomContext) -> String:
    # PROGRESSÃO EMOCIONAL: Tipos de sala baseados na jornada do jogador
    match context.story_progression:
        var x when x < 0.3:
            # Início: salas familiares e menos ameaçadoras
            return choose_weighted(["memory_library", "nature_twisted"], [0.6, 0.4])
        var x when x < 0.7:
            # Meio: introduz conflito e tensão
            return choose_weighted(["battle_echo", "memory_library", "nature_twisted"], [0.5, 0.3, 0.2])
        _:
            # Fim: confronto direto com horror
            return choose_weighted(["battle_echo", "void_chamber", "origin_core"], [0.4, 0.3, 0.3])

func add_adaptive_elements(room: Room, player_behavior: PlayerBehavior):
    # ADAPTAÇÃO ESPECÍFICA: Elementos que reagem ao comportamento
    if player_behavior.prefers_stealth:
        room.add_shadow_areas()
        room.add_alternative_paths()

    if player_behavior.prefers_aggression:
        room.add_direct_challenges()
        room.increase_enemy_density()

    if player_behavior.is_predictable:
        room.randomize_expected_elements()
        room.add_misdirection_elements()
```