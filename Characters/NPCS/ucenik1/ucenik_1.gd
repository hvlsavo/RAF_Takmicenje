extends Node2D

@export var phase_1 : Texture2D
@export var phase_2 : Texture2D
@export var phase_3 : Texture2D

signal start_battle(ucenik)

@onready var area2d = $Area2D
@onready var sprite_phase1 = $Phase1
@onready var sprite_phase2 = $Phase2
@onready var sprite_phase3 = $Phase3

func _ready():
    sprite_phase1.texture = phase_1
    sprite_phase2.texture = phase_2
    sprite_phase3.texture = phase_3
    add_to_group("ucenici")

func _on_area_2d_body_entered(body: Node2D) -> void:
    start_battle.emit(self)

# handleri koje battle poziva SAMO za ovog učenika
func _on_battle_half_monster_hp_left():
    sprite_phase1.hide()
    sprite_phase2.show()

func _on_battle_player_won():
    sprite_phase2.hide()
    sprite_phase3.show()
    area2d.set_deferred("monitoring", false)

func _on_battle_player_lost():
    sprite_phase1.show()
    sprite_phase2.hide()
    sprite_phase3.hide()
    area2d.set_deferred("monitoring", false)