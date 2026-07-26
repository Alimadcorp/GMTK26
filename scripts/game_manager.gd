extends Node2D

@export var max_time: float = 180.0 #The  bomb time I think (default to 300) / 10 min

@export var stages_count: int = 6

var bombs: int = 4
var done: int = 0
var state: String = "intro"
var time: float
@onready var amb = $Ambient
@onready var mod = $CanvasModulate
@onready var p = $Player

func _ready() -> void:
	await get_tree().create_timer(5).timeout #To run the intro first 
	time = max_time
	
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
		p.tut("oh_shit")

func _process(delta: float) -> void:
	if state == "ticking":
		time -= delta
			
		if time <= 0.0:
			boom()

func defuse() -> void:
	done += 1
	if done >= bombs:
		state = "won"

func boom() -> void:
	state = "lost"
	$Player.expl()
	await get_tree().create_timer(6).timeout
	get_tree().reload_current_scene()
