extends Node2D

var starting_dialogue : DialogicTimeline = preload("res://dialogue/timelines/starting.dtl")

func _ready():
	_start_game()


func _start_game():
	Dialogic.start(starting_dialogue)
	await Dialogic.timeline_ended
	get_tree().change_scene_to_file("res://Main/main.tscn")
