class_name HealthComponent
extends Node
## Component for managing health and invulnerability logic.
##
## Can be attached to any entity to give it health properties.
## Handles damage, healing, and invulnerability duration.

# === Signals ===
signal health_changed(current: int, maximum: int)
signal damaged(amount: int)
signal healed(amount: int)
signal died

# === Exports ===
@export_group("Stats")
@export var max_health: int = 3
@export var invulnerability_duration: float = 0.5 

# === Properties ===
var current_health: int:
    set(value):
        var old_health = _current_health
        _current_health = clampi(value, 0, max_health)
        if _current_health != old_health:
            health_changed.emit(_current_health, max_health)
    get:
        return _current_health

# === Private Properties ===
var _current_health: int = 0
var _invulnerability_timer: float = 0.0
var _is_invulnerable: bool = false:
    set(value):
        _is_invulnerable = value
        set_process(_is_invulnerable)

# === Lifecycle ===

func _ready() -> void:
    current_health = max_health
    set_process(false)

func _process(delta: float) -> void:
    if _is_invulnerable:
        _invulnerability_timer -= delta
        if _invulnerability_timer <= 0:
            _is_invulnerable = false

# === Public Methods ===

## Applies damage to the component.
func take_damage(amount: int) -> int:
    if _is_invulnerable or current_health <= 0:
        return 0
        
    var actual_damage = mini(amount, current_health)
    current_health -= actual_damage
    damaged.emit(actual_damage)
    
    if current_health <= 0:
        died.emit()
    elif invulnerability_duration > 0:
        _start_invulnerability()
        
    return actual_damage

## Restores health to the component.
func heal(amount: int) -> int:
    if current_health <= 0:
        return 0
    
    var old_health = current_health
    current_health += amount
    var reduction = current_health - old_health
    
    if reduction > 0:
        healed.emit(reduction)
    return reduction

func is_dead() -> bool:
    return current_health <= 0

func is_invulnerable() -> bool:
    return _is_invulnerable

# === Private Methods ===

func _start_invulnerability() -> void:
    _is_invulnerable = true
    _invulnerability_timer = invulnerability_duration
