extends CharacterBody2D
class_name Player
## Main character controller for Mel.
##
## Handles 2D platformer movement, combat actions, and health integration.
## Uses EventBus for global communication and HealthComponent for vitals.

# === Signals ===
# Signal specific to this instance (e.g., for local visual effects)
signal state_changed(new_state: State)

# === Enums ===
enum State { IDLE, RUNNING, JUMPING, FALLING, DASHING, ATTACKING }

# === Exports ===

@export_group("Movement")
## Base movement speed in pixels per second.
@export var run_speed: float = 200.0
## Downward acceleration.
@export var gravity: float = 1000.0
## Force applied when jumping (negative is up).
@export var jump_force: float = -350.0
## Multiplier applied to Y velocity when jump button is released early.
@export_range(0.0, 1.0) var jump_cut: float = 0.25

@export_group("Combat")
## Speed during dash maneuver.
@export var dash_speed: float = 500.0
## Duration of the dash in seconds.
@export var dash_duration: float = 0.275
## Time between dashes.
@export var dash_cooldown: float = 0.5
## Time between attacks.
@export var attack_cooldown: float = 0.1

@export_group("Game Feel")
## Recoil distance when hitting or getting hit.
@export var hit_recoil: float = 450.0  
## Visual freeze duration on impact.
@export var hit_freeze_time: float = 0.05

# === Properties ===
var current_state: State = State.IDLE:
    set(v):
        if current_state != v:
            current_state = v
            state_changed.emit(current_state)

var is_attacking: bool = false
var is_dashing: bool = false
var can_dash: bool = true
var is_dead: bool = false
var dash_direction: int = 1

# === Private Variables ===
var _dash_timer: float = 0.0
var _dash_cooldown_timer: float = 0.0
var _attack_cooldown_timer: float = 0.0

# === Node References ===
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var weapon_area: Area2D = $weaponarea
@onready var health_component: HealthComponent = $HealthComponent
@onready var camera: Camera2D = $Camera2D

# === Lifecycle ===

func _ready() -> void:
    # Essential setups
    add_to_group("player")
    _setup_signals()
    _init_persistence()

func _physics_process(delta: float) -> void:
    if is_dead: return
    
    _update_timers(delta)
    _handle_movement_logic(delta)
    _apply_physics()
    _update_state_machine()
    _update_animations()

# === Private Methods ===

func _setup_signals() -> void:
    sprite.animation_finished.connect(_on_animation_finished)
    weapon_area.monitoring = false
    
    health_component.health_changed.connect(_on_health_changed)
    health_component.died.connect(_on_died)
    
    # Notify initial health via EventBus
    EventBus.player_health_changed.emit(health_component.current_health, health_component.max_health)

func _init_persistence() -> void:
    if GameManager.player_position != Vector2.ZERO:
        global_position = GameManager.player_position
        # Consume position to avoid respawning here every scene reload
        GameManager.player_position = Vector2.ZERO
    
    # Restore health if saved
    if GameManager.player_health < health_component.max_health:
        health_component.current_health = GameManager.player_health

func _update_timers(delta: float) -> void:
    if _dash_cooldown_timer > 0: _dash_cooldown_timer -= delta
    if _attack_cooldown_timer > 0: _attack_cooldown_timer -= delta
    
    if is_on_floor(): 
        can_dash = true

    # Visual feedback for invulnerability
    if health_component.is_invulnerable():
        sprite.modulate.a = 0.5 if Engine.get_frames_drawn() % 4 < 2 else 1.0
    else:
        sprite.modulate.a = 1.0

func _handle_movement_logic(delta: float) -> void:
    if is_dashing: return

    var input_dir := Input.get_axis("move_left", "move_right")
    
    # Horizontal Movement
    if input_dir != 0:
        velocity.x = input_dir * run_speed
        if not is_attacking:
            _update_facing(input_dir)
        dash_direction = int(input_dir)
    else:
        velocity.x = move_toward(velocity.x, 0, run_speed)

    # Jump Logic
    if is_on_floor() and Input.is_action_just_pressed("jump"):
        _jump()
    
    if Input.is_action_just_released("jump") and velocity.y < 0:
        velocity.y *= jump_cut

    # Dash Logic
    if Input.is_action_just_pressed("dash") and can_dash and _dash_cooldown_timer <= 0:
        _start_dash(int(input_dir) if input_dir != 0 else dash_direction)

    # Attack Logic
    if Input.is_action_just_pressed("attack") and not is_attacking and _attack_cooldown_timer <= 0:
        _start_attack()

