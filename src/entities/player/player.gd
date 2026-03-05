extends CharacterBody2D
class_name Player
## Il personaggio principale controllato dal giocatore.
##
## Gestisce il movimento, il salto, il dash, l'attacco e le interazioni con i nemici.

# === Segnali ===
signal health_changed(new_health: int)
signal dash_triggered
signal attack_triggered

# === Enums ===
enum State { IDLE, RUNNING, JUMPING, FALLING, DASHING, ATTACKING }

# === Costanti ===
const UP_DIRECTION: Vector2 = Vector2.UP

# === Export: Movimento (Fisica Player) ===
@export_group("Movimento")
@export var run_speed: float = 200.0
@export var gravity: float = 1000.0
@export var jump_force: float = -350.0
@export_range(0.0, 1.0) var jump_cut: float = 0.25

# === Export: Combattimento (Combat) ===
@export_group("Combattimento")
@export var dash_speed: float = 500.0
@export var dash_duration: float = 0.275
@export var dash_cooldown: float = 0.5
@export var attack_cooldown: float = 0.1

# === Export: Game Feel ===
@export_group("Game Feel")
@export var hit_recoil: float = 450.0  
@export var enemy_knockback: float = 300.0 
@export var hit_freeze_time: float = 0.05 # Tempo di stop (freeze dello schermo)

# === Variabili di Stato ===
var current_state: State = State.IDLE
var is_dashing: bool = false
var dash_timer: float = 0.0
var dash_cooldown_timer: float = 0.0
var dash_direction: int = 1
var can_dash: bool = true 
var is_attacking: bool = false
var attack_cooldown_timer: float = 0.0

# === Node References ===
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var weapon_area: Area2D = $weaponarea

# === lifecycle ===

func _ready() -> void:
    add_to_group("player")
    sprite.animation_finished.connect(_on_animation_finished)
    weapon_area.monitoring = false
    
    # Impostazioni fisiche per atterraggi stabili
    floor_snap_length = 8.0
    floor_constant_speed = true
    
    # Ripristina posizione da GameManager se disponibile
    if GameManager.player_position != Vector2.ZERO:
        global_position = GameManager.player_position
        GameManager.player_position = Vector2.ZERO

func _physics_process(delta: float) -> void:
    # Timer (Cooldown vari)
    _update_timers(delta)
    # Logica di Input
    _handle_input(delta)
    # Logica Fisica (Gravità e Dash)
    _apply_physics_logic(delta)
    
    move_and_slide()
    
    # Gestione Atterraggio: se siamo a terra, azzeriamo la velocità Y per stabilità
    if is_on_floor():
        if velocity.y > 0:
            velocity.y = 0
        # Snap della velocità a zero se molto piccola
        if abs(velocity.x) < 5.0:
            velocity.x = 0
    
    
    # Aggiornamento Stati e Animazioni
    _update_state()
    _update_animation()

# === Private Methods ===

func _update_timers(delta: float) -> void:
    if dash_cooldown_timer > 0: dash_cooldown_timer -= delta
    if attack_cooldown_timer > 0: attack_cooldown_timer -= delta
    if is_on_floor(): can_dash = true

func _handle_input(delta: float) -> void:
    if current_state == State.DASHING:
        return

    var direction := Input.get_axis("move_left", "move_right")
    
    # Gestione Salto
    if is_on_floor() and Input.is_action_just_pressed("jump"):
        _jump()
    if Input.is_action_just_released("jump") and velocity.y < 0:
        velocity.y *= jump_cut

    # Gestione Dash
    if Input.is_action_just_pressed("dash") and can_dash and dash_cooldown_timer <= 0:
        start_dash(int(direction) if direction != 0 else dash_direction)
    
    # Gestione Attacco
    if Input.is_action_just_pressed("attack") and not is_attacking and attack_cooldown_timer <= 0:
        start_attack()

    # Movimento Orizzontale
    if direction != 0:
        velocity.x = direction * run_speed
        if not is_attacking:
            _update_facing(direction)
        dash_direction = int(direction)
    else:
        # Frenata normale
        velocity.x = move_toward(velocity.x, 0, run_speed)

func _apply_physics_logic(delta: float) -> void:
    if current_state == State.DASHING:
        dash_timer -= delta
        if dash_timer <= 0:
            _end_dash()
        else:
            velocity.x = dash_direction * dash_speed
            velocity.y = 0
    else:
        # Applica gravità sempre (tranne durante il dash) per stabilità is_on_floor
        velocity.y += gravity * delta

func _update_state() -> void:
    if is_dashing:
        current_state = State.DASHING
        return
        
    if is_attacking:
        current_state = State.ATTACKING
        return

    if is_on_floor():
        # Soglia aumentata a 10.0 per evitare che micro-movimenti attivino la corsa
        if abs(velocity.x) > 10.0:
            current_state = State.RUNNING
        else:
            current_state = State.IDLE
    else:
        if velocity.y < 0:
            current_state = State.JUMPING
        else:
            current_state = State.FALLING

func _update_facing(direction: float) -> void:
    sprite.flip_h = direction < 0 
    weapon_area.scale.x = -1 if direction < 0 else 1

func _jump() -> void:
    velocity.y = jump_force

# Azioni del Player

func start_dash(dir: int = 0) -> void:
    if dir == 0: dir = dash_direction
    current_state = State.DASHING
    is_dashing = true
    can_dash = false
    is_attacking = false
    weapon_area.monitoring = false
    dash_timer = dash_duration
    dash_cooldown_timer = dash_cooldown
    dash_direction = dir
    velocity.y = 0
    dash_triggered.emit()

func _end_dash() -> void:
    is_dashing = false
    current_state = State.IDLE

func start_attack() -> void:
    is_attacking = true
    attack_cooldown_timer = attack_cooldown
    sprite.play("attack")
    weapon_area.monitoring = true
    attack_triggered.emit()

func _update_animation() -> void:
    match current_state:
        State.DASHING: sprite.play("dash")
        State.ATTACKING: sprite.play("attack")
        State.JUMPING: sprite.play("jump")
        State.FALLING: sprite.play("jump") # Fallback for now
        State.RUNNING: sprite.play("run")
        State.IDLE: sprite.play("idle")

# === Segnali ===

func _on_animation_finished() -> void:
    if sprite.animation == "attack":
        is_attacking = false
        weapon_area.monitoring = false

func _on_weaponarea_body_entered(body: Node2D) -> void:
    if body.is_in_group("enemies"):
        _hit_enemy(body)

# Colpire i nemici
func _hit_enemy(enemy: Node2D) -> void:
    print("Nemico colpito!")
    # Freeze dello schermo
    _apply_hit_freeze()
    
    # Knockback di Mel
    var recoil_dir := 1 if sprite.flip_h else -1
    velocity.x = recoil_dir * hit_recoil
    
    # KNOCKBACK NEMICO
    if enemy.has_method("take_damage"):
        enemy.take_damage(global_position, enemy_knockback)

# Funzione per bloccare il tempo (Hit Pause)
func _apply_hit_freeze() -> void:
    Engine.time_scale = 0.05
    await get_tree().create_timer(hit_freeze_time, true, false, true).timeout
    Engine.time_scale = 1.0
