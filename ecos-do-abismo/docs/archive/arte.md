# 🎨 Arte e Impacto Visual

## 🎮 EXPERIÊNCIA DO JOGADOR

### A Sensação da Corrupção Visual Progressiva
**"O mundo fica mais sinistro conforme minha mente se fragmenta"**

O jogador **vê sua sanidade** refletida no estilo visual:
- **0% Corrupção:** "Que lugar sombrio mas belo"
- **25% Corrupção:** "As cores estão... diferentes?"
- **50% Corrupção:** "Algo está errado com minha visão"
- **75% Corrupção:** "Nada faz mais sentido visualmente"
- **100% Corrupção:** "Realidade completamente distorcida"

### Momentos Visuais Críticos

#### PRIMEIRA IMPRESSÃO (fascinação sombria)
**Sentimento:** Admiração por beleza tenebrosa
- **VÊ:** Arte elegante, paleta coesa, detalhes intrincados
- **SENTE:** "Que estilo artístico impressionante"
- **APRECIA:** Qualidade visual e atmosfera misteriosa
- **ENGAJA:** Quer explorar e ver mais

#### SUTIS DISTORÇÕES (inquietação)
**Sentimento:** Algo não está certo
- **PERCEBE:** Pequenas inconsistências visuais
- **QUESTIONA:** "Esta parede estava torta antes?"
- **DUVIDA:** Da própria percepção
- **DESCONFORTA:** Realidade não é estável

#### FRAGMENTAÇÃO VISUAL (paranoia)
**Sentimento:** Perda de controle perceptual
- **VÊ:** Elementos duplicados, cores sangrentas
- **CONFUNDE:** Realidade com alucinação
- **TEME:** Própria sanidade mental
- **ACEITA:** Novo estado de realidade

#### CAOS TOTAL (aceitação)
**Sentimento:** Submissão ao surrealismo
- **EXPERIMENTA:** Impossibilidades visuais
- **NAVEGA:** Realidade completamente alterada
- **ENTENDE:** Arte como linguagem da loucura
- **APRECIA:** Beleza no caos

### A Psicologia das Escolhas Visuais

#### IMPACTOS EMOCIONAIS ESPECÍFICOS

**PALETA DE CORRUPÇÃO**
- **Azul-Acinzentado:** Melancolia, memórias distantes
- **Roxo Profundo:** Mistério, poderes ocultos
- **Vermelho Sangue:** Violência, corrupção ativa
- **Dourado Pálido:** Esperança falsa, glória perdida

**EVOLUÇÃO DA TEXTURA**
- **Pedra Polida:** Civilização refinada
- **Metal Corroído:** Decadência temporal
- **Carne Pulsante:** Corrupção orgânica
- **Geometria Impossível:** Realidade quebrada

**ILUMINAÇÃO PSICOLÓGICA**
- **Luz Suave:** Segurança ilusória
- **Sombras Dramáticas:** Tensão crescente
- **Pulsos Vermelhos:** Corrupção ativa
- **Luz Fragmentada:** Sanidade perdida

## 🔗 INTEGRAÇÃO COM OUTRAS FEATURES

### Arte ↔ Corruption Progression
- **recursos.md:** Cada nível de Corrupção altera o estilo visual
- **0-25%:** Paleta original, pequenas aberrações
- **50-75%:** Distorções graduais, cores se contaminam
- **80-100%:** Estilo completamente alterado, surrealismo total

### Arte ↔ Environmental Storytelling
- **mundo.md:** Cada ambiente tem identidade visual única
- **lore.md:** Arte revela pistas narrativas através de simbolismo
- **Bibliotecas:** Arte acadêmica deteriorada
- **Campos de Batalha:** Épico heroico corrompido
- **Jardins:** Natureza bela que se torna predatória

### Arte ↔ Card Design Philosophy
- **cartas.md:** Cada carta tem arte que reflete sua natureza dupla
- **Eco Fraco:** Arte limpa, tradicional, reconfortante
- **Eco Forte:** Mesma cena mas distorcida, ameaçadora
- **Corrupção do jogador:** Cartas visualmente "sangram"

