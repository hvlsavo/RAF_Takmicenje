extends Node2D

@onready var empty = $empty_heart
@onready var full = $full_heart
@onready var click = $click
signal button_pressed(id: int)     
signal button_unpressed(id: int)
signal reset_all_hearts()

var already_pressed = false
@export var heart_id: int = 0    

func _heart_change():
    if already_pressed:
        reset_all_hearts.emit()
    else:
        full.show()
        empty.hide()
        already_pressed = true
        button_pressed.emit(heart_id)

func make_empty():
    empty.show()
    full.hide()
    already_pressed = false
    button_unpressed.emit(heart_id)

func _on_area_2d_area_entered(area:Area2D) -> void:
    click.play()
    _heart_change()
