extends Node2D

@onready var animation_player = $AnimationPlayer
@onready var area_2d = $Area2D

signal final_battle_started

func _ready() -> void:
    animation_player.play("idle")


func _on_area_2d_body_entered(body:Node2D) -> void:
    if body.is_in_group("player"):
        print("oh ne")
        final_battle_started.emit()
