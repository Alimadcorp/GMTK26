extends Node2D

@export var fuse_time: float = 120.0

var bomb_count: int = 4
var defused_count: int = 0
var state: String = "intro"
var bomb_timer: float

@onready var audio_tick = $Exp

func _ready() -> void:
	bomb_timer = fuse_time
	start_intro()

func start_intro() -> void:
	await get_tree().create_timer(5.0).timeout
	$Ambient.stop()
	state = "dark"

func trigger_sabotage() -> void:
	if state == "dark":
		state = "ticking"
		audio_tick.play()

func _process(delta: float) -> void:
	if state == "ticking":
		bomb_timer -= delta
		var ratio = 1.0 - (bomb_timer / fuse_time)
		audio_tick.pitch_scale = clamp(1.0 + ratio * 1.5, 1.0, 2.5)
		
		if bomb_timer <= 0.0:
			explode_all()

func defuse_bomb() -> void:
	defused_count += 1
	if defused_count >= bomb_count:
		state = "won"
		audio_tick.stop()

func explode_all() -> void:
	state = "lost"
	get_tree().reload_current_scene()
