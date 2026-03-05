extends GutTest

var PlayerScene = preload("res://src/entities/player/player.tscn")
var player

func before_each():
	player = PlayerScene.instantiate()
	add_child_autofree(player)

func test_initial_values():
	assert_eq(player.run_speed, 200.0, "Run speed dovrebbe essere 200")
	assert_eq(player.jump_force, -350.0, "Jump force dovrebbe essere -350")
	assert_eq(player.dash_speed, 500.0, "Dash speed dovrebbe essere 500")
	assert_eq(player.dash_duration, 0.275, "Dash duration dovrebbe essere 0.275")
	assert_eq(player.dash_cooldown, 0.5, "Dash cooldown dovrebbe essere 0.5")
	assert_eq(player.attack_cooldown, 0.1, "Attack cooldown dovrebbe essere 0.1")

func test_gravity_applied():
	# Simula un frame di fisica
	player._physics_process(0.1)
	assert_gt(player.velocity.y, 0.0, "La gravità dovrebbe aumentare la velocità Y")

func test_dash_logic():
	# Simula l'inizio del dash
	player.start_dash()
	assert_true(player.is_dashing, "Il player dovrebbe essere in dash")
	assert_eq(player.dash_timer, player.dash_duration, "Il dash timer dovrebbe essere impostato")
	
	# Simula un frame durante il dash
	player._physics_process(0.01)
	assert_ne(player.velocity.x, 0.0, "Il player dovrebbe avere velocità durante il dash")
	assert_eq(player.velocity.y, 0.0, "La gravità dovrebbe essere sospesa durante il dash")

func test_attack_logic():
	player.start_attack()
	assert_true(player.is_attacking, "Il player dovrebbe essere in attacco")
	assert_eq(player.sprite.animation, "attack", "L'animazione dovrebbe essere attack")
	assert_eq(player.attack_cooldown_timer, player.attack_cooldown, "L'attack cooldown dovrebbe essere impostato")
