extends Control


func _ready() -> void:
	self.modulate.a = 0
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 1, 2)
func _on_button_pressed() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color.BLACK, 1.0)
	await tween.finished
	get_tree().change_scene_to_file("res://Main/starting.tscn")


func _on_button_2_pressed() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color.BLACK, 1.0)
	await tween.finished
	get_tree().quit()