### Arte ↔ Interface Harmony
- **interface.md:** UI se adapta aos temas visuais atuais
- **Frames das cartas:** Mudam baseado na corrupção
- **Barras de recursos:** Degradam visualmente
- **Menus:** Refletem estado psicológico atual

## ⚙️ ARQUITETURA QUE SUPORTA A EXPERIÊNCIA

### VisualCorruptionManager.gd (Distorção Progressiva)

#### Sistema que Controla Evolução Visual
```gdscript
class_name VisualCorruptionManager
extends Node

# TIERS DE CORRUPÇÃO VISUAL: Cada nível tem identidade própria
enum CorruptionTier {
    PRISTINE,      # 0-25%: Beleza sombria original
    TAINTED,       # 25-50%: Sutis distorções
    CORRUPTED,     # 50-75%: Fragmentação visível
    NIGHTMARE      # 75-100%: Realidade impossível
}

var current_tier: CorruptionTier = CorruptionTier.PRISTINE
var corruption_intensity: float = 0.0

# SHADERS PROGRESSIVOS: Cada tier tem seus próprios efeitos
@onready var pristine_shader = preload("res://shaders/pristine_beauty.gdshader")
@onready var tainted_shader = preload("res://shaders/subtle_distortion.gdshader")
@onready var corrupted_shader = preload("res://shaders/fragmentation.gdshader")
@onready var nightmare_shader = preload("res://shaders/impossible_reality.gdshader")

signal corruption_tier_changed(new_tier: CorruptionTier)
signal visual_style_evolved(evolution_type: String)

func _ready():
    # CONECTA COM SISTEMA DE CORRUPÇÃO
    GameManager.player_resources.corrupcao_changed.connect(_on_corruption_changed)

func _on_corruption_changed(corruption_value: float, percentage: float):
    corruption_intensity = percentage

    # DETERMINA TIER VISUAL
    var new_tier = calculate_corruption_tier(percentage)

    if new_tier != current_tier:
        transition_to_corruption_tier(new_tier)

func calculate_corruption_tier(percentage: float) -> CorruptionTier:
    match percentage:
        var x when x < 0.25:
            return CorruptionTier.PRISTINE
        var x when x < 0.5:
            return CorruptionTier.TAINTED
        var x when x < 0.75:
            return CorruptionTier.CORRUPTED
        _:
            return CorruptionTier.NIGHTMARE

func transition_to_corruption_tier(new_tier: CorruptionTier):
    # TRANSIÇÃO VISUAL DRAMÁTICA
    var old_tier = current_tier
    current_tier = new_tier

    # FEEDBACK VISUAL DA MUDANÇA
    EffectManager.play_corruption_tier_transition(old_tier, new_tier)

    # ATUALIZA TODOS OS ELEMENTOS VISUAIS
    update_all_visual_elements()

    corruption_tier_changed.emit(new_tier)

func update_all_visual_elements():
    # APLICA SHADER APROPRIADO
    apply_global_corruption_shader()

    # ATUALIZA MATERIAIS DE AMBIENTE
    update_environment_materials()

    # MODIFICA ARTE DAS CARTAS
    update_card_visual_corruption()

    # ADAPTA INTERFACE
    update_ui_corruption_theme()

func apply_global_corruption_shader():
    var screen_material = get_viewport().get_screen_material()

    match current_tier:
        CorruptionTier.PRISTINE:
            # Sem filtro global, beleza natural
            get_viewport().set_screen_material(null)

        CorruptionTier.TAINTED:
            # Sutis distorções de cor
            screen_material = ShaderMaterial.new()
            screen_material.shader = tainted_shader
            screen_material.set_shader_parameter("distortion_strength", corruption_intensity)

        CorruptionTier.CORRUPTED:
            # Fragmentação visível
            screen_material = ShaderMaterial.new()
            screen_material.shader = corrupted_shader
            screen_material.set_shader_parameter("fragment_intensity", corruption_intensity)

        CorruptionTier.NIGHTMARE:
            # Realidade impossível
            screen_material = ShaderMaterial.new()
            screen_material.shader = nightmare_shader
            screen_material.set_shader_parameter("reality_distortion", corruption_intensity)

    if screen_material:
        get_viewport().set_screen_material(screen_material)

func update_card_visual_corruption():
    # CARTAS REFLETEM CORRUPÇÃO DO JOGADOR
    var cards = get_tree().get_nodes_in_group("displayed_cards")

    for card in cards:
        apply_card_corruption_effects(card)

func apply_card_corruption_effects(card: Control):
    match current_tier:
        CorruptionTier.PRISTINE:
            # Arte original limpa
            card.modulate = Color.WHITE

        CorruptionTier.TAINTED:
            # Bordas começam a "sangrar"
            add_card_bleeding_effect(card, 0.2)

        CorruptionTier.CORRUPTED:
            # Arte duplica e se fragmenta
            add_card_fragmentation_effect(card, 0.5)

        CorruptionTier.NIGHTMARE:
            # Cartas se tornam pesadelos visuais
            add_card_nightmare_effect(card, 1.0)
```

