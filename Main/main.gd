extends Node2D

@onready var battle_scene = $Player/Battle
@onready var player = $Player

var social_credit = 0

func _ready():
	# poveži sve ucenike iz grupe "ucenici"
	for ucenik in get_tree().get_nodes_in_group("ucenici"):
		ucenik.connect("start_battle", Callable(self, "_on_ucenik_start_battle"))

func _on_ucenik_start_battle(ucenik):
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
