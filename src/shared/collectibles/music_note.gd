class_name MusicNote
extends Area2D
## Collectible item that increases the player's score.

@export var score_value: int = 1

func _ready() -> void:
    body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
    if body is Player:
        _collect()

func _collect() -> void:
    GameManager.add_score(score_value)
    # Emit global signal if needed, though GameManager.score_changed already handles UI
    queue_free()
