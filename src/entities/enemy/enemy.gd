extends CharacterBody2D
class_name Enemy
## Patrolling enemy with unpredictable behavior, health, and auto-respawn.

# === Enums ===
enum State { PATROL, WAIT }

# === Exports ===
@export_group("Movement")
@export var speed: float = 100.0
@export var gravity: float = 1000.0

@export_group("AI Behavior")
@export var min_patrol_time: float = 1.5
@export var max_patrol_time: float = 4.0
@export var min_wait_time: float = 0.5
@export var max_wait_time: float = 2.0
@export_range(0.0, 1.0) var flip_chance: float = 0.4

@export_group("Combat")
## Damage dealt to the player on contact.
@export var damage: int = 1

@export_group("Respawn")
## Time in seconds before the enemy respawns after death.
@export var respawn_time: float = 5.0

# === State ===
var current_state: State = State.PATROL
var direction: int = 1 
var knockback: Vector2 = Vector2.ZERO
var is_dead: bool = false
var spawn_position: Vector2

# === Private Variables ===
var _state_timer: float = 0.0

# === Node References ===
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_component: HealthComponent = $HealthComponent
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

# === Lifecycle ===

func _ready() -> void:
    add_to_group("enemies")
    spawn_position = global_position
    _setup_signals()
    _pick_random_state()
    if sprite:
        sprite.play("walk")

func _physics_process(delta: float) -> void:
    if is_dead: return
    
    _update_ai(delta)
    _apply_physics(delta)
    move_and_slide()
    _handle_collisions()

# === Private Methods ===

func _setup_signals() -> void:
    health_component.died.connect(_on_died)

func _update_ai(delta: float) -> void:
    _state_timer -= delta
    if _state_timer <= 0:
        _pick_random_state()

func _pick_random_state() -> void:
    # Alterna tra muoversi e aspettare
    if current_state == State.PATROL:
        current_state = State.WAIT
        _state_timer = randf_range(min_wait_time, max_wait_time)
        if sprite: sprite.play("idle")
    else:
        current_state = State.PATROL
        _state_timer = randf_range(min_patrol_time, max_patrol_time)
        # Probabilità di girarsi prima di ripartire
        if randf() < flip_chance:
            _flip()
        if sprite: sprite.play("walk")

func _apply_physics(delta: float) -> void:
    # Gravity
    if not is_on_floor():
        velocity.y += gravity * delta
    
    # Horizontal Movement based on state
    var target_vel_x = 0.0
    if current_state == State.PATROL:
        target_vel_x = direction * speed
        
    velocity.x = target_vel_x + knockback.x
    knockback = knockback.move_toward(Vector2.ZERO, speed * 2 * delta)

func _handle_collisions() -> void:
    # Inversione immediata se tocca un muro
    if is_on_wall():
        _flip()

func _flip() -> void:
    direction *= -1
    if sprite: sprite.flip_h = direction < 0

# === Public Methods ===

## Interface for taking damage from external sources.
func take_damage(source_pos: Vector2, force: float, damage_amount: int = 1) -> void:
    if is_dead: return
    
    # Calculate knockback direction
    var dir_x := 1 if global_position.x > source_pos.x else -1
    knockback = Vector2(dir_x * force, 0)
    
    health_component.take_damage(damage_amount)

func respawn() -> void:
    is_dead = false
    global_position = spawn_position
    health_component.current_health = health_component.max_health
    _pick_random_state()
    
    # Re-enable physics and visuals
    set_physics_process(true)
    if collision_shape: 
        collision_shape.set_deferred("disabled", false)
    
    if sprite:
        sprite.visible = true
        sprite.modulate = Color.WHITE
        sprite.modulate.a = 1.0
    
    print("[Enemy] Respawned at ", spawn_position)

# === Signal Callbacks ===

func _on_died() -> void:
    if is_dead: return
    is_dead = true
    
    # Notify system
    EventBus.enemy_died.emit(self)
    
    # Death feedback
    if sprite:
        sprite.modulate = Color.RED
    
    # Disable collisions safely during physics
    if collision_shape: 
        collision_shape.set_deferred("disabled", true)
    
    velocity = Vector2.ZERO
    
    # Wait for death effect (ignoring engine slow-motion)
    await get_tree().create_timer(0.5, true, false, true).timeout
    
    # Hide and disable instead of queue_free()
    if sprite: sprite.visible = false
    set_physics_process(false)
    
    # Setup respawn timer (ignoring engine slow-motion)
    await get_tree().create_timer(respawn_time, true, false, true).timeout
    respawn()

func _on_hitbox_body_entered(body: Node2D) -> void:
    if is_dead: return
    
    if body is Player:
        body.take_damage(damage, global_position)
