extends Area2D
class_name SaveArea
## Area di salvataggio che interagisce con il Player.

# === Segnali ===
signal game_saved

# === Node References ===
# Riferimento alla scritta
@onready var label: Label = $Label

# === Variabili di Stato ===
var player_inside: bool = false
var player_ref: Player = null # Memorizzo chi è il giocatore

# === lifecycle ===

func _ready() -> void:
    label.visible = false
    # Colleghiamo i segnali per sapere quando Mel entra ed esce
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)

func _input(event: InputEvent) -> void:
    if player_inside and Input.is_action_just_pressed("ui_accept"):
        _perform_save()

# === Private Methods ===

func _perform_save() -> void:
    if not player_ref:
        return
        
    print("Salvataggio in corso...")
    # Logica di salvataggio
    GameManager.save_game(player_ref)
    
    label.text = "GIOCO SALVATO"
    game_saved.emit()
    
    await get_tree().create_timer(1.0).timeout
    if player_inside:
        label.text = "Premi INVIO per Salvare"

# Quando qualcuno entra nell'area
func _on_body_entered(body: Node2D) -> void:
    if body is Player:
        player_inside = true
        player_ref = body as Player # Ci ricordiamo chi è Mel
        label.visible = true # Mostra la scritta
        label.text = "Premi INVIO per Salvare"

# Quando qualcuno esce dall'area
func _on_body_exited(body: Node2D) -> void:
    if body is Player:
        player_inside = false
        player_ref = null
        label.visible = false # Nascondi la scritta
