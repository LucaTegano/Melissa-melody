extends GutTest

var PlayerScene = preload("res://scenes/player.tscn")
var player

func before_each():
	player = PlayerScene.instantiate()
	add_child_autofree(player)
	player.position = Vector2(0, 0)

func test_attack_integration():
	# Simulate Attack Input manually
	var event_press = InputEventAction.new()
	event_press.action = "attack"
	event_press.pressed = true
	Input.parse_input_event(event_press)
	
	await wait_physics_frames(2)
	
	assert_true(player.is_attacking, "Player should enter attack state on input")
	
	var event_release = InputEventAction.new()
	event_release.action = "attack"
	event_release.pressed = false
	Input.parse_input_event(event_release)
	
	# Wait for animation to finish
	await wait_seconds(0.3)
	
	assert_false(player.is_attacking, "Player should exit attack state after animation")

func test_dash_integration():
	var start_pos = player.position
	player.dash_cooldown_timer = 0
	
	# Simulate Dash Input manually
	var event_press = InputEventAction.new()
	event_press.action = "dash"
	event_press.pressed = true
	Input.parse_input_event(event_press)
	
	await wait_physics_frames(2)
	
	assert_true(player.is_dashing, "Player should enter dash state")
	
	var event_release = InputEventAction.new()
	event_release.action = "dash"
	event_release.pressed = false
	Input.parse_input_event(event_release)
	
	# Wait for dash duration
	await wait_seconds(player.DASH_DURATION + 0.1)
	
	assert_false(player.is_dashing, "Player should exit dash state")
	
	var dist = player.position.distance_to(start_pos)
	assert_gt(dist, 10.0, "Player should have moved during dash")
