extends GutTest

var PlayerScene = preload("res://scenes/player.tscn")
var player

func before_each():
	player = PlayerScene.instantiate()
	add_child_autofree(player)

func test_initial_values():
	assert_eq(player.SPEED, 300.0, "Speed should be 300")
	assert_eq(player.JUMP_VELOCITY, -400.0, "Jump velocity should be -400")
	assert_eq(player.DASH_DISTANCE, 300.0, "Dash distance should be 300")
	assert_eq(player.DASH_COOLDOWN, 0.5, "Dash cooldown should be 0.5")
	assert_eq(player.ATTACK_COOLDOWN, 0.5, "Attack cooldown should be 0.5")

func test_gravity_applied():
	# Simulate physics frame
	player._physics_process(0.1)
	assert_gt(player.velocity.y, 0.0, "Gravity should increase Y velocity")

func test_dash_logic():
	# Simulate dash start
	player.start_dash()
	assert_true(player.is_dashing, "Player should be dashing")
	assert_eq(player.dash_timer, player.DASH_DURATION, "Dash timer should be set")
	
	# Simulate frame during dash
	player._physics_process(0.01)
	assert_ne(player.velocity.x, 0.0, "Player should have velocity during dash")
	assert_eq(player.velocity.y, 0.0, "Gravity should be suspended during dash")

func test_attack_logic():
	player.start_attack()
	assert_true(player.is_attacking, "Player should be attacking")
	assert_eq(player.animated_sprite.animation, "attack", "Animation should be attack")
	assert_eq(player.attack_cooldown_timer, player.ATTACK_COOLDOWN, "Attack cooldown should be set")
