extends Node2D

@onready var light_occluder = $LightOccluder2D
@onready var label = $Label

func _ready():
	generate_text_occluder()
	if not Engine.is_editor_hint():
		label.item_rect_changed.connect(generate_text_occluder)

func _process(_delta):
	if Engine.is_editor_hint():
		generate_text_occluder()
func generate_text_occluder():
	if not is_instance_valid(label) or not is_instance_valid(light_occluder):
		return
		
	var text_to_occlude = label.text
	if text_to_occlude == "":
		light_occluder.occluder = null
		return
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
	
	var font_ascent = ts.font_get_ascent(font_rid, current_font_size)
	for i in range(text_to_occlude.length()):
		var char_code = text_to_occlude.unicode_at(i)
		var glyph_index = ts.font_get_glyph_index(font_rid, current_font_size, char_code, 0)
		var contours = ts.font_get_glyph_contours(font_rid, current_font_size, glyph_index)
		
		for point in contours["points"]:
			var world_point = Vector2(point.x + current_x_offset, point.y)
			final_polygon_points.append(world_point)
			
		current_x_offset += ts.font_get_glyph_advance(font_rid, current_font_size, glyph_index).x
	combined_occluder.polygon = final_polygon_points
	light_occluder.occluder = combined_occluder
	var horizontal_alignment_offset = 0.0
	
	if label.horizontal_alignment == HORIZONTAL_ALIGNMENT_CENTER:
		horizontal_alignment_offset = (label.size.x - current_x_offset) / 2.0
	elif label.horizontal_alignment == HORIZONTAL_ALIGNMENT_RIGHT:
		horizontal_alignment_offset = label.size.x - current_x_offset
	light_occluder.position = label.position + Vector2(horizontal_alignment_offset, font_ascent)
