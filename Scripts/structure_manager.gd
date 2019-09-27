extends Node

var _Tree = load("res://Scripts/tree.gd")
var  structure_list = []
var building_list = []

onready var map = get_parent().get_node("World/nav/map_structure")

signal grow()


func _ready():
	structure_list.resize(5000)
	for i in map.get_used_cells_by_id(0):
		new_tree(i.x,i.y,10)
	for i in map.get_used_cells_by_id(9):
		spawn_structure(i.x,i.y,"res://Scenes/core.tscn")
	for i in map.get_used_cells_by_id(8):
		spawn_structure(i.x,i.y,"res://Scenes/forester.tscn")


func new_tree(x,y,growth):
	var tree = _Tree.new()
	tree.tile = Vector2(x,y)
	tree.growth = growth
	var image_index = tree.get_image_index()
	structure_list[y*64+x] = tree
	change_tile(x,y,image_index)
	self.connect("grow",tree,"grow")
	tree.connect("change_tile",self,"change_tile")


func spawn_structure(x,y,reference):
	var instance = load(str(reference)).instance()
	get_parent().get_node("World").call_deferred("add_child",instance)
	instance.global_position = map.map_to_world(Vector2(x,y))-(instance.tile_offset*32 - instance.position_offset)
	instance.tile = Vector2(x,y)
	instance.state = enums.building_states.build
	instance.get_node("Sprite").set_visible(false)
	add_structure_to_tilemap(x,y,instance)
	if reference == "res://Scenes/core.tscn":
		worker_manager.core = instance


func add_structure_to_tilemap(x,y,reference):
	for j in reference.size :
		for i in reference.size :
			map.set_cell(x+i,y+j,11)
	structure_list[y*64+x] = reference
	building_list.append(reference)
	if reference.state != enums.building_states.build :
		map.set_cell(x,y,reference.building_tile_index)
		task_manager.new_task(enums.task_type.build,reference,reference.building_time)
	else :
		map.set_cell(x,y,reference.tile_index)
		reference.state = enums.building_states.operate
		reference.health = reference.health_max
		yield(get_tree().create_timer(0.1), "timeout")
		reference.update_pbar()


func remove_structure_from_tilemap(structure):
	var index = structure_list.find(structure)
	if index != -1 :
		var x = index % 64
		var y = floor(index/64)
		for j in structure.size :
			for i in structure.size :
				map.set_cell(x+i,y+j,5)


func unregister_structure(structure):
	var index = structure_list.find(structure)
	if index != -1 :
		var x = index % 64
		var y = floor(index/64)
		structure_list[y*64+x] = structure
	index = building_list.find(structure)
	if index != -1 : building_list.remove(index)

func change_tile(x,y,index):
	map.set_cell(x,y,index)


func _on_tree_grow_timer_timeout():
	self.emit_signal("grow")


func register_structure(x,y,ID):
	print(str(x) + " ; " + str(y) + " : " + str(ID))
	structure_list[y*64+x] = ID


func get_structure_ID(x,y):
	var ID = structure_list[y*64+x]
	return ID


func remove_tree(x,y):
	structure_list[y*64+x] = []
	change_tile(x,y,3)













