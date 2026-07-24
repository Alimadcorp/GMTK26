extends Area2D

@export var bomb_num: int = 1
@export var req_item: String = "cutter"

@onready var label = $TimerLabel

var is_defused: bool = false
var near_player: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(_delta: float) -> void:
	if near_player and not is_defused:
		var manager = get_tree().current_scene
		if manager and "bomb_timer" in manager:
			label.text = "%02d:%02d" % [int(manager.bomb_timer) / 60, int(manager.bomb_timer) % 60]

func _unhandled_input(event: InputEvent) -> void:
	if near_player and event.is_action_pressed("interact") and not is_defused:
		var player = get_tree().get_first_node_in_group("player")
		if player and req_item in player.inv:
			is_defused = true
			label.text = "DEFUSED"
			var manager = get_tree().current_scene
			if manager and manager.has_method("defuse_bomb"):
				manager.defuse_bomb()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		near_player = true
		label.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		near_player = false
		label.visible = false