### AIArtPipeline.gd (Geração Procedural de Arte)

#### Sistema que Gera Arte Consistente com IA
```gdscript
class_name AIArtPipeline
extends Node

# PROMPTS BASE: Fundação do estilo visual
var base_style_prompt = "dark fantasy, gothic architecture, ethereal lighting, muted colors, detailed textures, oil painting style, dramatic shadows"

var corruption_style_modifiers = {
    CorruptionTier.PRISTINE: "",
    CorruptionTier.TAINTED: "subtle wrongness, slight color bleeding, minor geometric distortions",
    CorruptionTier.CORRUPTED: "fragmented reality, overlapping elements, impossible architecture, bleeding colors",
    CorruptionTier.NIGHTMARE: "surreal nightmare, melting forms, impossible geometry, reality breaking apart"
}

# PALETAS POR TIER: Cores específicas para cada nível
var tier_color_palettes = {
    CorruptionTier.PRISTINE: {
        "primary": ["#2C3E50", "#8E44AD", "#34495E"],      # Azul-acinzentado, roxo, cinza
        "secondary": ["#F39C12", "#E8D5B7", "#A0A4A8"],   # Dourado, bege, prata
        "accent": ["#E74C3C", "#C0392B"]                   # Vermelhos para pontos focais
    },
    CorruptionTier.TAINTED: {
        "primary": ["#2C3E50", "#8E44AD", "#5D4E75"],      # Cores base com contaminação
        "secondary": ["#D68910", "#D5B895", "#8C8C8C"],   # Dourados desbotados
        "accent": ["#E74C3C", "#A93226", "#884EA0"]        # Vermelhos e roxos
    },
    CorruptionTier.CORRUPTED: {
        "primary": ["#1B2631", "#6C3483", "#4A235A"],      # Cores escurecidas
        "secondary": ["#B7950B", "#AF9B5A", "#717D7E"],   # Metais corroídos
        "accent": ["#C0392B", "#922B21", "#7D3C98"]        # Vermelhos sangue
    },
    CorruptionTier.NIGHTMARE: {
        "primary": ["#0E1821", "#4A148C", "#311B92"],      # Quase preto, roxos profundos
        "secondary": ["#8E6509", "#7E5109", "#5D6D7E"],   # Dourados pútridos
        "accent": ["#B71C1C", "#7B1FA2", "#4A148C"]        # Vermelhos e roxos intensos
    }
}

func generate_card_art(card_concept: String, corruption_tier: CorruptionTier) -> Texture2D:
    # CONSTRÓI PROMPT COMPLETO
    var full_prompt = build_art_prompt(card_concept, corruption_tier)

    # GERA ARTE COM IA
    var art_data = await call_sdxl_api(full_prompt)

    # PÓS-PROCESSAMENTO
    var processed_art = apply_post_processing(art_data, corruption_tier)

    return processed_art

func build_art_prompt(concept: String, tier: CorruptionTier) -> String:
    var prompt = base_style_prompt + ", " + concept

    # ADICIONA MODIFICADORES DE CORRUPÇÃO
    if corruption_style_modifiers.has(tier):
        prompt += ", " + corruption_style_modifiers[tier]

    # ESPECIFICA PALETA DE CORES
    var palette = tier_color_palettes[tier]
    prompt += ", color palette: " + str(palette.primary) + " " + str(palette.secondary)

    return prompt

func apply_post_processing(raw_art: ImageTexture, tier: CorruptionTier) -> Texture2D:
    # PÓS-PROCESSAMENTO BASEADO NO TIER
    var image = raw_art.get_image()

    match tier:
        CorruptionTier.PRISTINE:
            # Apenas ajustes sutis de contraste
            apply_contrast_boost(image, 1.1)

        CorruptionTier.TAINTED:
            # Adiciona ruído sutil
            apply_corruption_noise(image, 0.1)
            apply_color_bleeding(image, 0.2)

        CorruptionTier.CORRUPTED:
            # Fragmentação e distorção
            apply_fragmentation_effect(image, 0.3)
            apply_color_shift(image, 0.4)

        CorruptionTier.NIGHTMARE:
            # Distorção extrema
            apply_nightmare_distortion(image, 0.6)
            apply_reality_tear_effects(image, 0.5)

    var processed_texture = ImageTexture.new()
    processed_texture.set_image(image)
    return processed_texture
```

