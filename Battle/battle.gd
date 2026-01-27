extends Control

@onready var label = $Panel/Label
@onready var act_button = $Buttons/ActButton
@onready var respond_button = $Buttons/RespondButton
@onready var silent_button = $Buttons/SilentButton
@onready var stare_button = $StareButton
var monster_hp := 10
var player_hp := 10
var battle_over := false
var first_act_done := false
var dialogue_state := "idle"
var last_monster_response_index := -1
var half_emitted := false

# mini boss vars
var is_mini_boss = false
@onready var fearbar = $FearBar
@onready var fearbar_label = $Label2
var silent_count = 0
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
	if is_mini_boss and ucenik.is_in_group("mini_boss"):
		fearbar.visible = true
		fearbar_label.visible = true
		stare_button.visible = true
		fearbar.value = 75
		print("mini")
		label.text = "Sva svetla trepere,ne gleda te jedno čudovište,već više njih."


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
	act_button.text = "Pokreni razgovor."

func check_battle_end() -> bool:
	if is_mini_boss:
		if fearbar.value >= fearbar.max_value:
			label.text = "Glasovi se stapaju u šum."
			player_hp = 0
			battle_over = true
			_disable_buttons()
			_delayed_player_lost()
			return true
		if fearbar.value <= 0:
			label.text = "Oči se gase, jedno po jedno.Ostaju samo deca.Ne čudovišta."
			monster_hp = 0
			battle_over = true
			_disable_buttons()
			_delayed_player_won()
			return true
	else:
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
	silent_count = 0
	if is_mini_boss:
		print(silent_count)
		label.text = "Pokušavaš da kažeš nešto normalno.Rečenica ti zapne na pola.Oni kažu: \"Zašto se uopšte trudiš?\""
		fearbar.value += 10
		if check_battle_end(): return
	else:
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
	silent_count = 0
	if is_mini_boss:
		print(silent_count)
		if not first_act_done:
			label.text = "Odgovorio si iskreno.Nekoliko ociju su se zatvorile."
			fearbar.value -= 15
			first_act_done = true
		else:
			label.text = "Odgovaraš tek kad su te već procenili.Kažu ti: \"Kasno\""
	else:
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
	if is_mini_boss:
		silent_count += 1
		print(silent_count)
		if silent_count == 1:
			label.text = "Odlučio si da ćutiš. Glasovi šapuću: \"Zašto ne govoriš?\""
			fearbar.value += 20
		elif silent_count == 5:
			label.text = "Previše tišine… probaj kasnije."
		elif silent_count >= 2 and silent_count <= 4:
			label.text = "I dalje ćutiš. Neko izgleda zbunjeno..."
			fearbar.value -= 10
	else:
		if battle_over: return
		label.text = "Odlučio si da ćutiš."
		player_hp -= 2
		if check_battle_end(): return
		label.text += "\nČudovište ćuti i gleda te čudno."
		dialogue_state = "idle"


func _on_stare_button_pressed() -> void:
	silent_count = 0
	if is_mini_boss:
		label.text = "Gledaš u njih, ne trepćući.Ne znaš šta će se desiti."
		var rng = RandomNumberGenerator.new()
		var chance_of_fear = rng.randf_range(0.0, 1.0)
		if chance_of_fear <= 0.5:
			label.text += "\nJedno po jedno, oči se zatvaraju."
			fearbar.value -= 25
		else:
			label.text += "\nGlasovi se pojačavaju u tvojoj glavi."
			fearbar.value += 15
		if check_battle_end(): return
