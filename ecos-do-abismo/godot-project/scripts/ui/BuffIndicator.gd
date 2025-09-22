# Sprint 16 - Indicador Visual de Buffs
extends Control

@onready var buffs_container = $BuffsContainer

var target_id: String = ""
var displayed_buffs := {}

func _ready():
	_create_buffs_container()

func _create_buffs_container():
	"""Criar container para buffs se não existir"""
	if not buffs_container:
		buffs_container = HBoxContainer.new()
		buffs_container.name = "BuffsContainer"
		add_child(buffs_container)

func set_target(new_target_id: String):
	"""Definir alvo para monitorar buffs"""
	target_id = new_target_id
	refresh_buffs()

func refresh_buffs():
	"""Atualizar display de buffs"""
	if target_id == "":
		return

	var current_buffs = BuffSystem.get_buff_summary(target_id)

	# Remover buffs que não existem mais
	for buff_type in displayed_buffs.keys():
		var found = false
		for buff in current_buffs:
			if buff.type == buff_type:
				found = true
				break

		if not found:
			displayed_buffs[buff_type].queue_free()
			displayed_buffs.erase(buff_type)

	# Atualizar ou criar buffs
	for buff in current_buffs:
		if displayed_buffs.has(buff.type):
			_update_buff_display(buff)
		else:
			_create_buff_display(buff)

func _create_buff_display(buff: Dictionary):
	"""Criar display visual para um buff"""
	var buff_panel = Panel.new()
	buff_panel.custom_minimum_size = Vector2(60, 60)
	buff_panel.tooltip_text = "%s\n%s" % [buff.name, buff.description]

	# Adicionar cor baseada no tipo de buff
	var style = StyleBoxFlat.new()
	style.bg_color = buff.color
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = Color.WHITE if buff.is_positive else Color.BLACK
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	buff_panel.add_theme_stylebox_override("panel", style)

	# Container vertical para ícone e valores
	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	buff_panel.add_child(vbox)

	# Ícone do buff
	var icon_label = Label.new()
	icon_label.text = buff.icon
	icon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	icon_label.add_theme_font_size_override("font_size", 24)
	vbox.add_child(icon_label)

	# Container horizontal para valor e duração
	var hbox = HBoxContainer.new()
	hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(hbox)

	# Valor do buff
	var value_label = Label.new()
	value_label.text = str(buff.value)
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	value_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	value_label.add_theme_font_size_override("font_size", 12)
	value_label.add_theme_color_override("font_color", Color.WHITE)
	hbox.add_child(value_label)

	# Duração (se aplicável)
	if buff.duration > 0:
		var duration_label = Label.new()
		duration_label.text = str(buff.duration)
		duration_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		duration_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		duration_label.add_theme_font_size_override("font_size", 10)
		duration_label.add_theme_color_override("font_color", Color.YELLOW)
		hbox.add_child(duration_label)

	# Armazenar referências para updates
	buff_panel.set_meta("buff_type", buff.type)
	buff_panel.set_meta("icon_label", icon_label)
	buff_panel.set_meta("value_label", value_label)
	buff_panel.set_meta("duration_label", hbox.get_child(1) if hbox.get_child_count() > 1 else null)

	buffs_container.add_child(buff_panel)
	displayed_buffs[buff.type] = buff_panel

func _update_buff_display(buff: Dictionary):
	"""Atualizar display existente de um buff"""
	if not displayed_buffs.has(buff.type):
		return

	var buff_panel = displayed_buffs[buff.type]
	var value_label = buff_panel.get_meta("value_label")
	var duration_label = buff_panel.get_meta("duration_label")

	# Atualizar valor
	value_label.text = str(buff.value)

	# Atualizar duração se existir
	if duration_label and buff.duration > 0:
		duration_label.text = str(buff.duration)
		duration_label.visible = true
	elif duration_label:
		duration_label.visible = false

	# Atualizar tooltip
	buff_panel.tooltip_text = "%s\n%s" % [buff.name, buff.description]

func clear_buffs():
	"""Limpar todos os buffs visuais"""
	for buff_panel in displayed_buffs.values():
		buff_panel.queue_free()
	displayed_buffs.clear()

# Funções de conveniência para diferentes alvos
func set_player_target():
	"""Configurar para mostrar buffs do jogador"""
	set_target("player")

func set_enemy_target(enemy_id: String):
	"""Configurar para mostrar buffs de um inimigo"""
	set_target(enemy_id)

# Auto-refresh opcional (para telas em tempo real)
var auto_refresh_enabled := false
var refresh_timer := 0.0
const REFRESH_INTERVAL := 1.0  # Atualizar a cada segundo

func enable_auto_refresh():
	"""Habilitar atualização automática"""
	auto_refresh_enabled = true

func disable_auto_refresh():
	"""Desabilitar atualização automática"""
	auto_refresh_enabled = false

func _process(delta):
	if auto_refresh_enabled:
		refresh_timer += delta
		if refresh_timer >= REFRESH_INTERVAL:
			refresh_timer = 0.0
			refresh_buffs()