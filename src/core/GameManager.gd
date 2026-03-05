extends Node
## Manager globale per lo stato del gioco e il sistema di salvataggio.
##
## Gestisce il caricamento delle scene e la persistenza dei dati del giocatore.

# === Costanti ===
const SAVE_PATH: String = "user://savegame.tres"

# === Variabili Pubbliche ===
var player_position: Vector2 = Vector2.ZERO

# === Metodi Pubblici ===

## Salva lo stato attuale del gioco nel file di sistema.
func save_game(player_node: CharacterBody2D) -> void:
	var save_data := SaveData.new()
	save_data.scene_path = player_node.get_tree().current_scene.scene_file_path # Quale livello è?
	save_data.player_position = player_node.global_position # Dove si trova Mel?
	
	# Apriamo/salviamo il file (nuovo metodo backend)
	var error := ResourceSaver.save(save_data, SAVE_PATH)
	if error == OK:
		print("Gioco Salvato con successo in %s!" % SAVE_PATH)
	else:
		printerr("Errore durante il salvataggio: ", error)

## Carica lo stato del gioco dal file di sistema e cambia scena.
func load_game() -> void:
	# Controlliamo se il file esiste
	if not ResourceLoader.exists(SAVE_PATH):
		print("Nessun salvataggio trovato in %s!" % SAVE_PATH)
		return # Non fare nulla

	# Leggiamo il file di salvataggio
	var save_data := ResourceLoader.load(SAVE_PATH) as SaveData
	if not save_data:
		printerr("Errore nel caricamento del file di salvataggio!")
		return
	
	# Prima memorizziamo i dati in variabili temporanee nel GameManager
	player_position = save_data.player_position
	
	# Cambiamo scena verso quella salvata
	var error := get_tree().change_scene_to_file(save_data.scene_path)
	if error != OK:
		printerr("Errore nel cambio scena: ", error)
	else:
		print("Caricamento completato. Scena: ", save_data.scene_path)
