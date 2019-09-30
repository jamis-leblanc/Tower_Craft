extends "res://Scripts/building.gd"

func _init():
	reference = "res://Scenes/core.tscn"
	food = 8
	size = 3
	health_max = units_stats.core_health_max
	health = health_max
	$ProgressBar.max_value = health_max
	tile_index = 9
	
	mouse_offset = fmod(size+1,2) * Vector2(16,16)	# mouse_offset = 16,16 if size is en even number,  0,0 otherwise
	position_offset = fmod(size,2) * Vector2(16,16)	# position_offset = 16,16 if size is en odd number,  0,0 otherwise
	tile_offset = floor(size/2) * Vector2(-1,-1)	# tile_offset = (0,0) is size  = 1, (-1,-1) otherwise
	
	UI_offset = Vector2(64,-64)
	_name = "Castle"
	popup_UI = "res://Scenes/Popup_building_info.tscn"

func _ready():
	$Label.text = str(self)
	world.add_food(food)
	get_tree().call_group("UI", "_update")