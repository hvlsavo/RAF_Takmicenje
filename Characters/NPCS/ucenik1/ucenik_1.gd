extends CharacterBody2D

@export var phase_1 : Texture2D
@export var phase_2 : Texture2D
@export var phase_3 : Texture2D
signal start_battle(ucenik)

@onready var area2d = $Area2D
@onready var sprite_phase1 = $Phase1
@onready var sprite_phase2 = $Phase2
@onready var sprite_phase3 = $Phase3
@onready var phase_3_collider = $CollisionShape2D
@onready var alert_sprite = $AlertedAnim
@onready var alert_sound = $AlertedAnim/Alert
@onready var phase1_anim = $Phase1Anim
@onready var phase2_anim = $Phase2Anim

@onready var shadow = $TextureRect

@onready var transition = $Transition
var transition_sound_ended : bool = false

var direction : int = 1
var current_phase : int = 1
var is_defeated : bool = false

func _ready():
	sprite_phase1.texture = phase_1
	sprite_phase2.texture = phase_2
	sprite_phase3.texture = phase_3
	add_to_group("ucenici")

	alert_sprite.modulate.a = 0.0
	
	# Load saved state if it exists
	var state_key = name
	if Manager.ucenik_states.has(state_key):
		var state = Manager.ucenik_states[state_key]
		current_phase = state.get("phase", 1)
		is_defeated = state.get("defeated", false)
		_restore_phase(current_phase, is_defeated)
	
	# If defeated, disable interactions
	if is_defeated:
		area2d.set_deferred("monitoring", false)
		shadow.hide()

func _physics_process(delta: float) -> void:
	phase1_anim.play("idle")


func _restore_phase(phase: int, defeated: bool) -> void:
	"""Restore ucenik to saved phase"""
	if defeated:
		sprite_phase1.hide()
		sprite_phase2.hide()
		sprite_phase3.hide()
		shadow.hide()
		phase_3_collider.disabled = true
		area2d.set_deferred("monitoring", false)
	elif phase == 1:
		sprite_phase1.show()
		sprite_phase2.hide()
		sprite_phase3.hide()
		phase1_anim.play("idle")
	elif phase == 2:
		sprite_phase1.hide()
		sprite_phase2.show()
		sprite_phase3.hide()
		phase2_anim.play("idle")
	elif phase == 3:
		sprite_phase1.hide()
		sprite_phase2.hide()
		sprite_phase3.show()
		phase_3_collider.disabled = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var tween = get_tree().create_tween()
		tween.tween_property(alert_sprite, "modulate:a", 1.0, 0.3).set_trans(Tween.TRANS_SINE)
		tween.tween_property(alert_sprite, "modulate:a", 0.0, 0.3).set_trans(Tween.TRANS_SINE)
		alert_sound.play()
		start_battle.emit(self)

# handleri koje battle poziva SAMO za ovog učenika
func _on_battle_half_monster_hp_left():
	current_phase = 2
	Manager.ucenik_states[name] = {"phase": current_phase, "defeated": is_defeated}
	transition.play()
	sprite_phase1.hide()
	sprite_phase2.show()
	phase2_anim.play("idle")

func _on_battle_player_won():
	is_defeated = true
	current_phase = 3
	Manager.ucenik_states[name] = {"phase": current_phase, "defeated": is_defeated}
	phase_3_collider.disabled = false
	sprite_phase2.hide()
	sprite_phase3.show()
	area2d.set_deferred("monitoring", false)
	shadow.hide()

func _on_battle_player_lost():
	is_defeated = true
	Manager.ucenik_states[name] = {"phase": current_phase, "defeated": is_defeated}
	var tween = get_tree().create_tween()
	tween.set_parallel()
	tween.tween_property(sprite_phase1, "modulate:a", 0.0, 1)
	tween.tween_property(shadow, "modulate:a", 0.0, 1)
	await tween.finished
	phase_3_collider.disabled = true
	sprite_phase1.hide()
	sprite_phase2.hide()
	shadow.hide()
	area2d.set_deferred("monitoring", false)
