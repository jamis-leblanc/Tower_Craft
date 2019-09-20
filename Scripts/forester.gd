extends "res://Scripts/building.gd"

var _Tree = load("res://Scripts/tree.gd")
var on_cooldown = false
var max_range = 8

signal new_tree(x,y,growth)

func _init():
	reference = "res://Scenes/forester.tscn"
	size = 2
	cost = 200
	tile_index = 8
	mouse_offset = fmod(size+1,2) * Vector2(16,16)	# mouse_offset = 16,16 if size is en even number,  0,0 otherwise
	position_offset = fmod(size,2) * Vector2(16,16)	# position_offset = 16,16 if size is en odd number,  0,0 otherwise
	tile_offset = floor(size/2) * Vector2(-1,-1)	# tile_offset = (0,0) is size  = 1, (-1,-1) otherwise
	_name = "Forester Hut"


func _ready():
	self.connect("new_tree",structure_manager,"new_tree")


func _process(delta):
	if state == enums.building_states.operate:
		update_production()


func update_production():
	if is_working == false : return
	if on_cooldown == true : return
	else :
		var pop_succes = false
		var pop_radius = size * 16 * 1.45
		for i in range(max_range) :
			var pop_direction = rand_range(0,360)
			var pop_cell_x = self.position.x + sin(pop_direction) * pop_radius
			var pop_cell_y = self.position.y + cos(pop_direction) * pop_radius
			var tile = map.world_to_map(Vector2(pop_cell_x,pop_cell_y))
			if map.get_cell(tile.x,tile.y) == 5 or map.get_cell(tile.x,tile.y) == 3:
				self.emit_signal("new_tree",tile.x,tile.y,0)
				pop_succes = true
				$Spawn_cooldown.start()
				on_cooldown = true
				break
			pop_radius += 32


func _on_Spawn_cooldown_timeout():
	on_cooldown = false
