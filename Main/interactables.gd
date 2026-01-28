extends Node



var dialogue_locked = false
signal interaction_started
signal interaction_over


#lockers
var lockers_timeline : DialogicTimeline = load("res://dialogue/timelines/lockers.dtl")
var is_player_near_lockers = false

#entrance_door
var is_player_near_entrance_door = false
var entrance_door_timeline : DialogicTimeline = load("res://dialogue/timelines/entrance_door.dtl")

#vending masine
var is_player_near_vending_machine = false
var vending_machine_timeline : DialogicTimeline = load("res://dialogue/timelines/vending.dtl")

#lounge lockers
var is_player_near_lounge_lockers = false
var lounge_lockers_timeline : DialogicTimeline = load("res://dialogue/timelines/lounge_lockers.dtl")

func _physics_process(delta: float) -> void:
    if is_player_near_lockers and Input.is_action_just_pressed("ui_accept") and dialogue_locked == false:
        _check_lockers()
    if is_player_near_entrance_door and Input.is_action_just_pressed("ui_accept") and dialogue_locked == false:
        _check_entrance_door()
    if is_player_near_vending_machine and Input.is_action_just_pressed("ui_accept") and dialogue_locked == false:
        _check_vending_machine()
    if is_player_near_lounge_lockers and Input.is_action_just_pressed("ui_accept") and dialogue_locked == false:
        _check_lounge_lockers()

func _on_lockers_body_entered(body:Node2D) -> void:
    if body.is_in_group("player"):
        is_player_near_lockers = true

func _on_lockers_body_exited(body:Node2D) -> void:
    if body.is_in_group("player"):
        is_player_near_lockers = false

func _check_lockers() -> void:
    dialogue_locked = true
    Dialogic.start(lockers_timeline)
    interaction_started.emit()
    await Dialogic.timeline_ended
    interaction_over.emit()
    dialogue_locked = false

func _on_entrance_door_body_entered(body:Node2D) -> void:
    if body.is_in_group("player"):
        is_player_near_entrance_door = true


func _on_entrance_door_body_exited(body:Node2D) -> void:
    if body.is_in_group("player"):
        is_player_near_entrance_door = false

func _check_entrance_door() -> void:
    dialogue_locked = true
    Dialogic.start(entrance_door_timeline)
    interaction_started.emit()
    await Dialogic.timeline_ended
    interaction_over.emit()

func _on_vending_body_entered(body:Node2D) -> void:
    if body.is_in_group("player"):
        is_player_near_vending_machine = true

func _on_vending_body_exited(body:Node2D) -> void:
    if body.is_in_group("player"):
        is_player_near_vending_machine = false

func _check_vending_machine() -> void:
    dialogue_locked = true
    Dialogic.start(vending_machine_timeline)
    interaction_started.emit()
    await Dialogic.timeline_ended
    interaction_over.emit()
    dialogue_locked = false


func _on_lounge_lockers_body_entered(body:Node2D) -> void:
    if body.is_in_group("player"):
        is_player_near_lounge_lockers = true

func _on_lounge_lockers_body_exited(body:Node2D) -> void:
    if body.is_in_group("player"):
        is_player_near_lounge_lockers = false

func _check_lounge_lockers() -> void:
    dialogue_locked = true
    Dialogic.start(lounge_lockers_timeline)
    interaction_started.emit()
    await Dialogic.timeline_ended
    interaction_over.emit()
    dialogue_locked = false
