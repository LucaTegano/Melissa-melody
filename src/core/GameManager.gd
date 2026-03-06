extends Node
## Global game state manager and persistence system.
##
## Coordinates between EventBus signals and persistent storage.

# === Configuration ===
const SAVE_PATH: String = "user://savegame.tres"

# === Global State ===
var player_position: Vector2 = Vector2.ZERO
var player_score: int = 0:
    set(value):
        _player_score = value
        EventBus.score_changed.emit(_player_score)
    get:
        return _player_score

var player_health: int = 3:
    set(value):
        _player_health = value
        EventBus.player_health_changed.emit(_player_health, 3)
    get:
        return _player_health

# === Private State ===
var _player_score: int = 0
var _player_health: int = 3

# === Lifecycle ===

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS

# === Public API ===

## Saves the current game state to file.
func save_game(player: Player) -> void:
    var save_data := SaveData.new()
    save_data.scene_path = player.get_tree().current_scene.scene_file_path
    save_data.player_position = player.global_position
    save_data.score = player_score
    save_data.current_health = player.health_component.current_health
    
    var error := ResourceSaver.save(save_data, SAVE_PATH)
    if error == OK:
        print("[GameManager] Game saved successfully.")
        EventBus.game_saved.emit()
    else:
        printerr("[GameManager] Failed to save game: ", error)

## Loads the game state and transitions to the saved level.
func load_game(force_full_health: bool = false) -> void:
    if not ResourceLoader.exists(SAVE_PATH):
        print("[GameManager] No save file found.")
        return

    var save_data := ResourceLoader.load(SAVE_PATH) as SaveData
    if not save_data:
        printerr("[GameManager] Error loading save data resource.")
        return
    
    # Restore data
    player_position = save_data.player_position
    player_score = save_data.score
    
    if force_full_health:
        player_health = 3
    else:
        player_health = save_data.current_health
    
    # Safety check
    if player_health <= 0:
        player_health = 3
    
    if get_tree().change_scene_to_file(save_data.scene_path) == OK:
        print("[GameManager] Level loaded: ", save_data.scene_path)
        EventBus.game_loaded.emit()
    else:
        printerr("[GameManager] Failed to change scene.")

## Resets health and reloads from checkpoint or scene start.
func respawn_player() -> void:
    print("[GameManager] Respawning player...")
    # Use load_game with forced full health if a save exists
    if ResourceLoader.exists(SAVE_PATH):
        load_game(true)
    else:
        player_health = 3
        player_score = 0
        get_tree().reload_current_scene()

func add_score(amount: int) -> void:
    player_score += amount
