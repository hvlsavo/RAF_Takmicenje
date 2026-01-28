extends Node2D

var puzzle_blocks = []
@export var target_puzzle_blocks = 16

var puzzle_solved = false
signal secondkey_obtained

var secondkey_dialogue : DialogicTimeline = preload("res://dialogue/timelines/second_key.dtl")

func _physics_process(delta: float) -> void:
    if puzzle_blocks.size() == target_puzzle_blocks and not puzzle_solved:
        puzzle_solved = true
        secondkey_obtained.emit()
        Dialogic.start(secondkey_dialogue)

func _ready():
    for heart in get_tree().get_nodes_in_group("hearts"):
        heart.reset_all_hearts.connect(_on_reset_all_hearts)
        heart.button_pressed.connect(_on_button_pressed)
        heart.button_unpressed.connect(_on_button_unpressed)

func _on_reset_all_hearts():
    for heart in get_tree().get_nodes_in_group("hearts"):
        heart.make_empty()
    puzzle_blocks.clear()
    puzzle_solved = false

func _on_button_pressed(id: int):
    if not puzzle_blocks.has(id):
        puzzle_blocks.append(id)

func _on_button_unpressed(id: int):
    puzzle_blocks.erase(id)