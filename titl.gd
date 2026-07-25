@tool # Enables live rendering updates directly inside the Godot editor
extends Node2D

@onready var light_occluder = $LightOccluder2D
@onready var label = $Label

func _ready():
	# Build the vector shape data on launch
	generate_text_occluder()
	
	# Connect boundary shifts to update shadows smoothly at runtime
	if not Engine.is_editor_hint():
		label.item_rect_changed.connect(generate_text_occluder)

func _process(_delta):
	# Forces live updates inside the editor when typing text or editing styles
	if Engine.is_editor_hint():
		generate_text_occluder()
func generate_text_occluder():
	# Node validation check
	if not is_instance_valid(label) or not is_instance_valid(light_occluder):
		return
		
	var text_to_occlude = label.text
	if text_to_occlude == "":
		light_occluder.occluder = null
		return

	# 1. Fetch current font configurations from the label node settings
	var current_font = label.get_theme_font("font")
	var font_rids = current_font.get_rids()
	
	if font_rids.is_empty():
		return
	var font_rid = font_rids[0]
	
	var current_font_size = label.get_theme_font_size("font_size")
	if current_font_size <= 0:
		current_font_size = 16 
	
	var ts = TextServerManager.get_primary_interface()
	var combined_occluder = OccluderPolygon2D.new()
	combined_occluder.closed = false
	
	var current_x_offset = 0.0
	var final_polygon_points = PackedVector2Array()
	
	# Fetch font metrics for exact vertical alignment
	var font_ascent = ts.font_get_ascent(font_rid, current_font_size)
	
	# 2. Iterate through each letter glyph path outline
	for i in range(text_to_occlude.length()):
		var char_code = text_to_occlude.unicode_at(i)
		var glyph_index = ts.font_get_glyph_index(font_rid, current_font_size, char_code, 0)
		var contours = ts.font_get_glyph_contours(font_rid, current_font_size, glyph_index)
		
		for point in contours["points"]:
			# Keep positive point.y to avoid horizontal/vertical mirror inversion
			var world_point = Vector2(point.x + current_x_offset, point.y)
			final_polygon_points.append(world_point)
			
		current_x_offset += ts.font_get_glyph_advance(font_rid, current_font_size, glyph_index).x
		
	# 3. Mount text geometries to the active 2D light processor
	combined_occluder.polygon = final_polygon_points
	light_occluder.occluder = combined_occluder
	
	# 4. Handle Alignment Layout Computations
	var horizontal_alignment_offset = 0.0
	
	if label.horizontal_alignment == HORIZONTAL_ALIGNMENT_CENTER:
		horizontal_alignment_offset = (label.size.x - current_x_offset) / 2.0
	elif label.horizontal_alignment == HORIZONTAL_ALIGNMENT_RIGHT:
		horizontal_alignment_offset = label.size.x - current_x_offset

	# Align y-position cleanly to the top baseline of the Label
	light_occluder.position = label.position + Vector2(horizontal_alignment_offset, font_ascent)
