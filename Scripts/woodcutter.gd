extends "res://Scripts/building.gd"


func _init():
	reference = "res://Scenes/woodcutter.tscn"
	size = 2
	tile_index = 13
	building_time = 5
	offset = fmod(size,2)
	_name = "Woodcutter hut"


func check_position_validity():
	is_valid = true
	for j in size :
			for i in size :
				var cell_type = map.get_cell(tile.x-(size/2+offset)+i,tile.y-(size/2+offset)+j)
				if cell_type != 5 :
					is_valid = false
	if is_valid == false :	$Sprite.set_self_modulate(Color(1,0.25,0.25,1))
	else  : 				$Sprite.set_self_modulate(Color(1,1,1,1))

