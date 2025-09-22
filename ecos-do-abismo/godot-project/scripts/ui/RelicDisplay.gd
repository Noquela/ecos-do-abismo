# Sprint 12 - Interface de Relíquias Ativas
extends Control

@onready var relics_container = $RelicsPanel/RelicsContainer

var relic_buttons := []

func _ready():
	print("💎 Relic Display - Sprint 12: Interface de relíquias")

	# Atualizar exibição das relíquias
	_update_relics_display()

	# Conectar sinal para atualizar quando relíquias mudarem
	if RunManager.has_signal("relic_added"):
		RunManager.relic_added.connect(_on_relic_added)

func _update_relics_display():
	"""Atualizar exibição das relíquias ativas"""
	# Limpar botões existentes
	for btn in relic_buttons:
		btn.queue_free()
	relic_buttons.clear()

	# Obter relíquias da run atual
	var run_relics = RunManager.get_run_relics()

	# Criar botão para cada relíquia
	for relic in run_relics:
		var btn = Button.new()

		# Configurar botão
		btn.text = "💎"
		btn.custom_minimum_size = Vector2(50, 50)
		btn.tooltip_text = _format_relic_tooltip(relic)

		# Cor baseada no tipo
		btn.modulate = RelicSystem.get_relic_color(relic.type)

		# Conectar sinal para mostrar detalhes
		btn.pressed.connect(_on_relic_pressed.bind(relic))

		relics_container.add_child(btn)
		relic_buttons.append(btn)

	print("💎 Exibindo %d relíquias ativas" % run_relics.size())

func _format_relic_tooltip(relic: Dictionary) -> String:
	"""Formatar tooltip da relíquia"""
	var tooltip = "💎 %s\n" % relic.name
	tooltip += "⭐ %s\n\n" % RelicSystem.get_relic_type_name(relic.type)
	tooltip += relic.description
	return tooltip

func _on_relic_pressed(relic: Dictionary):
	"""Quando clica em uma relíquia"""
	print("💎 Relíquia clicada: %s" % relic.name)

	# Aqui poderia abrir um popup com detalhes da relíquia
	# Por enquanto só mostra no console

func _on_relic_added(relic: Dictionary):
	"""Quando uma nova relíquia é adicionada"""
	print("💎 Nova relíquia detectada: %s" % relic.name)
	_update_relics_display()

func get_total_relics() -> int:
	"""Obter total de relíquias ativas"""
	return RunManager.get_run_relics().size()

func has_relic_type(relic_type: RelicSystem.RelicType) -> bool:
	"""Verificar se tem relíquia de um tipo específico"""
	var run_relics = RunManager.get_run_relics()
	for relic in run_relics:
		if relic.type == relic_type:
			return true
	return false

func get_relic_effect_total(effect_name: String) -> float:
	"""Obter valor total de um efeito das relíquias"""
	var total = 0.0
	var run_relics = RunManager.get_run_relics()

	for relic in run_relics:
		if relic.effect == effect_name:
			total += relic.value

	return total