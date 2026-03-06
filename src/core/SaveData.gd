class_name SaveData
extends Resource
## Risorsa per i dati di salvataggio.
##
## Contiene le informazioni necessarie per ripristinare lo stato del gioco.

@export var scene_path: String = ""
@export var player_position: Vector2 = Vector2.ZERO
@export var score: int = 0
@export var current_health: int = 3
