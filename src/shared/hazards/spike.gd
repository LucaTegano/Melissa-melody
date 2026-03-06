class_name Spike
extends Area2D
## Environmental hazard that damages the player on contact.

@export var damage: int = 1

func _ready() -> void:
    body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
    if body is Player:
        body.take_damage(damage, global_position)
