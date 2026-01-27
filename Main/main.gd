extends Node2D

@onready var battle_scene = $Player/Battle
@onready var player = $Player
@onready var player_camera = $Player/Camera2D
@onready var game_over = $Player/game_over
#Door 1
@onready var door = $Door
@onready var door_tile = $Door/DoorTile
@onready var door_collision = $Door/CollisionShape2D


#dialogue
var dialogue_locked = false
#door 2
var is_player_near = false
var door_locked_timeline : DialogicTimeline = load("res://dialogue/timelines/checking_door.dtl")



var social_credit = 0


#pomerajuci npcevi
@onready var ucenik_3 = $Ucenik3
@export var ucenik_3_move_limit = 40
var direction = 1
var ucenik_3_start_x = 0.0
var ucenik_moving = true

#mini boss
@onready var mini_boss = $Mini_boss
var is_mini_boss_defeated = false
signal mini_boss_defeated

func _ready():
	ucenik_3_start_x = ucenik_3.position.x
	# poveži sve ucenike iz grupe "ucenici"
	for ucenik in get_tree().get_nodes_in_group("ucenici"):
		ucenik.connect("start_battle", Callable(self, "_on_ucenik_start_battle"))

func _physics_process(delta: float) -> void:
	if ucenik_moving:
		# pomera ucenika levo-desno
		ucenik_3.position.x += direction * 40 * delta
		if ucenik_3.position.x > ucenik_3_start_x + ucenik_3_move_limit:
			direction = -1
		elif ucenik_3.position.x < ucenik_3_start_x - ucenik_3_move_limit:
			direction = 1
	if is_player_near and Input.is_action_just_pressed("ui_accept") and dialogue_locked == false:
		_check_locked_door()

func _on_ucenik_start_battle(ucenik):
	ucenik_moving = false
	player.speed = 0
	battle_scene.start(ucenik)
	ucenik.area2d.set_deferred("monitoring", false)

func _on_battle_player_won():
	if is_mini_boss_defeated == false and battle_scene.is_mini_boss:
		is_mini_boss_defeated = true
		var tween = get_tree().create_tween()
		tween.tween_property(player_camera, "zoom", Vector2(1, 1), 0.7).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(battle_scene, "scale", Vector2(1.0, 1.0), 0.7)
	social_credit += 1
	player.speed = 200

func _on_battle_player_lost():
	if battle_scene.is_mini_boss:
		game_over.show()
	if social_credit > 0:
		social_credit -= 1
	player.speed = 200

func _on_door_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var tween = get_tree().create_tween()
		tween.tween_property(door_tile, "modulate:a", 0.0, 0.4)
		door_collision.set_deferred("disabled", true)
		set_deferred("monitoring", false)
		

func _on_mini_boss_start_miniboss_battle(boss):
	var tween = get_tree().create_tween()
	tween.set_parallel()
	tween.tween_property(player_camera, "zoom", Vector2(0.8, 0.8), 0.7).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(battle_scene, "scale", Vector2(1.25, 1.25), 0.7)
	player.speed = 0
	battle_scene.is_mini_boss = true
	battle_scene.start(boss)


func _on_game_over_try_again() -> void:
	game_over.hide()
	battle_scene.start(battle_scene.current_ucenik)


func _on_locked_door_body_entered(body:Node2D) -> void:
	if body.is_in_group("player"):
		is_player_near = true
		

func _on_locked_door_body_exited(body:Node2D) -> void:
	if body.is_in_group("player"):
		is_player_near = false

func _check_locked_door() -> void:
	dialogue_locked = true
	Dialogic.start(door_locked_timeline)
	player.speed = 0
	await Dialogic.timeline_ended
	player.speed = 200
	dialogue_locked = false
