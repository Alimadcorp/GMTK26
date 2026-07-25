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

@onready var amb: AudioStreamPlayer2D = $Ambient
@onready var snd: AudioStreamPlayer2D = $Exp
@onready var mod: CanvasModulate = $CanvasModulate
@onready var p = $Player

func _ready() -> void:
	time = max_time
	
	_spawn_all_objects()
	
	var generator: AudioStreamGenerator = AudioStreamGenerator.new()
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

func _spawn_all_objects() -> void:
	# Spawn bombs
	var bomb_scene: PackedScene = load("res://bomb.tscn")
	var bomb_positions: Array = [
		Vector2(-600, 400), Vector2(600, 400),
		Vector2(-600, -400), Vector2(600, -400),
	]
	var bombs_parent: Node2D = Node2D.new()
	bombs_parent.name = "Bombs"
	add_child(bombs_parent)
	
	for i in range(bomb_positions.size()):
		var bomb: Area2D = bomb_scene.instantiate()
		bomb.name = "Bomb%d" % (i + 1)
		bomb.position = bomb_positions[i]
		bomb.scale = Vector2(5, 5)
		bomb.bomb_num = i + 1
		bomb.add_to_group("bomb_node")
		bombs_parent.add_child(bomb)
	
	# Spawn items
	var items_parent: Node2D = Node2D.new()
	items_parent.name = "Items"
	add_child(items_parent)
	
	# Cutter
	var cutter_scene: PackedScene = load("res://cutter.tscn")
	var cutter: Area2D = cutter_scene.instantiate()
	cutter.name = "Cutter"
	cutter.position = Vector2(100, 200)
	cutter.scale = Vector2(6, 6)
	items_parent.add_child(cutter)
	
	# Master Key
	var mkey_scene: PackedScene = load("res://master_key.tscn")
	var mkey: Area2D = mkey_scene.instantiate()
	mkey.name = "MasterKey"
	mkey.position = Vector2(-200, 500)
	mkey.scale = Vector2(6, 6)
	items_parent.add_child(mkey)
	
	# Notes
	var note_scene: PackedScene = load("res://note.tscn")
	var notes_data: Array = [
		["Note1", Vector2(-300, -100), "Cut the RED wire first - never cut blue or green"],
		["Note2", Vector2(300, -100), "The final bomb uses a keyhole - find the master key in the office"],
		["Note3", Vector2(0, 500), "Reset the fuse box before the bombs start ticking"],
	]
	for nd in notes_data:
		var note: Area2D = note_scene.instantiate()
		note.name = nd[0]
		note.position = nd[1]
		note.text = nd[2]
		items_parent.add_child(note)

func sab() -> void:
	if state == "dark":
		state = "ticking"
		p.no_tut()
		next_b = 0.1
		_start_bomb_timers()

func _start_bomb_timers() -> void:
	var all_bombs: Array = get_tree().get_nodes_in_group("bomb_node")
	for b in all_bombs:
		if b.has_method("start_ticking"):
			b.start_ticking()

func _process(delta: float) -> void:
	if state == "ticking":
		time -= delta
		next_b -= delta
		if next_b <= 0.0:
			beep()
			var r: float = time / max_time
			next_b = max(0.08, r * 1.5)
		if time <= 0.0:
			boom()

func beep() -> void:
	if not pb:
		pb = snd.get_stream_playback() if snd.playing else null
		if not pb:
			return

	phase = 0.0
	var frames_to_push: int = int(hz * 0.05)
	var available_frames: int = pb.get_frames_available()
	
	var count: int = min(frames_to_push, available_frames)
	for i in range(count):
		phase = fmod(phase + freq / hz, 1.0)
		var v: float = sin(phase * TAU) * 0.3
		pb.push_frame(Vector2(v, v))

func defuse() -> void:
	done += 1
	if done >= bombs:
		state = "won"
		snd.stop()
		p.txt("All bombs defused!", 5.0)

func boom() -> void:
	state = "lost"
	get_tree().reload_current_scene()