### EnvironmentArtManager.gd (Arte Ambiental Procedural)

#### Sistema que Cria Consistência Visual nos Ambientes
```gdscript
class_name EnvironmentArtManager
extends Node

# TEMAS VISUAIS POR AMBIENTE
var environment_themes = {
    "memory_library": {
        "base_style": "ancient library, towering bookshelves, floating tomes, ethereal light",
        "corruption_variants": {
            CorruptionTier.PRISTINE: "serene scholarly atmosphere",
            CorruptionTier.TAINTED: "books bleeding ink, words crawling off pages",
            CorruptionTier.CORRUPTED: "shelves warping, reality written and rewritten",
            CorruptionTier.NIGHTMARE: "library of screaming knowledge, sentient books"
        }
    },
    "battle_echo": {
        "base_style": "ancient battlefield, spectral warriors, floating weapons, war banners",
        "corruption_variants": {
            CorruptionTier.PRISTINE: "noble conflict, heroic poses",
            CorruptionTier.TAINTED: "glory tarnished, weapons rusted",
            CorruptionTier.CORRUPTED: "eternal slaughter, bodies never falling",
            CorruptionTier.NIGHTMARE: "war without meaning, soldiers as meat"
        }
    },
    "nature_twisted": {
        "base_style": "overgrown garden, impossible plants, bioluminescent flowers",
        "corruption_variants": {
            CorruptionTier.PRISTINE: "beautiful but alien nature",
            CorruptionTier.TAINTED: "plants with teeth, predatory beauty",
            CorruptionTier.CORRUPTED: "flesh-gardens, organic machinery",
            CorruptionTier.NIGHTMARE: "nature as cancer, life consuming itself"
        }
    }
}

func setup_environment_visuals(room_type: String, corruption_tier: CorruptionTier):
    # SELECIONA TEMA APROPRIADO
    var theme = environment_themes.get(room_type, environment_themes["memory_library"])

    # GERA ELEMENTOS VISUAIS
    generate_environment_backgrounds(theme, corruption_tier)
    place_atmospheric_elements(theme, corruption_tier)
    setup_dynamic_lighting(corruption_tier)

func generate_environment_backgrounds(theme: Dictionary, tier: CorruptionTier):
    # BACKGROUND PRINCIPAL
    var base_prompt = theme.base_style + ", " + theme.corruption_variants[tier]
    var background_art = await AIArtPipeline.generate_environment_art(base_prompt, tier)

    # LAYERS ADICIONAIS PARA PROFUNDIDADE
    generate_background_layers(theme, tier)

func place_atmospheric_elements(theme: Dictionary, tier: CorruptionTier):
    # PARTÍCULAS AMBIENTAIS
    var particle_system = create_corruption_particles(tier)
    CurrentRoom.add_child(particle_system)

    # OBJETOS DECORATIVOS
    place_thematic_decorations(theme, tier)

    # EFEITOS DE DISTORÇÃO
    if tier >= CorruptionTier.CORRUPTED:
        add_reality_distortion_effects()

func setup_dynamic_lighting(tier: CorruptionTier):
    # ILUMINAÇÃO BASEADA NO TIER
    var lighting_config = get_lighting_for_tier(tier)

    # APLICA CONFIGURAÇÃO
    RenderingServer.environment_set_ambient_light(
        get_viewport().get_world_3d().environment,
        lighting_config.ambient_color,
        lighting_config.ambient_intensity
    )

    # LUZES DINÂMICAS
    create_atmospheric_lights(lighting_config)

func get_lighting_for_tier(tier: CorruptionTier) -> Dictionary:
    match tier:
        CorruptionTier.PRISTINE:
            return {
                "ambient_color": Color(0.4, 0.4, 0.5, 1.0),     # Azul suave
                "ambient_intensity": 0.3,
                "dynamic_lights": "soft_mystical"
            }
        CorruptionTier.TAINTED:
            return {
                "ambient_color": Color(0.5, 0.35, 0.4, 1.0),    # Ligeiramente avermelhado
                "ambient_intensity": 0.25,
                "dynamic_lights": "flickering_unstable"
            }
        CorruptionTier.CORRUPTED:
            return {
                "ambient_color": Color(0.6, 0.2, 0.3, 1.0),     # Vermelho sombrio
                "ambient_intensity": 0.2,
                "dynamic_lights": "pulsing_bloody"
            }
        CorruptionTier.NIGHTMARE:
            return {
                "ambient_color": Color(0.7, 0.1, 0.2, 1.0),     # Vermelho profundo
                "ambient_intensity": 0.15,
                "dynamic_lights": "chaotic_impossible"
            }
        _:
            return get_lighting_for_tier(CorruptionTier.PRISTINE)
```

