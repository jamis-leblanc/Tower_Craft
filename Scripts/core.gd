extends "res://Scripts/building.gd"

func _init():
	reference = "res://Scenes/core.tscn"
	size = 3
	tile_index = 9
#	offset = floor(size/2)
	offset = fmod(size,2)
	UI_offset = Vector2(32,-64)
	tile_offset = Vector2(-2,-2)
	_name = "Castle"

func _ready():
	$Label.text = str(self)
	