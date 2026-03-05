extends CharacterBody2D
class_name Enemy
## Nemico base che pattuglia tra i muri e subisce knockback.

# === Segnali ===
signal damaged(amount: float)

# === Export: Movimento ===
@export_group("Movimento")
@export var speed: float = 60.0
@export var gravity: float = 900.0
@export var knockback_friction: float = 1200.0

# === Variabili di Stato ===
var direction: int = 1 
var knockback: Vector2 = Vector2.ZERO # Variabile per la spinta del knockback

# === Node References ===
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

# === lifecycle ===

func _ready() -> void:
    add_to_group("enemies")
    if sprite:
        sprite.play("walk")

func _physics_process(delta: float) -> void:
    # 1. Gravità
    _apply_gravity(delta)
    # Movimento e Knockback
    _handle_movement(delta)
    move_and_slide()

# === Public Methods ===

# Prendere Danno
## Applica danno e knockback al nemico.
func take_damage(source_position: Vector2, force: float) -> void:
    print("Nemico colpito!")
    var dir_x := 1 if global_position.x > source_position.x else -1
    knockback = Vector2(dir_x * force, 0)
    damaged.emit(force)

# === Private Methods ===

func _apply_gravity(delta: float) -> void:
    if not is_on_floor():
        velocity.y += gravity * delta

func _handle_movement(delta: float) -> void:
    # Movimento guidato dal Knockback
    if knockback != Vector2.ZERO:
        velocity = knockback
        knockback = knockback.move_toward(Vector2.ZERO, knockback_friction * delta)
    else:
        # Comportamento normale (Pattugliamento)
        if is_on_wall():
            direction *= -1
            if sprite:
                sprite.flip_h = (direction < 0)
        
        velocity.x = direction * speed
