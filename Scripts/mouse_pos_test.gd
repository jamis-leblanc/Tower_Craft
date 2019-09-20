extends Node2D

onready var map = get_tree().get_root().get_node("/root/World/nav/map_structure")
onready var map_enn =  get_tree().get_root().get_node("/root/World/map_enn")

var size = 3
var mouse_offset = fmod(size+1,2) * Vector2(16,16)	# mouse_offset = 16,16 if size is en even number,  0,0 otherwise
var position_offset = fmod(size,2) * Vector2(16,16)	# position_offset = 16,16 if size is en odd number,  0,0 otherwise
var tile_offset = floor(size/2) * Vector2(-1,-1)	# tile_offset = (0,0) is size  = 1, (-1,-1) otherwise


func _ready() :
	print("size = " + str(size))
	print("mouse_offset = " + str(mouse_offset))
	print("position_offset = " + str(position_offset))
	print("tile_offset = " + str(tile_offset))


func _process(delta):
	follow_cursor()


func follow_cursor():
	var mouse_cell = map.world_to_map(get_global_mouse_position() + mouse_offset)
	var tile = mouse_cell + tile_offset
	
	map_enn.clear()
	map_enn.set_cellv(mouse_cell,0)
	map_enn.set_cellv(tile,1)
	
	self.global_position = map.map_to_world(mouse_cell) + position_offset