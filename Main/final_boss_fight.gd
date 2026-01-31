extends Node2D

@export var button_markers : Array[Node2D] = []

@onready var player = $fb_player

@onready var button = $Area2D
@onready var button_collision = $Area2D/CollisionShape2D
@onready var fearbar = $Fearbar
var fb_button_touched = false
var is_picking_button = false

func _physics_process(delta: float) -> void:
	if fb_button_touched and Input.is_action_just_pressed("ui_accept") and not is_picking_button:
		pick_button()
		fearbar.value -= 10


func _on_area_2d_body_entered(body:Node2D) -> void:
	if body == player:
		fb_button_touched = true

func _on_area_2d_body_exited(body:Node2D) -> void:
	if body == player:
		fb_button_touched = false

func pick_button():
	is_picking_button = true
	button.hide()
	button_collision.disabled = true
	await get_tree().create_timer(1.0).timeout
	button.show()
	button_collision.disabled = false
	var random_marker = button_markers.pick_random()
	var last_marker = random_marker
	while random_marker == last_marker and button_markers.size() > 1:
		random_marker = button_markers.pick_random()
	button.global_position = random_marker.global_position
	is_picking_button = false