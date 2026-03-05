extends Node


const SAVE_PATH = "user://savegame.save"


var player_position = Vector2.ZERO
var current_scene = ""

func save_game(player_node):

	var data = {
		"filename": player_node.get_tree().current_scene.scene_file_path, # Quale livello è?
		"pos_x": player_node.global_position.x, # Dove si trova Mel?
		"pos_y": player_node.global_position.y
	}
	
	# Apriamo il file in modalità SCRITTURA 
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	
	# Trasformiamo i dati in testo JSON e salviamo
	var json_string = JSON.stringify(data)
	file.store_line(json_string)
	
	print("Gioco Salvato!")

func load_game():
	# Controlliamo se il file esiste
	if not FileAccess.file_exists(SAVE_PATH):
		print("Nessun salvataggio trovato!")
		return # Non fare nulla
	
	# Apriamo il file in modalità LETTURA 
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var json_string = file.get_line()
	
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	var data = json.get_data()
	
	
	# Prima memorizziamo i dati in variabili temporanee nel GameManager
	player_position = Vector2(data["pos_x"], data["pos_y"])
	
	# Cambiamo scena verso quella salvata
	get_tree().change_scene_to_file(data["filename"])
