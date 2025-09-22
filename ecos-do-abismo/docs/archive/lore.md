# 📜 Lore e Descoberta Narrativa

## 🎮 EXPERIÊNCIA DO JOGADOR

### A Sensação de Desvendamento Gradual
**"Cada fragmento que encontro torna o mistério ainda maior"**

O jogador experimenta uma **revelação psicológica progressiva**:
- **Primeiro fragmento:** "Que história estranha... será verdade?"
- **Conexões iniciais:** "Espera... isto se relaciona com aquilo que vi antes"
- **Insight perturbador:** "Se isso é verdade, então eu... quem sou eu?"
- **Revelação final:** "Tudo se conecta... e é pior do que imaginava"

### Momentos Psicológicos da Descoberta

#### FRAGMENTO ISOLADO (curiosidade)
**Sentimento:** Intriga, especulação
- **ENCONTRA:** Objeto ou texto misterioso
- **LÊ:** Referência a eventos desconhecidos
- **QUESTIONA:** "O que significa isso?"
- **IMAGINA:** Teorias sobre o contexto

#### PRIMEIRA CONEXÃO (insight)
**Sentimento:** Satisfação de descoberta
- **RECONHECE:** Padrão entre fragmentos
- **CONECTA:** "Este nome apareceu antes!"
- **COMPREENDE:** Relação entre elementos
- **QUER MAIS:** Anseia por próxima peça

#### REVELAÇÃO PERTURBADORA (inquietação)
**Sentimento:** Desconforto crescente
- **DESCOBRE:** Verdade sobre si mesmo
- **QUESTIONA:** "Será que sou realmente...?"
- **NEGA:** "Isso não pode estar certo"
- **ACEITA:** Reluctância em aceitar a realidade

#### COMPREENSÃO FINAL (catarse)
**Sentimento:** Mistura de horror e satisfação
- **VÊ:** Quadro completo da verdade
- **ENTENDE:** Seu papel na tragédia
- **ACEITA:** Responsabilidade e destino
- **ESCOLHE:** O que fazer com o conhecimento

### A Psicologia da Descoberta Narrativa

#### TIPOS DE FRAGMENTOS NARRATIVOS

**FRAGMENTOS ÍNTIMOS**
- **Conteúdo:** Memórias pessoais do protagonista
- **Sensação:** "Isso parece familiar... seria minha memória?"
- **Efeito:** Questiona identidade própria

**FRAGMENTOS HISTÓRICOS**
- **Conteúdo:** Eventos que criaram o Abismo
- **Sensação:** "Que tragédia terrível... quem fez isso?"
- **Efeito:** Constrói contexto do mundo

**FRAGMENTOS PROFÉTICOS**
- **Conteúdo:** Previsões sobre o futuro/fim
- **Sensação:** "Se isso é verdade, então estamos condenados"
- **Efeito:** Tensão sobre o desfecho

## 🔗 INTEGRAÇÃO COM OUTRAS FEATURES

### Lore ↔ World Exploration
- **mundo.md:** Cada ambiente revela fragmentos específicos da história
- **Bibliotecas:** Documentos sobre a civilização perdida
- **Campos de Batalha:** Relatos de guerra que criou o Abismo
- **Jardins Corrompidos:** Experiências de transformação

### Lore ↔ Corruption Progression
- **recursos.md:** Níveis de Corrupção revelam diferentes aspectos
- **0-25%:** Verdades superficiais, história "oficial"
- **50-75%:** Contradições, versões alternativas
- **80-100%:** Verdades brutas, realidade sem filtros

### Lore ↔ Card Narratives
- **cartas.md:** Cada carta conta parte da história maior
- **Nome da carta:** Referência a eventos históricos
- **Arte da carta:** Retrata momentos específicos
- **Flavor text:** Citações de personagens históricos

### Lore ↔ Enemy Behavior
- **inimigos.md:** Inimigos são ecos de personagens históricos
- **Comportamento adaptativo:** Reflete personalidade original
- **Padrões de ataque:** Baseados em táticas que usavam em vida
- **Reações:** Memórias de como interagiam com outros

## ⚙️ ARQUITETURA QUE SUPORTA A EXPERIÊNCIA

### NarrativeDiscoverySystem.gd (Revelador de Segredos)

