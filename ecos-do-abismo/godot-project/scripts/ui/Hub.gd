# Sprint 8 - Hub com interface melhorada
extends Control

# Nova UI reorganizada
@onready var level_label = $StatusPanel/StatusContainer/PlayerInfo/LevelLabel
@onready var xp_label = $StatusPanel/StatusContainer/XPProgress/XPLabel
@onready var xp_bar = $StatusPanel/StatusContainer/XPProgress/XPBar
@onready var coins_label = $StatusPanel/StatusContainer/PlayerInfo/CoinsLabel

@onready var play_btn = $ActionButtons/PlayButton

@onready var stats_label = $StatsSection/UpgradesPanel/UpgradesContainer/StatsLabel
@onready var progress_label = $StatsSection/ProgressPanel/ProgressContainer/ProgressLabel

func _ready():
	print("🏠 Hub do jogador - Sprint 8: Interface melhorada")

	# Conectar botões
	play_btn.pressed.connect(_on_play_pressed)

	_update_ui()

func _update_ui():
	var stats = GameData.get_player_stats()

	# Status do jogador
	level_label.text = "📈 Nível %d" % stats.level
	xp_label.text = "✨ XP: %d/%d" % [stats.xp, stats.xp_needed]
	coins_label.text = "💰 %d moedas" % stats.coins

	# Barra de XP
	var xp_progress = float(stats.xp) / float(stats.xp_needed) * 100.0
	xp_bar.value = xp_progress

	# Upgrades ativos
	stats_label.text = "❤️ HP Máximo: %d\n⚡ Energia Inicial: %d\n⚔️ Bonus Dano: %d" % [stats.max_hp, stats.starting_energy, stats.damage_bonus]

	# Progresso do jogador
	progress_label.text = "🎯 Vitórias: %d\n🔥 Sequência Atual: %d\n🌟 Melhor Sequência: %d" % [stats.victories, stats.current_streak, stats.best_streak]

	print("📊 Hub atualizado - Nível %d, %d moedas" % [stats.level, stats.coins])

func _on_play_pressed():
	print("🎮 Iniciando nova run...")
	# Iniciar nova run e ir para o mapa
	RunManager.start_new_run()
	get_tree().change_scene_to_file("res://scenes/ui/RunMap.tscn")

