# Protótipo Mínimo - Menu Principal
# Este é um protótipo para validar o fluxo básico do jogo

extends Control

@onready var new_game_btn = $VBoxContainer/NewGameButton
@onready var continue_btn = $VBoxContainer/ContinueButton
@onready var settings_btn = $VBoxContainer/SettingsButton
@onready var quit_btn = $VBoxContainer/QuitButton

func _ready():
	# Conectar botões
	new_game_btn.pressed.connect(_on_new_game_pressed)
	continue_btn.pressed.connect(_on_continue_pressed)
	settings_btn.pressed.connect(_on_settings_pressed)
	quit_btn.pressed.connect(_on_quit_pressed)

	# Verificar se há save game
	continue_btn.disabled = not _has_save_game()

func _on_new_game_pressed():
	print("🎮 INICIANDO NOVO JOGO")
	get_tree().change_scene_to_file("res://prototype/player_hub_prototype.tscn")

func _on_continue_pressed():
	print("📂 CARREGANDO JOGO")
	# TODO: Carregar save game
	get_tree().change_scene_to_file("res://prototype/player_hub_prototype.tscn")

func _on_settings_pressed():
	print("⚙️ CONFIGURAÇÕES")
	# TODO: Abrir menu de configurações
	pass

func _on_quit_pressed():
	print("🚪 SAINDO DO JOGO")
	get_tree().quit()

func _has_save_game() -> bool:
	# Simular verificação de save game
	return FileAccess.file_exists("user://savegame.dat")