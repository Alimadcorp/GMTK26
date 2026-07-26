extends Area2D

@export var req: String = "cutter"

var done: bool = false
var near: bool = false

@export var wire = "red"

@export_group("Beep Pitch Settings")
@export var start_pitch: float = 0.9
@export var end_pitch: float = 1.1

@export_group("Beep Interval Settings")
@export var start_interval: float = 3.0
@export var end_interval: float = 0.15

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
		var max_t: float = manager.max_time if manager.max_time > 0 else 1.0
		var progress: float = 1.0 - clamp(manager.time / max_t, 0.0, 1.0)

		var steps: int = max(1, manager.stages_count if "stages_count" in manager else 6)
		
		var current_step: float = floor(progress * steps) / float(steps)

		var current_interval: float = lerpf(start_interval, end_interval, current_step)
		var current_pitch: float = max(0.01, lerpf(start_pitch, end_pitch, current_step))
		
		beep_player.pitch_scale = current_pitch

		beep_timer -= delta
		if beep_timer <= 0.0:
			if beep_player.playing:
				beep_player.stop()
			beep_player.play()
			beep_timer = max(0.05, current_interval)
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
