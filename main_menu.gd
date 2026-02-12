extends Control

func _ready():

	$VBoxContainer/BtnNewGame.pressed.connect(_on_new_game_pressed)
	$VBoxContainer/BtnLoadGame.pressed.connect(_on_load_game_pressed)

func _on_new_game_pressed():
	print("Inizio nuova partita...")

	get_tree().change_scene_to_file("res://scenes/test_level.tscn") 

func _on_load_game_pressed():
	print("Caricamento salvataggio...")
	
	GameManager.load_game()