### ArtConsistencyValidator.gd (Garantia de Qualidade Visual)

#### Sistema que Mantém Coerência Artística
```gdscript
class_name ArtConsistencyValidator
extends Node

# MÉTRICAS DE CONSISTÊNCIA
var style_consistency_score: float = 1.0
var color_harmony_score: float = 1.0
var corruption_accuracy_score: float = 1.0

func validate_art_consistency(new_art: Texture2D, context: Dictionary) -> bool:
    # ANÁLISE DE ESTILO
    var style_score = analyze_style_consistency(new_art, context.expected_style)

    # ANÁLISE DE PALETA
    var color_score = analyze_color_harmony(new_art, context.corruption_tier)

    # ANÁLISE DE CORRUPÇÃO
    var corruption_score = analyze_corruption_accuracy(new_art, context.corruption_level)

    # DECISÃO FINAL
    var overall_score = (style_score + color_score + corruption_score) / 3.0
    return overall_score >= 0.7  # Threshold de qualidade

func analyze_style_consistency(art: Texture2D, expected_style: String) -> float:
    # ANÁLISE DE CARACTERÍSTICAS VISUAIS
    var image = art.get_image()

    # VERIFICA ELEMENTOS ESTILÍSTICOS
    var has_gothic_elements = detect_gothic_architecture(image)
    var has_proper_lighting = detect_dramatic_lighting(image)
    var has_texture_detail = detect_texture_richness(image)

    # CALCULA SCORE
    var style_elements = [has_gothic_elements, has_proper_lighting, has_texture_detail]
    var consistent_elements = style_elements.filter(func(x): return x).size()

    return float(consistent_elements) / style_elements.size()

func analyze_color_harmony(art: Texture2D, tier: CorruptionTier) -> float:
    var image = art.get_image()
    var expected_palette = VisualCorruptionManager.tier_color_palettes[tier]

    # EXTRAI CORES DOMINANTES
    var dominant_colors = extract_dominant_colors(image, 5)

    # COMPARA COM PALETA ESPERADA
    var harmony_score = calculate_palette_similarity(dominant_colors, expected_palette)

    return harmony_score

func ensure_art_quality_pipeline():
    # PIPELINE DE QUALIDADE PARA ARTE GERADA
    # 1. Geração inicial
    # 2. Validação automática
    # 3. Correção se necessário
    # 4. Validação final
    # 5. Integração ao jogo
    pass
```