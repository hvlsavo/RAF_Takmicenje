extends CharacterBody2D

@onready var anim_player = $AnimationPlayer


@export var speed :float = 200.0


func _physics_process(delta: float) -> void:
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")

	if input_vector.length() > 0 and speed != 0:
		input_vector = input_vector.normalized()
		velocity = input_vector * speed
		move_and_slide()

		# Play the correct walk animation
		if abs(input_vector.x) > abs(input_vector.y) and speed != 0:
			if input_vector.x > 0:
				anim_player.play("walk_right")
			else:
				anim_player.play("walk_left")
		else:
			if input_vector.y > 0:
				anim_player.play("walk_down")
			else:
				anim_player.play("walk_up")
	else:
		velocity = Vector2.ZERO
		move_and_slide()

		# Stop animation and reset to first frame
		anim_player.stop()
