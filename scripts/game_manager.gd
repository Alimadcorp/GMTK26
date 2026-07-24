extends Node2D

@export var max_time: float = 120.0

var bombs: int = 4
var done: int = 0
var state: String = "intro"
var time: float
var pb: AudioStreamGeneratorPlayback
var phase: float = 0.0
var next_b: float = 0.0
var hz: float = 44100.0
var freq: float = 880.0

@onready var amb = $Ambient
@onready var snd = $Exp
@onready var mod = $CanvasModulate
@onready var p = $Player

func _ready() -> void:
	time = max_time
	snd.stream = AudioStreamGenerator.new()
	snd.stream.mix_rate = hz
	snd.play()
	pb = snd.get_stream_playback()
	mod.color = Color(1, 1, 1, 1)
	await get_tree().create_timer(5.0).timeout
	amb.stop()
	mod.color = Color(0.05, 0.05, 0.05, 1)
	state = "dark"
	p.tut("torch")

func sab() -> void:
	if state == "dark":
		state = "ticking"
		p.no_tut()
		next_b = 1.0

func _process(delta: float) -> void:
	if state == "ticking":
		time -= delta
		next_b -= delta
		if next_b <= 0.0:
			beep()
			var r = time / max_time
			next_b = max(0.1, r * 2.0)
		if time <= 0.0:
			boom()

func beep() -> void:
	var f: int = int(hz * 0.1)
	for i in range(f):
		phase += freq / hz
		var v = sin(phase * 6.28318)
		pb.push_frame(Vector2(v, v))

func defuse() -> void:
	done += 1
	if done >= bombs:
		state = "won"
		snd.stop()

func boom() -> void:
	state = "lost"
	get_tree().reload_current_scene()
