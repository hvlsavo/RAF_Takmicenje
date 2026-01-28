extends Node2D

@onready var area2d: Area2D = $Area2D
@onready var sprite: Node2D = $TileMapLayer

var in_area: bool = false
var used: bool = false

var first_key_timeline: DialogicTimeline = preload("res://dialogue/timelines/first_key.dtl")

signal first_key_obtained
signal interaction_started
signal interaction_over


func _physics_process(delta: float) -> void:
	if in_area and not used and Input.is_action_just_pressed("ui_accept"):
		interact()


func interact() -> void:
	interaction_started.emit()

	used = true
	in_area = false

	area2d.monitoring = false
	sprite.hide()

	first_key_obtained.emit()

	Dialogic.start(first_key_timeline)
	await Dialogic.timeline_ended

	interaction_over.emit()
	set_physics_process(false)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not used:
		in_area = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		in_area = false
