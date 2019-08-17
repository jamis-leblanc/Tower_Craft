extends "res://Scripts/building.gd"

var nbr_scientist = 0

func _init():
	reference = "res://Scenes/laboratory.tscn"
	size = 3
	cost = 0
	tile_index = 9
	building_time = 5
	UI_offset = Vector2(64,-64)
	tile_offset = Vector2(-2,-2)
	offset = fmod(size,2)
	_name = "Laboratory"
	popup_UI = "res://Scenes/Popup_science_building.tscn"

#
#func _on_prod_timer_timeout():
#	world.add_research(nbr_scientist)
