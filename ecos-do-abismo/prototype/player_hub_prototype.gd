# Protótipo Mínimo - Hub do Jogador
# Validar navegação e estrutura básica

extends Control

@onready var missions_btn = $HBoxContainer/MissionsPanel/SelectMissionButton
@onready var deck_btn = $HBoxContainer/DeckPanel/ViewDeckButton
@onready var shop_btn = $HBoxContainer/ShopPanel/OpenShopButton
@onready var back_btn = $TopBar/BackButton

@onready var level_label = $TopBar/PlayerInfo/LevelLabel
@onready var hp_bar = $StatusPanel/HPBar
@onready var willpower_bar = $StatusPanel/WillpowerBar

# Dados simulados do jogador
var player_data = {
	"level": 5,
	"hp": 80,
	"max_hp": 100,
	"willpower": 60,
	"max_willpower": 100,
	"xp": 1250,
	"xp_to_next": 2000,
	"coins": 1500
}

func _ready():
	# Conectar botões
	missions_btn.pressed.connect(_on_missions_pressed)
	deck_btn.pressed.connect(_on_deck_pressed)
	shop_btn.pressed.connect(_on_shop_pressed)
	back_btn.pressed.connect(_on_back_pressed)

	# Atualizar UI
	_update_player_info()

func _update_player_info():
	level_label.text = "Nível %d" % player_data.level

	# Atualizar barras de status
	hp_bar.value = float(player_data.hp) / player_data.max_hp * 100
	willpower_bar.value = float(player_data.willpower) / player_data.max_willpower * 100

	print("👤 Player Status:")
	print("   HP: %d/%d" % [player_data.hp, player_data.max_hp])
	print("   Vontade: %d/%d" % [player_data.willpower, player_data.max_willpower])
	print("   XP: %d/%d" % [player_data.xp, player_data.xp_to_next])

func _on_missions_pressed():
	print("🎯 SELECIONANDO MISSÃO")
	# Simular seleção de missão
	print("   Missões disponíveis:")
	print("   1. Ruínas Perdidas (★★☆)")
	print("   2. Câmaras Sombrias (★★★)")

	# Ir direto para combate no protótipo
	get_tree().change_scene_to_file("res://prototype/combat_prototype.tscn")

func _on_deck_pressed():
	print("🃏 VISUALIZANDO DECK")
	# TODO: Abrir deck builder
	print("   Deck atual: 20 cartas")
	print("   Última adição: Ataque Devastador")

func _on_shop_pressed():
	print("🛒 ABRINDO LOJA")
	# TODO: Abrir loja
	print("   Moedas: %d" % player_data.coins)
	print("   Itens disponíveis: 12")

func _on_back_pressed():
	print("◀️ VOLTANDO AO MENU")
	get_tree().change_scene_to_file("res://prototype/main_menu_prototype.tscn")