#### Sistema que Controla Revelação Progressiva
```gdscript
class_name NarrativeDiscoverySystem
extends Node

# FRAGMENTOS NARRATIVOS: Base de dados da história
var narrative_fragments: Dictionary = {}
var discovered_fragments: Array[String] = []
var connection_matrix: Dictionary = {}

# PROGRESSÃO DA REVELAÇÃO: Controla timing das descobertas
var story_progression_tier: int = 0
var player_understanding_level: float = 0.0
var revelation_readiness: float = 0.0

signal fragment_discovered(fragment_id: String, content: String)
signal connection_revealed(fragment_a: String, fragment_b: String)
signal major_revelation(revelation_type: String)

func _ready():
    # CARREGA BASE DE FRAGMENTOS
    load_narrative_database()

    # CONECTA COM OUTROS SISTEMAS
    AbyssWorldManager.room_entered.connect(_on_room_entered)
    GameManager.player_resources.corrupcao_changed.connect(_on_corruption_changed)

func _on_room_entered(room_type: String, corruption_level: float):
    # FRAGMENTOS AMBIENTAIS: História contada pelo espaço
    var available_fragments = get_fragments_for_context(room_type, corruption_level)

    for fragment_id in available_fragments:
        if should_reveal_fragment(fragment_id):
            place_fragment_in_room(fragment_id)

func should_reveal_fragment(fragment_id: String) -> bool:
    var fragment = narrative_fragments[fragment_id]

    # CONTROLE DE TIMING: Fragmentos aparecem na ordem certa
    if fragment.min_progression_tier > story_progression_tier:
        return false

    # CONTROLE DE CORRUPÇÃO: Verdades brutais só em altos níveis
    var current_corruption = GameManager.player_resources.corrupcao / 100.0
    if fragment.min_corruption_level > current_corruption:
        return false

    # CONTROLE DE DEPENDÊNCIAS: Alguns fragmentos precisam de outros
    for dependency in fragment.required_fragments:
        if not discovered_fragments.has(dependency):
            return false

    return true

func place_fragment_in_room(fragment_id: String):
    var fragment = narrative_fragments[fragment_id]

    # CRIA OBJETO INTERATIVO
    var narrative_object = create_narrative_object(fragment)
    narrative_object.interaction_triggered.connect(_on_fragment_discovered.bind(fragment_id))

    # POSICIONA NATURALMENTE
    var position = find_narrative_placement_position(fragment.placement_context)
    CurrentRoom.add_child(narrative_object)
    narrative_object.global_position = position

func _on_fragment_discovered(fragment_id: String):
    if discovered_fragments.has(fragment_id):
        return

    # REGISTRA DESCOBERTA
    discovered_fragments.append(fragment_id)
    var fragment = narrative_fragments[fragment_id]

    # FEEDBACK IMEDIATO
    fragment_discovered.emit(fragment_id, fragment.content)
    UIManager.show_lore_discovery(fragment)

    # ANÁLISE DE CONEXÕES
    check_for_new_connections(fragment_id)

    # ATUALIZA PROGRESSÃO
    update_story_progression()

func check_for_new_connections(new_fragment_id: String):
    # BUSCA CONEXÕES COM FRAGMENTOS EXISTENTES
    for existing_fragment_id in discovered_fragments:
        if existing_fragment_id == new_fragment_id:
            continue

        var connection_key = get_connection_key(existing_fragment_id, new_fragment_id)
        if connection_matrix.has(connection_key):
            # NOVA CONEXÃO DESCOBERTA
            reveal_connection(existing_fragment_id, new_fragment_id)

func reveal_connection(fragment_a: String, fragment_b: String):
    var connection_key = get_connection_key(fragment_a, fragment_b)
    var connection = connection_matrix[connection_key]

    # REVELA NOVA INFORMAÇÃO
    connection_revealed.emit(fragment_a, fragment_b)
    UIManager.show_narrative_connection(connection)

    # AUMENTA COMPREENSÃO DO JOGADOR
    player_understanding_level += connection.understanding_boost

    # VERIFICA SE PERMITE REVELAÇÃO MAIOR
    check_for_major_revelations()

func check_for_major_revelations():
    # REVELAÇÕES IMPORTANTES: Quando jogador conecta pontos suficientes
    var major_revelations = [
        {
            "id": "protagonist_nature",
            "required_understanding": 0.3,
            "required_fragments": ["identity_fragment_1", "mirror_shard", "echo_resonance"]
        },
        {
            "id": "civilization_fate",
            "required_understanding": 0.6,
            "required_fragments": ["final_experiment", "rupture_point", "collective_memory"]
        },
        {
            "id": "true_purpose",
            "required_understanding": 0.9,
            "required_fragments": ["origin_core", "sealing_method", "sacrifice_required"]
        }
    ]

    for revelation in major_revelations:
        if can_trigger_revelation(revelation):
            trigger_major_revelation(revelation)

func trigger_major_revelation(revelation: Dictionary):
    # MOMENTO DRAMÁTICO: Verdade importante revelada
    major_revelation.emit(revelation.id)

    # EFEITO VISUAL DRAMÁTICO
    EffectManager.play_revelation_effect(revelation.visual_style)

    # ATUALIZA TIER DE PROGRESSÃO
    story_progression_tier += 1

    # MUDA COMPORTAMENTO DO MUNDO
    AbyssWorldManager.set_narrative_tier(story_progression_tier)
```

