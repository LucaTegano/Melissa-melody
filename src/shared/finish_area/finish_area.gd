extends Area2D
## Area di fine livello.

@export_file("*.tscn") var next_level_path: String

func _ready() -> void:
    body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
    if body is Player:
        _finish_level()

func _finish_level() -> void:
    print("Livello Completato!")
    if next_level_path != "":
        get_tree().change_scene_to_file(next_level_path)
    else:
        # Torna al menu principale se non c'è un prossimo livello
        get_tree().change_scene_to_file("res://src/ui/main_menu/main_menu.tscn")
