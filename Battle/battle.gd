extends Control

@onready var label = $Label
@onready var act_button = $Buttons/ActButton
@onready var respond_button = $Buttons/RespondButton
@onready var silent_button = $Buttons/SilentButton

var monster_hp := 10
var player_hp := 10
var battle_over := false
var first_act_done := false
var dialogue_state := "idle"
var last_monster_response_index := -1
var half_emitted := false

# referenca na učenika sa kojim se trenutno boriš
var current_ucenik: Node = null

signal player_won
signal player_lost
signal half_monster_hp_left

var monster_questions = [
	"Šta misliš o muzici?",
	"Koja ti je omiljena boja?",
	"Da li voliš da putuješ?",
	"Šta te najviše raduje?",
	"Koja ti je omiljena hrana?",
	"Da li voliš knjige?",
	"Šta misliš o sportu?",
	"Koji ti je omiljeni film?",
	"Da li voliš životinje?",
	"Šta te inspiriše?"
]

var monster_responses = [
	"Meni se sviđa.",
	"Ne sviđa mi se.",
	"Zanimljivo razmišljanje.",
	"Možda je tako.",
	"To je baš lepo."
]

func start(ucenik: Node):
	current_ucenik = ucenik
	visible = true
	_reset_battle()
	label.text = "Bitka počinje! Čudovište te gleda radoznalo."

func _reset_battle():
	monster_hp = 10
	player_hp = 10
	battle_over = false
	first_act_done = false
	dialogue_state = "idle"
	half_emitted = false
	act_button.disabled = false
	respond_button.disabled = false
	silent_button.disabled = false
	act_button.text = "Započni razgovor"

func check_battle_end() -> bool:
	if monster_hp <= 0:
		label.text = "Čudovište je zapravo samo dete."
		battle_over = true
		_disable_buttons()
		_delayed_player_won()
		return true
	elif player_hp <= 0:
		label.text = "Pobegao si od srama."
		battle_over = true
		_disable_buttons()
		_delayed_player_lost()
		return true
	elif not half_emitted and monster_hp <= 5:
		half_emitted = true
		if current_ucenik:
			current_ucenik._on_battle_half_monster_hp_left()
		half_monster_hp_left.emit()
	return false

func _disable_buttons():
	act_button.disabled = true
	respond_button.disabled = true
	silent_button.disabled = true

func get_random_response() -> String:
	var idx = randi() % monster_responses.size()
	while idx == last_monster_response_index:
		idx = randi() % monster_responses.size()
	last_monster_response_index = idx
	return monster_responses[idx]

func _delayed_player_won() -> void:
	await get_tree().create_timer(1.5).timeout
	if current_ucenik:
		current_ucenik._on_battle_player_won()
	player_won.emit()
	visible = false

func _delayed_player_lost() -> void:
	await get_tree().create_timer(1.0).timeout
	if current_ucenik:
		current_ucenik._on_battle_player_lost()
	player_lost.emit()
	visible = false

# dugmad
func _on_act_button_pressed():
	if battle_over: return
	if not first_act_done:
		monster_hp -= 2
		label.text = "Pitao si čudovište kako mu je prošao dan."
		if check_battle_end(): return
		label.text += "\nČudovište odgovara: 'Bio je dobar, a tvoj?'"
		dialogue_state = "monster_waiting"
		first_act_done = true
		act_button.text = "Pitaj"
	else:
		label.text = "Postavio si novo pitanje čudovištu."
		monster_hp -= 2
		if check_battle_end(): return
		label.text += "\nČudovište odgovara: '" + get_random_response() + "'"
		dialogue_state = "idle"

func _on_respond_button_pressed():
	if battle_over: return
	if dialogue_state == "monster_waiting":
		monster_hp -= 1
		label.text = "Odgovorio si čudovištu."
		if check_battle_end(): return
		label.text += "\nČudovište pita: '" + monster_questions[randi() % monster_questions.size()] + "'"
		dialogue_state = "player_responded"
	elif dialogue_state == "player_responded":
		label.text = "Odgovorio si na pitanje čudovišta."
		label.text += "\nČudovište kaže: '" + get_random_response() + "'"
		dialogue_state = "idle"

func _on_silent_button_pressed():
	if battle_over: return
	label.text = "Odlučio si da ćutiš."
	player_hp -= 2
	if check_battle_end(): return
	label.text += "\nČudovište ćuti i gleda te čudno."
	dialogue_state = "idle"
