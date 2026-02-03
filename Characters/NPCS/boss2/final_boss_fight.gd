extends Node2D

@export var button_markers : Array[Node2D] = []


@export var bullet_patterns : Array[Node] = []

@onready var fb_player = $fb_player
@onready var button = $Area2D
@onready var button_collision = $Area2D/CollisionShape2D
@onready var fearbar = $Fearbar
@onready var game_over = $CanvasLayer/game_over
@onready var hit_sound = $hitsound
var fb_button_touched := false
var can_spawn := true
var pattern_index := 0
var can_take_damage = true

func _ready() -> void:
	if not Spawning.is_connected(
		"bullet_collided_body",
		Callable(self, "_on_bullet_hit")
	):
		Spawning.connect(
			"bullet_collided_body",
			Callable(self, "_on_bullet_hit")
		)

	pick_button()

func _physics_process(delta: float) -> void:
	if fb_button_touched and Input.is_action_just_pressed("ui_accept"):
		fearbar.value -= 20
		pick_button()

	if fearbar.value >= 100:
		game_over.visible = true
		set_physics_process(false)
		return
	elif fearbar.value <= 0:
		Manager.is_final_boss_defeated = true
		Spawning.reset_bullets()
		get_tree().change_scene_to_file("res://Main/main.tscn")
	loop_patterns()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == fb_player:
		fb_button_touched = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == fb_player:
		await get_tree().create_timer(2).timeout
		fb_button_touched = false


func loop_patterns() -> void:
	if not can_spawn or bullet_patterns.is_empty():
		return

	can_spawn = false

	var pattern = bullet_patterns.pick_random()
	if pattern and pattern.has_method("spawn"):
		pattern.spawn()


	await get_tree().create_timer(3).timeout
	can_spawn = true


func pick_button() -> void:
	button.hide()
	button_collision.disabled = true
	await get_tree().create_timer(1.0).timeout
	button.show()
	button_collision.disabled = false

	var random_marker = button_markers.pick_random()
	var last_marker = random_marker
	while random_marker == last_marker and button_markers.size() > 1:
		random_marker = button_markers.pick_random()
	button.position = random_marker.position


func _on_bullet_hit(
	body: Node,
	body_shape_index: int,
	bullet: Dictionary,
	local_shape_index: int,
	shared_area: Area2D
) -> void:
	if body != fb_player or not can_take_damage:
		return
	hit_sound.play()
	can_take_damage = false
	fearbar.value += 10

	await get_tree().create_timer(0.25).timeout
	can_take_damage = true


func _on_game_over_try_again() -> void:
	Spawning.reset_bullets()
	game_over.hide()
	fearbar.value = 50
	can_spawn = true
	set_physics_process(true)