func _apply_physics() -> void:
    if is_dashing:
        _dash_timer -= get_physics_process_delta_time()
        if _dash_timer <= 0:
            _end_dash()
        else:
            velocity.x = dash_direction * dash_speed
            velocity.y = 0
    else:
        # Standard Gravity with Fast Fall
        var current_gravity = gravity
        if velocity.y > 0 and Input.is_action_pressed("move_down"):
            current_gravity *= 2.0
            
        velocity.y += current_gravity * get_physics_process_delta_time()
    
    move_and_slide()

func _update_state_machine() -> void:
    if is_dashing:
        current_state = State.DASHING
    elif is_attacking:
        current_state = State.ATTACKING
    elif is_on_floor():
        current_state = State.RUNNING if abs(velocity.x) > 10.0 else State.IDLE
    else:
        current_state = State.JUMPING if velocity.y < 0 else State.FALLING

func _update_animations() -> void:
    match current_state:
        State.DASHING: sprite.play("dash")
        State.ATTACKING: sprite.play("attack")
        State.JUMPING, State.FALLING: sprite.play("jump")
        State.RUNNING: sprite.play("run")
        State.IDLE: sprite.play("idle")

func _update_facing(dir: float) -> void:
    sprite.flip_h = dir < 0 
    weapon_area.scale.x = -1 if dir < 0 else 1

func _jump() -> void:
    velocity.y = jump_force

func _start_dash(dir: int) -> void:
    is_dashing = true
    is_attacking = false
    can_dash = false
    weapon_area.monitoring = false
    _dash_timer = dash_duration
    _dash_cooldown_timer = dash_cooldown
    dash_direction = dir
    velocity.y = 0
    EventBus.player_dash_triggered.emit()

func _end_dash() -> void:
    is_dashing = false

func _start_attack() -> void:
    is_attacking = true
    _attack_cooldown_timer = attack_cooldown
    weapon_area.monitoring = true
    EventBus.player_attack_triggered.emit()

# === Public Methods ===

## Interface for taking damage from external sources.
func take_damage(amount: int, source_pos: Vector2 = Vector2.ZERO) -> void:
    if is_dead: return
    
    if source_pos != Vector2.ZERO and not health_component.is_invulnerable():
        var recoil_dir := 1 if global_position.x > source_pos.x else -1
        velocity.x = recoil_dir * hit_recoil
        velocity.y = jump_force * 0.5
            
    health_component.take_damage(amount)

# === Signal Callbacks ===

func _on_animation_finished() -> void:
    if sprite.animation == "attack":
        is_attacking = false
        weapon_area.monitoring = false

func _on_weaponarea_body_entered(body: Node2D) -> void:
    if body.is_in_group("enemies") and body.has_method("take_damage"):
        _apply_hit_freeze()
        # Mel feedback
        velocity.x = (1 if sprite.flip_h else -1) * hit_recoil
        body.take_damage(global_position, 300.0, 1)

func _apply_hit_freeze() -> void:
    if Engine.time_scale < 1.0: return # Evita sovrapposizioni di freeze
    
    Engine.time_scale = 0.05
    # Aspetta hit_freeze_time secondi REALI (indipendenti dallo slow motion)
    await get_tree().create_timer(hit_freeze_time, true, false, true).timeout
    Engine.time_scale = 1.0

func _on_health_changed(current: int, max_hp: int) -> void:
    GameManager.player_health = current
    EventBus.player_health_changed.emit(current, max_hp)

func _on_died() -> void:
    _die()

func _die() -> void:
    if is_dead: return
    is_dead = true
    velocity = Vector2.ZERO
    sprite.modulate = Color.RED
    sprite.play("idle")
    EventBus.player_died.emit()
    
    print("Mel è esausta...")
    await get_tree().create_timer(1.5).timeout
    GameManager.respawn_player()
