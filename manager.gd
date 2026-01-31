extends Node

var keys = 3
var is_final_boss_defeated: bool = false
var is_mini_boss_defeated: bool = false
var first_key_obtained: bool = false
var second_key_obtained: bool = false

# Ucenik states (by node name)
var ucenik_states: Dictionary = {}  # {"ucenik_1": {"phase": 3, "defeated": true}, ...}