### LoreDatabase.gd (Biblioteca dos Segredos)

#### Base de Dados Narrativa Estruturada
```gdscript
class_name LoreDatabase
extends Resource

# ESTRUTURA NARRATIVA: Organização hierárquica dos segredos
var narrative_structure = {
    "act_1_mystery": {
        "theme": "Quem sou eu? O que é este lugar?",
        "fragments": [
            {
                "id": "first_awakening",
                "content": "Acordo num lugar que não reconheço, mas parece familiar...",
                "discovery_context": "room_entry_first_time",
                "emotional_impact": "confusion"
            },
            {
                "id": "echo_recognition",
                "content": "Essas cartas... não são cartas. São memórias cristalizadas.",
                "discovery_context": "first_card_usage",
                "emotional_impact": "realization"
            }
        ]
    },
    "act_2_history": {
        "theme": "O que aconteceu aqui? Quem criou isto?",
        "fragments": [
            {
                "id": "civilization_glory",
                "content": "Eram conhecidos como os Arquivistas. Guardavam toda memória da humanidade.",
                "discovery_context": "library_exploration",
                "emotional_impact": "wonder"
            },
            {
                "id": "experiment_ambition",
                "content": "Queriam preservar não apenas fatos, mas a essência da experiência humana.",
                "discovery_context": "corruption_medium",
                "emotional_impact": "admiration"
            },
            {
                "id": "hubris_revelation",
                "content": "Acreditavam que poderiam conter o infinito numa esfera finita.",
                "discovery_context": "pattern_recognition",
                "emotional_impact": "foreboding"
            }
        ]
    },
    "act_3_tragedy": {
        "theme": "O que deu errado? Como tudo se corrompeu?",
        "fragments": [
            {
                "id": "memory_overflow",
                "content": "As memórias começaram a se misturar, a se contaminar mutuamente.",
                "discovery_context": "corruption_high",
                "emotional_impact": "horror"
            },
            {
                "id": "reality_breach",
                "content": "A fronteira entre lembrança e realidade se dissolveu completamente.",
                "discovery_context": "reality_distortion_experienced",
                "emotional_impact": "terror"
            }
        ]
    },
    "act_4_truth": {
        "theme": "Qual é meu papel? Por que estou aqui?",
        "fragments": [
            {
                "id": "protagonist_identity",
                "content": "Você não é um explorador. Você é o último Arquivista.",
                "discovery_context": "major_revelation_triggered",
                "emotional_impact": "shock"
            },
            {
                "id": "mission_purpose",
                "content": "Seu propósito não é escapar. É selar o Abismo para sempre.",
                "discovery_context": "understanding_complete",
                "emotional_impact": "acceptance"
            }
        ]
    }
}

# CONEXÕES NARRATIVAS: Como fragmentos se relacionam
var narrative_connections = {
    "echo_recognition + civilization_glory": {
        "revelation": "Os Ecos são restos da tentativa de preservar memórias",
        "understanding_boost": 0.15
    },
    "experiment_ambition + memory_overflow": {
        "revelation": "A ambição dos Arquivistas causou a catástrofe",
        "understanding_boost": 0.2
    },
    "protagonist_identity + mission_purpose": {
        "revelation": "Você é tanto a causa quanto a possível solução",
        "understanding_boost": 0.3
    }
}

func get_fragment_by_id(fragment_id: String) -> Dictionary:
    # BUSCA FRAGMENTO EM TODA A ESTRUTURA
    for act in narrative_structure.values():
        for fragment in act.fragments:
            if fragment.id == fragment_id:
                return fragment
    return {}

func get_fragments_for_context(context: String, corruption_level: float) -> Array[String]:
    # FILTRA FRAGMENTOS APROPRIADOS PARA O CONTEXTO
    var appropriate_fragments: Array[String] = []

    for act in narrative_structure.values():
        for fragment in act.fragments:
            if fragment.discovery_context == context:
                # VERIFICA NÍVEL DE CORRUPÇÃO NECESSÁRIO
                if meets_corruption_requirement(fragment, corruption_level):
                    appropriate_fragments.append(fragment.id)

    return appropriate_fragments
```

