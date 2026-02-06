extends Node2D

@onready var bad_ending_shadows = $Bad_ending
@onready var npcs = $Sprites
@onready var music = $music
func _ready() -> void:
    if Manager.good_ending == false:
        music.pitch_scale = 0.65
        bad_ending_shadows.show()
        npcs.hide()
    self.modulate.a = 0
    var tween = get_tree().create_tween()
    tween.tween_property(self, "modulate:a", 1, 3)
    await tween.finished
    var timer = get_tree().create_timer(5)
    await timer.timeout
    var tween2 = get_tree().create_tween()
    tween2.tween_property(self, "modulate:a", 0, 3)
    await tween2.finished
    get_tree().change_scene_to_file("res://menus/mainmenu.tscn")