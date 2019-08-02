extends "res://Scripts/building.gd"

var _Tree = load("res://Scripts/tree.gd")
var on_cooldown = false
var max_range = 8

#onready var structure_manager = get_parent().get_node("structure_manager")

signal new_tree(x,y,growth)

func _init():
	reference = "res://Scenes/woodcutter.tscn"
	size = 2
	tile_index = 13
	offset = fmod(size,2)
	_name = "Woodcutter hut"


func _ready():
	self.connect("new_tree",structure_manager,"new_tree")

func _process(delta):
	if is_spawning == false : update_production()


func check_position_validity():
	is_valid = true
	for j in size :
			for i in size :
				var cell_type = map.get_cell(tile.x-(size/2+offset)+i,tile.y-(size/2+offset)+j)
				if cell_type != 5 :
					is_valid = false
	if is_valid == false :	$Sprite.set_self_modulate(Color(1,0.25,0.25,1))
	else  : 				$Sprite.set_self_modulate(Color(1,1,1,1))


func update_production():
	if is_working == false : return
	if on_cooldown == true : return
	else :
		var pop_succes = false
		var pop_radius = size * 16 * 1.45
		for i in range(max_range) :
			var pop_direction = rand_range(0,360)
			var pop_cell_x = self.position.x - get_parent().cell_size.x * offset/2  + sin(pop_direction) * pop_radius
			var pop_cell_y = self.position.y - get_parent().cell_size.y * offset/2 + cos(pop_direction) * pop_radius
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
