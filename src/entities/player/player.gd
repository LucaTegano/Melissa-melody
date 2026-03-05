extends CharacterBody2D

#fisica player
@export var run_speed: float = 200.0
@export var gravity: float = 1000.0
@export var jump_force: float = -350.0
@export_range(0.0, 1.0) var jump_cut: float = 0.25

#combat
@export var dash_speed: float = 500.0
@export var dash_duration: float = 0.275
@export var dash_cooldown: float = 0.5
@export var attack_cooldown: float = 0.1

# game feel
@export var hit_recoil: float = 450.0  
@export var enemy_knockback: float = 300.0 
@export var hit_freeze_time: float = 0.05 # Tempo di stop 

#variabili di stato
var is_dashing: bool = false
var dash_timer: float = 0.0
var dash_cooldown_timer: float = 0.0
var dash_direction: int = 1
var can_dash: bool = true 
var is_attacking: bool = false
var attack_cooldown_timer: float = 0.0


@onready var sprite = $AnimatedSprite2D
@onready var weapon_area = $weaponarea 

func _ready():
	sprite.animation_finished.connect(_on_animation_finished)
	weapon_area.monitoring = false
	
	if GameManager.player_position != Vector2.ZERO:
		global_position = GameManager.player_position
		
		GameManager.player_position = Vector2.ZERO

func _physics_process(delta):
	var direction = Input.get_axis("move_left", "move_right")

	# Timer
	if dash_cooldown_timer > 0: dash_cooldown_timer -= delta
	if attack_cooldown_timer > 0: attack_cooldown_timer -= delta
	if is_on_floor(): can_dash = true

	# LOGICA
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0: is_dashing = false
		else:
			velocity.x = dash_direction * dash_speed
			velocity.y = 0
	else:
		if not is_on_floor(): velocity.y += gravity * delta

		if is_on_floor() and Input.is_action_just_pressed("jump"):
			velocity.y = jump_force
		if Input.is_action_just_released("jump") and velocity.y < 0:
			velocity.y *= jump_cut 

		if direction != 0:
		
			velocity.x = direction * run_speed
			
			if not is_attacking:
				sprite.flip_h = direction < 0 
				if direction < 0: weapon_area.scale.x = -1
				else: weapon_area.scale.x = 1
			dash_direction = direction 
		else:
			# Frenata normale
			velocity.x = move_toward(velocity.x, 0, run_speed)
			
		if Input.is_action_just_pressed("dash") and can_dash and dash_cooldown_timer <= 0: start_dash()
		if Input.is_action_just_pressed("attack") and not is_attacking and attack_cooldown_timer <= 0: start_attack()

	# Animazioni
	if is_dashing: sprite.play("dash")
	elif is_attacking: sprite.play("attack")
	elif not is_on_floor(): 
		if sprite.animation != "jump": sprite.play("jump")
	else:
		if direction != 0: sprite.play("run")
		else: sprite.play("idle")

	move_and_slide()

#azioni
func start_dash():
	is_dashing = true
	can_dash = false 
	is_attacking = false 
	weapon_area.monitoring = false 
	dash_timer = dash_duration
	dash_cooldown_timer = dash_cooldown
	velocity.y = 0

func start_attack():
	is_attacking = true
	attack_cooldown_timer = attack_cooldown
	sprite.play("attack")
	weapon_area.monitoring = true

func _on_animation_finished():
	if sprite.animation == "attack":
		is_attacking = false
		weapon_area.monitoring = false

#colpire
func _on_weaponarea_body_entered(body):
	if body.is_in_group("enemies"):
		print("nemico colpito")
		
		# freeze dello schermo
		hit_freeze()
		
		#knockback di mel
		var recoil_dir = 1 if sprite.flip_h else -1
		velocity.x = recoil_dir * hit_recoil
		
		# KNOCKBACK NEMICO
		if body.has_method("take_damage"):
			body.take_damage(global_position, enemy_knockback)

# Funzione per bloccare il tempo
func hit_freeze():
	Engine.time_scale = 0.05
	await get_tree().create_timer(hit_freeze_time, true, false, true).timeout
	Engine.time_scale = 1.0
