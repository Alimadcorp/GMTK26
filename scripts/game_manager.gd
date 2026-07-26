extends Node2D

@export var max_time: float = 300.0

@export var freq: float = 1200.0

@export var start_beep_duration: float = 0.6
@export var end_beep_duration: float = 0.1

@export var start_beep_delay: float = 3.0
@export var end_beep_delay: float = 0.5

@export var stages_count: int = 5

var bombs: int = 4
var done: int = 0
var state: String = "intro"
var time: float
var pb: AudioStreamGeneratorPlayback
var phase: float = 0.0
var next_b: float = 0.0
var hz: float = 44100.0

@onready var amb = $Ambient
@onready var snd = $Exp
@onready var mod = $CanvasModulate
@onready var p = $Player

func _ready() -> void:
	time = max_time
	
	var generator = AudioStreamGenerator.new()
	generator.mix_rate = hz
	generator.buffer_length = 0.5
	snd.stream = generator
	snd.play()
	await get_tree().create_timer(5.0).timeout
	pb = snd.get_stream_playback()
	$Lout.play()
	p.spd = p.speed
	
	amb.stop()
	mod.color = Color(0.03, 0.03, 0.03, 1)
	state = "dark"
	p.tut("torch")

func sab() -> void:
	if state == "dark":
		state = "ticking"
		p.no_tut()
		next_b = 0.1
		p.tut("oh_shit")

func _process(delta: float) -> void:
	if state == "ticking":
		time -= delta
		next_b -= delta
		
		if next_b <= 0.0:
			var r: float = clamp(time / max_time, 0.0, 1.0)
			var stage_progress: float = 1.0 - r
			var step: float = floor(stage_progress * float(stages_count)) / float(max(1, stages_count - 1))
			step = clamp(step, 0.0, 1.0)
			var current_duration = lerp(start_beep_duration, end_beep_duration, step)
			var current_delay = lerp(start_beep_delay, end_beep_delay, step)
			
			beep(current_duration)
			next_b = current_delay
			
		if time <= 0.0:
			boom()

func beep(duration: float) -> void:
	if not pb:
		pb = snd.get_stream_playback() if snd.playing else null
		if not pb:
			return

	phase = 0.0
	var frames_to_push: int = int(hz * duration)
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
	$Player.expl()
	await get_tree().create_timer(6).timeout
	get_tree().reload_current_scene()
