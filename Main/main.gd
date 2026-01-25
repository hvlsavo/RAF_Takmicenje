extends Node2D

@onready var battle_scene = $Player/Battle
@onready var player = $Player

#Door 1
@onready var door = $Door
@onready var door_tile = $Door/DoorTile
@onready var door_collision = $Door/CollisionShape2D


var social_credit = 0


#Moving npcs
@onready var ucenik_3 = $Ucenik3
@export var ucenik_3_move_limit = 40
var direction = 1
var ucenik_3_start_x = 0.0
var ucenik_moving = true


func _ready():
	ucenik_3_start_x = ucenik_3.position.x
	# poveži sve ucenike iz grupe "ucenici"
	for ucenik in get_tree().get_nodes_in_group("ucenici"):
		ucenik.connect("start_battle", Callable(self, "_on_ucenik_start_battle"))

func _physics_process(delta: float) -> void:
	if ucenik_moving:
		# move ucenik 3 left right
		ucenik_3.position.x += direction * 40 * delta
		if ucenik_3.position.x > ucenik_3_start_x + ucenik_3_move_limit:
			direction = -1
		elif ucenik_3.position.x < ucenik_3_start_x - ucenik_3_move_limit:
			direction = 1

func _on_ucenik_start_battle(ucenik):
	ucenik_moving = false
	player.speed = 0
	battle_scene.start(ucenik)
	ucenik.area2d.set_deferred("monitoring", false)

func _on_battle_player_won():
	social_credit += 1
	player.speed = 200

func _on_battle_player_lost():
	if social_credit > 0:
		social_credit -= 1
	player.speed = 200

func _on_door_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var tween = get_tree().create_tween()
		tween.tween_property(door_tile, "modulate:a", 0.0, 0.4)
		door_collision.disabled = true
		door.monitoring = false
		
