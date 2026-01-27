extends Control

signal try_again
func _on_try_again_pressed() -> void:
    try_again.emit()
    visible = false
