extends Control
class_name MainMenu
## Schermata dei titoli del gioco.

# === Export ===
@export_file("*.tscn") var first_level_path: String = "res://src/levels/test_level.tscn"

# === Node References ===
@onready var btn_new_game: Button = $VBoxContainer/BtnNewGame
@onready var btn_load_game: Button = $VBoxContainer/BtnLoadGame

# === lifecycle ===

func _ready() -> void:
    btn_new_game.pressed.connect(_on_new_game_pressed)
    btn_load_game.pressed.connect(_on_load_game_pressed)

# === Private Methods ===

func _on_new_game_pressed() -> void:
    print("Inizio nuova partita...")
    var error := get_tree().change_scene_to_file(first_level_path)
    if error != OK:
        printerr("Errore nel caricamento della scena: ", error)

func _on_load_game_pressed() -> void:
    print("Caricamento salvataggio...")
    GameManager.load_game()
