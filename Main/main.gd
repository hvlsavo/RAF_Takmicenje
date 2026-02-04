extends Node2D

# Nodi
@onready var player = $Player
@onready var player_camera = $Player/Camera2D
@onready var battle_scene = $Player/Battle
@onready var game_over = $Player/game_over
@onready var ucenik1 = $Ucenik1
@onready var ucenik2 = $Ucenik2
@onready var ucenik3 = $Ucenik3
@onready var main_music = $Player/AudioStreamPlayer2D
@onready var mini_boss_music = $Mini_boss/AudioStreamPlayer2D
# Vrata 1
@onready var door = $Door
@onready var door_tile = $Door/DoorTile
@onready var door_collision = $Door/CollisionShape2D

# Mini boss
@onready var mini_boss = $Mini_boss

# Stanje igre
var social_credit: int = 0
var dialogue_locked: bool = false

# Zaključana vrata
var is_player_near: bool = false
var door_unlocking_timeline: DialogicTimeline = preload("res://dialogue/timelines/unlocking_door.dtl")
var door_locked_timeline: DialogicTimeline = preload("res://dialogue/timelines/checking_door.dtl")

# Mini boss
var is_mini_boss_defeated: bool = false

#Final boss
@onready var final_boss = $Final_Boss
@onready var cam_marker = $Final_Boss/Camera_Marker
var final_boss_dialogue: DialogicTimeline = preload("res://dialogue/timelines/final_boss.dtl")
var final_boss_end_dialogue: DialogicTimeline = preload("res://dialogue/timelines/Final_boss_ending.dtl")

func _ready() -> void:
	self.modulate = Color.BLACK
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color(1,1,1,1), 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	if Manager.is_final_boss_defeated:
		Manager.keys +=1
		ucenik1.queue_free()
		ucenik2.queue_free()
		ucenik3.queue_free()
		final_boss.queue_free()
		player.speed = 0
		Dialogic.start(final_boss_end_dialogue)
		await Dialogic.timeline_ended
		player.speed = 200
	if Manager.is_mini_boss_defeated:
		mini_boss.queue_free()
	for ucenik in get_tree().get_nodes_in_group("ucenici"):
		ucenik.connect("start_battle", Callable(self, "_on_ucenik_start_battle"))

func _physics_process(delta: float) -> void:
	_handle_locked_door_input()

func _handle_locked_door_input() -> void:
	if is_player_near and not dialogue_locked and Input.is_action_just_pressed("ui_accept"):
		_check_locked_door()

func _on_ucenik_start_battle(ucenik) -> void:
	_lock_player()
	battle_scene.start(ucenik)
	ucenik.area2d.set_deferred("monitoring", false)

func _on_battle_player_won() -> void:
	if battle_scene.is_mini_boss and not is_mini_boss_defeated:
		mini_boss_music.stop()
		main_music.play()
		Manager.is_mini_boss_defeated = true
		is_mini_boss_defeated = true
		var tween = get_tree().create_tween()
		tween.tween_property(player_camera, "zoom", Vector2(1,1), 0.7).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(battle_scene, "scale", Vector2.ONE, 0.7)
	Manager.social_credit +=1
	social_credit += 1
	_unlock_player()

func _on_battle_player_lost() -> void:
	if battle_scene.is_mini_boss:
		mini_boss_music.stop()
		main_music.stop()
		game_over.show()
	if social_credit > 0:
		Manager.social_credit -= 1
		social_credit -= 1
	_unlock_player()

func _on_game_over_try_again() -> void:
	game_over.hide()
	battle_scene.start(battle_scene.current_ucenik)
	if battle_scene.is_mini_boss:
		mini_boss_music.play()

func _on_mini_boss_start_miniboss_battle(boss) -> void:
	main_music.stop()
	mini_boss_music.play()
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
	if Manager.keys == 3:
		Dialogic.start(door_unlocking_timeline)
		dialogue_locked = true
		_lock_player()
		await Dialogic.timeline_ended
		if Manager.social_credit > 0:
			Manager.good_ending = true
			var tween = get_tree().create_tween()
			tween.tween_property(self, "modulate:a", 0, 1.5)
			await tween.finished
			get_tree().change_scene_to_file("res://Main/ending.tscn")
		else:
			Manager.good_ending = false
			var tween = get_tree().create_tween()
			tween.tween_property(self, "modulate:a", 0, 1.5)
			await tween.finished
			get_tree().change_scene_to_file("res://Main/ending.tscn")
	else:
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
	_lock_player()

func _on_stkey_interaction_started() -> void:
	_lock_player()

func _on_stkey_interaction_over() -> void:
	_unlock_player()

func _lock_player() -> void:
	player.speed = 0

func _unlock_player() -> void:
	player.speed = 200

func _on_puzzle_secondkey_obtained() -> void:
	_lock_player()
	await Dialogic.timeline_ended
	Manager.keys += 1
	_unlock_player()


func _on_final_boss_final_battle_started() -> void:
	main_music.stop()
	var tween = get_tree().create_tween()
	tween.tween_property(player.get_node("Camera2D"), "global_position", cam_marker.global_position, 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_lock_player()
	Dialogic.start(final_boss_dialogue)
	await Dialogic.timeline_ended
	tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color.BLACK, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	get_tree().change_scene_to_file("res://Characters/NPCS/boss2/final_boss_fight.tscn")
