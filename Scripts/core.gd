extends "res://Scripts/building.gd"

func _init():
	reference = "res://Scenes/core.tscn"
	food = 4
	size = 3
	tile_index = 9
	offset = fmod(size,2)
	UI_offset = Vector2(64,-64)
	tile_offset = Vector2(-2,-2)
	_name = "Castle"
	popup_UI = "res://Scenes/Popup_building_info.tscn"

func _ready():
	$Label.text = str(self)
	world.add_food(food)
	get_tree().call_group("UI", "_update")