### NarrativeUIManager.gd (Apresentador de Segredos)

#### Sistema que Apresenta Lore de Forma Dramática
```gdscript
class_name NarrativeUIManager
extends Control

# ELEMENTOS DE UI NARRATIVA
@onready var lore_popup = $LoreDiscoveryPopup
@onready var connection_visualizer = $ConnectionVisualizer
@onready var revelation_overlay = $RevelationOverlay

func show_lore_discovery(fragment: Dictionary):
    # MOMENTO DRAMÁTICO: Descoberta de novo fragmento
    lore_popup.setup_fragment_display(fragment)

    # EFEITO VISUAL BASEADO NO IMPACTO EMOCIONAL
    var effect_style = get_effect_for_emotion(fragment.emotional_impact)
    play_discovery_effect(effect_style)

    # ÁUDIO APROPRIADO
    AudioManager.play_lore_discovery_sfx(fragment.emotional_impact)

    # EXIBE COM TIMING DRAMÁTICO
    lore_popup.show_with_fade_in()

func show_narrative_connection(connection: Dictionary):
    # VISUALIZAÇÃO DE CONEXÃO: Mostra como fragmentos se relacionam
    connection_visualizer.setup_connection_display(connection)
    connection_visualizer.animate_connection_reveal()

    # SOM DE INSIGHT
    AudioManager.play_connection_revealed_sfx()

func play_major_revelation(revelation_id: String):
    # MOMENTO CLIMÁTICO: Revelação importante
    revelation_overlay.setup_revelation(revelation_id)

    # EFEITO VISUAL DRAMÁTICO
    EffectManager.screen_flash(Color.WHITE, 0.5)
    EffectManager.slow_motion_effect(2.0, 3.0)

    # MÚSICA ÉPICA
    AudioManager.play_revelation_music(revelation_id)

    # ANIMAÇÃO ESPECIAL
    revelation_overlay.play_revelation_sequence()

func get_effect_for_emotion(emotion: String) -> String:
    # EFEITOS VISUAIS BASEADOS NA EMOÇÃO
    match emotion:
        "confusion":
            return "subtle_glow"
        "realization":
            return "bright_flash"
        "wonder":
            return "golden_shimmer"
        "horror":
            return "red_distortion"
        "shock":
            return "screen_shake"
        _:
            return "default_glow"
```

### NarrativeIntegration.gd (Conectador de Sistemas)

#### Sistema que Integra Lore com Gameplay
```gdscript
class_name NarrativeIntegration
extends Node

# INTEGRAÇÃO NARRATIVA: Como lore afeta gameplay
func _ready():
    # CONEXÕES COM OUTROS SISTEMAS
    NarrativeDiscoverySystem.major_revelation.connect(_on_major_revelation)
    GameManager.player_resources.corrupcao_changed.connect(_on_corruption_changed)

func _on_major_revelation(revelation_id: String):
    # REVELAÇÕES MUDAM O GAMEPLAY
    match revelation_id:
        "protagonist_nature":
            # Jogador descobre sua natureza
            unlock_memory_cards()
            change_ui_theme_to_archival()

        "civilization_fate":
            # Entende o que aconteceu
            unlock_historical_environments()
            add_corruption_resistance_mechanic()

        "true_purpose":
            # Compreende sua missão
            unlock_sealing_abilities()
            add_sacrifice_mechanics()

func unlock_memory_cards():
    # NOVAS CARTAS: Baseadas na revelação
    var memory_cards = [
        "forgotten_knowledge",
        "archival_access",
        "memory_reconstruction"
    ]

    for card_id in memory_cards:
        DeckManager.unlock_card(card_id)

    UIManager.show_new_cards_unlocked(memory_cards)

func change_ui_theme_to_archival():
    # MUDANÇA VISUAL: Interface reflete descoberta
    UIManager.transition_to_theme("archival_memories")

func add_corruption_resistance_mechanic():
    # NOVA MECÂNICA: Baseada no entendimento
    GameManager.player_resources.add_corruption_insight_resistance()

func integrate_lore_with_environment(fragment_id: String):
    # AMBIENTES REAGEM À DESCOBERTA
    var fragment = LoreDatabase.get_fragment_by_id(fragment_id)

    if fragment.affects_world_generation:
        AbyssWorldManager.add_narrative_influence(fragment_id)

    if fragment.unlocks_new_rooms:
        WorldGenerator.unlock_room_types(fragment.new_room_types)
```