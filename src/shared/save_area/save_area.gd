extends Area2D

# Riferimento alla scritta
@onready var label = $Label

var player_inside = false
var player_ref = null # Memorizzo chi è il giocatore

func _ready():
	
	label.visible = false
	
	# Colleghiamo i segnali per sapere quando Mel entra ed esce
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _input(event):
	
	if player_inside and Input.is_action_just_pressed("ui_accept"):
		print("Salvataggio in corso...")
		#logica salvataggio
		
		GameManager.save_game(player_ref)
		
		
		label.text = "GIOCO SALVATO"
		
		
		await get_tree().create_timer(1.0).timeout
		label.text = "Premi INVIO per Salvare"

# Quando qualcuno entra nell'area
func _on_body_entered(body):
	if body.name == "Player":
		player_inside = true
		player_ref = body # Ci ricordiamo chi è Mel
		label.visible = true # Mostra la scritta

# Quando qualcuno esce dall'area
func _on_body_exited(body):
	if body.name == "Player":
		player_inside = false
		player_ref = null
		label.visible = false # Nascondi la scritta
