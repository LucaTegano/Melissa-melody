extends CanvasLayer
## Heads-Up Display for player stats.
##
## Decoupled from the Player node, listens to EventBus for updates.

@onready var health_label: Label = $Control/HealthLabel
@onready var score_label: Label = $Control/ScoreLabel

func _ready() -> void:
    # Connect global signals
    EventBus.player_health_changed.connect(_update_health_display)
    EventBus.score_changed.connect(_update_score_display)
    
    # Initialize values from GameManager (our global state holder)
    _update_health_display(GameManager.player_health, 3)
    _update_score_display(GameManager.player_score)

func _update_health_display(current: int, max_hp: int) -> void:
    health_label.text = "VITA: %d / %d" % [current, max_hp]

func _update_score_display(new_score: int) -> void:
    score_label.text = "NOTE: %d" % new_score
