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
	
	# ho lee beep generator
	var generator = AudioStreamGenerator.new()
	generator.mix_rate = hz
	generator.buffer_length = 0.5
	snd.stream = generator
	snd.play()
	await get_tree().create_timer(5.0).timeout
	pb = snd.get_stream_playback()
	
	amb.stop()
	mod.color = Color(0.05, 0.05, 0.05, 1)
	state = "dark"
	p.tut("torch")

func sab() -> void:
	if state == "dark":
		state = "ticking"
		p.no_tut()
		next_b = 0.1

func _process(delta: float) -> void:
	if state == "ticking":
		time -= delta
		next_b -= delta
		if next_b <= 0.0:
			beep()
			var r = time / max_time
			next_b = max(0.08, r * 1.5)
		if time <= 0.0:
			boom()

func beep() -> void:
	print("beeeeeep")
	if not pb:
		pb = snd.get_stream_playback() if snd.playing else null
		if not pb:
			return

	phase = 0.0
	var frames_to_push: int = int(hz * 0.05)
	var available_frames: int = pb.get_frames_available()
	
	var count = min(frames_to_push, available_frames)
	for i in range(count):
		phase = fmod(phase + freq / hz, 1.0)
		var v = sin(phase * TAU) * 0.3
		pb.push_frame(Vector2(v, v))

func defuse() -> void:
	done += 1
	if done >= bombs:
		state = "won"
		snd.stop()

func boom() -> void:
	state = "lost"
	get_tree().reload_current_scene()
