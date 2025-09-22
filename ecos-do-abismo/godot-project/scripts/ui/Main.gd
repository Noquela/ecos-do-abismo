# Sprint 1 - Só um botão que funciona
extends Control

@onready var button = $Button

func _ready():
	print("🎮 SPRINT 1: Menu mínimo funcionando")
	button.pressed.connect(_on_button_pressed)

func _on_button_pressed():
	print("🃏 INDO PARA COMBATE")
	get_tree().change_scene_to_file("res://Combat.tscn")