extends Node2D


@onready var area2d = $Area2D
@onready var alert_sprite = $AlertedAnim
@onready var alert_sound = $AlertedAnim/Alert
@onready var boss_anim = $AnimationPlayer
@onready var sprite = $Sprite2D
@onready var small_sh = $small_shadow
@onready var big_sh = $ Big_shadow
signal start_miniboss_battle(miniboss)

func _physics_process(delta: float) -> void:
    boss_anim.play("idle")


func _on_area_2d_body_entered(body:Node2D) -> void:
    if body.is_in_group("player"):
        var tween = get_tree().create_tween()
        tween.tween_property(alert_sprite, "modulate:a", 1.0, 0.3).set_trans(Tween.TRANS_SINE)
        tween.tween_property(alert_sprite, "modulate:a", 0.0, 0.3).set_trans(Tween.TRANS_SINE)
        alert_sound.play()
        start_miniboss_battle.emit(self)
        area2d.set_deferred("monitoring", false)


#PLACEHOLDER NAPRAVITI GAME OVER
func _on_battle_player_lost():
    print("PLAYER LOST TO MINI BOSS")

func _on_battle_player_won():
    var tween = get_tree().create_tween()
    tween.set_parallel()
    tween.tween_property(sprite, "modulate:a", 0.0, 0.5)
    tween.tween_property(small_sh, "modulate:a", 0.0, 0.5)
    tween.tween_property(big_sh, "modulate:a", 0.0, 0.5)
    await tween.finished
    area2d.set_deferred("monitoring", false)

