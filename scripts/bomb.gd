extends Area2D

@export var req: String = "cutter"

var done: bool = false
var near: bool = false

@export var wire = "red"

@export_group("Beep Settings")
@export var min_beep_interval: float = 0.15
@export var max_beep_interval: float = 1.0
@export var beep_duration: float = 0.15 

@onready var beep_player: AudioStreamPlayer2D = $BeepSFX
var beep_timer: float = 0.0

func _ready() -> void:
	body_entered.connect(_in)
	body_exited.connect(_out)

func _process(delta: float) -> void:
	var manager = get_tree().current_scene
	if not manager:
		return

	if manager.state == "ticking":
		var time_ratio: float = 1.0
		if "time_remaining" in manager and "total_time" in manager and manager.total_time > 0:
			time_ratio = clamp(manager.time_remaining / manager.total_time, 0.0, 1.0)
		
		var current_interval: float = lerpf(min_beep_interval, max_beep_interval, time_ratio)

		beep_timer -= delta
		if beep_player.playing:
			if beep_timer <= 0.0:
				beep_player.stop()
				beep_timer = max(current_interval - beep_duration, 0.01)
		elif beep_timer <= 0.0:
			beep_player.play()
			beep_timer = max(beep_duration, 0.01)
	else:
		if beep_player.playing:
			beep_player.stop()
		beep_timer = 0.0

func _on_body_entered(body: Node2D) -> void:
	if get_tree().current_scene.state != "ticking": return
	if body.is_in_group("player"):
		if req == "pliers":
			body.c_bomb = self
			body.toggle_bomb(true, true)
			body.setcorwire(wire)
		else:
			body.toggle_bomb(true, false)

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.toggle_bomb(false, false)

func _in(b: Node2D) -> void:
	if b.is_in_group("player") and get_tree().current_scene.state == "ticking":
		near = true
		b.tgt = self

func _out(b: Node2D) -> void:
	if b.is_in_group("player"):
		near = false
		if b.tgt == self:
			b.tgt = null
