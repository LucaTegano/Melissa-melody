extends GutTest

var PlayerScene = preload("res://src/entities/player/player.tscn")
var player

func before_each():
    player = PlayerScene.instantiate()
    add_child_autofree(player)

func test_initial_values():
    assert_eq(player.run_speed, 200.0, "Run speed dovrebbe essere 200")
    assert_eq(player.jump_force, -350.0, "Jump force dovrebbe essere -350")
    assert_eq(player.max_health, 3, "Salute massima dovrebbe essere 3")
    assert_eq(player.current_health, 3, "Salute attuale dovrebbe essere 3 all'inizio")

func test_gravity_applied():
    # Simula un frame di fisica
    player._physics_process(0.1)
    assert_gt(player.velocity.y, 0.0, "La gravità dovrebbe aumentare la velocità Y")

func test_dash_logic():
    # Simula l'inizio del dash
    player.start_dash()
    assert_true(player.is_dashing, "Il player dovrebbe essere in dash")
    
    # Simula un frame durante il dash
    player._physics_process(0.01)
    assert_eq(player.velocity.y, 0.0, "La gravità dovrebbe essere sospesa durante il dash")

func test_attack_logic():
    player.start_attack()
    assert_true(player.is_attacking, "Il player dovrebbe essere in attacco")
    assert_eq(player.attack_cooldown_timer, player.attack_cooldown, "L'attack cooldown dovrebbe essere impostato")

func test_take_damage():
    var initial_health = player.current_health
    player.take_damage(1)
    assert_eq(player.current_health, initial_health - 1, "La salute dovrebbe diminuire di 1")
    assert_true(player.is_invulnerable, "Il player dovrebbe essere invulnerabile dopo il danno")

func test_death_logic():
    player.take_damage(3)
    assert_eq(player.current_health, 0, "La salute dovrebbe essere 0")
    assert_true(player.is_dead, "Il player dovrebbe essere morto")
    assert_eq(player.velocity, Vector2.ZERO, "La velocità dovrebbe essere zero alla morte")
