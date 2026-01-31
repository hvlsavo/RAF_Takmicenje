extends Node2D

# Nodi
@onready var player = $Player
@onready var player_camera = $Player/Camera2D
@onready var battle_scene = $Player/Battle
@onready var game_over = $Player/game_over

# Vrata 1
@onready var door = $Door
@onready var door_tile = $Door/DoorTile
@onready var door_collision = $Door/CollisionShape2D

# Pomerajući NPC
@onready var ucenik_3 = $Ucenik3

# Mini boss
@onready var mini_boss = $Mini_boss

# Stanje igre
var keys: int = 0
var social_credit: int = 0
var dialogue_locked: bool = false

# Zaključana vrata
var is_player_near: bool = false
var door_locked_timeline: DialogicTimeline = preload("res://dialogue/timelines/checking_door.dtl")

# Mini boss
var is_mini_boss_defeated: bool = false

#Final boss
@onready var cam_marker = $Final_Boss/Camera_Marker
var final_boss_dialogue: DialogicTimeline = preload("res://dialogue/timelines/final_boss.dtl")
@onready var final_boss_battle = $Final_boss_fight
signal final_boss_started



# Pomeranje NPC
@export var ucenik_3_move_limit: int = 40
var ucenik_3_start_x: float
var direction: int = 1
var ucenik_moving: bool = true

func _ready() -> void:
	ucenik_3_start_x = ucenik_3.position.x
	for ucenik in get_tree().get_nodes_in_group("ucenici"):
		ucenik.connect("start_battle", Callable(self, "_on_ucenik_start_battle"))

func _physics_process(delta: float) -> void:
	_move_ucenik(delta)
	_handle_locked_door_input()

func _move_ucenik(delta: float) -> void:
	if not ucenik_moving:
		return
	ucenik_3.position.x += direction * 40 * delta
	if ucenik_3.position.x > ucenik_3_start_x + ucenik_3_move_limit:
		direction = -1
	elif ucenik_3.position.x < ucenik_3_start_x - ucenik_3_move_limit:
		direction = 1

func _handle_locked_door_input() -> void:
	if is_player_near and not dialogue_locked and Input.is_action_just_pressed("ui_accept"):
		_check_locked_door()

func _on_ucenik_start_battle(ucenik) -> void:
	ucenik_moving = false
	_lock_player()
	battle_scene.start(ucenik)
	ucenik.area2d.set_deferred("monitoring", false)

func _on_battle_player_won() -> void:
	if battle_scene.is_mini_boss and not is_mini_boss_defeated:
		is_mini_boss_defeated = true
		var tween = get_tree().create_tween()
		tween.tween_property(player_camera, "zoom", Vector2(1,1), 0.7).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(battle_scene, "scale", Vector2.ONE, 0.7)
	social_credit += 1
	_unlock_player()

func _on_battle_player_lost() -> void:
	if battle_scene.is_mini_boss:
		game_over.show()
	if social_credit > 0:
		social_credit -= 1
	_unlock_player()

func _on_game_over_try_again() -> void:
	game_over.hide()
	battle_scene.start(battle_scene.current_ucenik)

func _on_mini_boss_start_miniboss_battle(boss) -> void:
	var tween = get_tree().create_tween()
	tween.set_parallel()
	tween.tween_property(player_camera, "zoom", Vector2(0.8,0.8), 0.7).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(battle_scene, "scale", Vector2(1.25,1.25), 0.7)
	_lock_player()
	battle_scene.is_mini_boss = true
	battle_scene.start(boss)

func _on_door_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	var tween = get_tree().create_tween()
	tween.tween_property(door_tile, "modulate:a", 0.0, 0.4)
	door_collision.set_deferred("disabled", true)
	door.set_deferred("monitoring", false)

func _on_locked_door_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_near = true

func _on_locked_door_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_near = false

func _check_locked_door() -> void:
	dialogue_locked = true
	_lock_player()
	Dialogic.start(door_locked_timeline)
	await Dialogic.timeline_ended
	_unlock_player()
	dialogue_locked = false

func _on_interactables_interaction_started() -> void:
	_lock_player()

func _on_interactables_interaction_over() -> void:
	_unlock_player()

func _on_stkey_first_key_obtained() -> void:
	keys = min(keys + 1, 3)

func _on_stkey_interaction_started() -> void:
	_lock_player()

func _on_stkey_interaction_over() -> void:
	_unlock_player()

func _lock_player() -> void:
	player.speed = 0

func _unlock_player() -> void:
	player.speed = 200

func _on_puzzle_secondkey_obtained() -> void:
	keys = min(keys + 1, 3)
	_lock_player()
	await Dialogic.timeline_ended
	_unlock_player()


func _on_final_boss_final_battle_started() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(player.get_node("Camera2D"), "global_position", cam_marker.global_position, 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_lock_player()
	Dialogic.start(final_boss_dialogue)
	await Dialogic.timeline_ended
	final_boss_battle.set_process(false)
	final_boss_battle.set_physics_process(false)
	final_boss_battle.visible = true
	final_boss_battle.modulate.a = 0.0
	var tween2 = get_tree().create_tween()
	tween2.tween_property(final_boss_battle, "modulate:a", 1.0, 1.0)
	await tween2.finished
	final_boss_battle.set_process(true)
	final_boss_battle.set_physics_process(true)
	final_boss_started.emit()

