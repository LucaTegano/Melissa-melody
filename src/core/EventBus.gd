extends Node
## Global signal bus for decoupling systems.
##
## This autoload handles communication between independent systems like
## the Player, enemies, HUD, and GameManager.

# Player signals
signal player_health_changed(current: int, max_hp: int)
signal player_died
signal player_dash_triggered
signal player_attack_triggered

# Combat / Enemy signals
signal enemy_died(enemy: Node2D)
signal damage_dealt(amount: int, target: Node2D)

# Game / UI signals
signal score_changed(new_score: int)
signal level_completed
signal game_saved
signal game_loaded
