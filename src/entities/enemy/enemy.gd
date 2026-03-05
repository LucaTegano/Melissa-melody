extends CharacterBody2D

@export var speed: float = 60.0
@export var gravity: float = 900.0

var direction = 1 
var knockback = Vector2.ZERO # Variabile per la spinta

@onready var sprite = $AnimatedSprite2D

func _ready():
	if sprite:
		sprite.play("walk")

func _physics_process(delta):
	# 1. Gravità
	if not is_on_floor():
		velocity.y += gravity * delta

	# movimento e knockback
	if knockback != Vector2.ZERO:
		
		velocity = knockback
		
		knockback = knockback.move_toward(Vector2.ZERO, 1200 * delta)
	else:
		# Comportamento normale
		if is_on_wall():
			direction = direction * -1
			if sprite:
				sprite.flip_h = (direction < 0)
		
		velocity.x = direction * speed
	
	move_and_slide()

# prendere danno
func take_damage(source_position: Vector2, force: float):
	print("palla colpita")
	

	
	var dir_x = 1 if global_position.x > source_position.x else -1
	
	
	knockback = Vector2(dir_x * force, 0)
	
	
