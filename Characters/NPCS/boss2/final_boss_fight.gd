extends Node2D


@export var button_markers : Array[Node2D] = []

@onready var fb_player = $fb_player
@onready var button = $Area2D
@onready var button_collision = $Area2D/CollisionShape2D
@onready var fearbar = $Fearbar
var fb_button_touched = false

func _ready() -> void:
	pick_button()
	fb_player.speed = 0

func _physics_process(delta: float) -> void:
	if fb_button_touched and Input.is_action_just_pressed("ui_accept"):
		fearbar.value -= 10
		pick_button()

func _on_area_2d_body_entered(body:Node2D) -> void:
	if body == fb_player:
		fb_button_touched = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == fb_player:
		fb_button_touched = false

func pick_button():
	button.hide()
	button_collision.disabled = true
	await get_tree().create_timer(1.0).timeout
	button.show()
	button_collision.disabled = false
	var random_marker = button_markers.pick_random()
	var last_marker = random_marker
	if random_marker == last_marker:
		random_marker = button_markers.pick_random()
	button.position = random_marker.position

func _on_main_final_boss_started() -> void:
	fb_player.speed = 100
