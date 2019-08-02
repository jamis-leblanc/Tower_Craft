extends Node

var _Tree = load("res://Scripts/tree.gd")
var  structure_list = []


onready var map = get_parent().get_node("nav/map_structure")

signal grow()


func _ready():
	structure_list.resize(2500)
	for i in map.get_used_cells_by_id(0):
		new_tree(i.x,i.y,10)
	for i in map.get_used_cells_by_id(9):
		spawn_structure(i.x,i.y,"res://Scenes/core.tscn")
	for i in map.get_used_cells_by_id(8):
		spawn_structure(i.x,i.y,"res://Scenes/forester.tscn")
#		new_castle(i.x,i.y)

func new_tree(x,y,growth):
	var tree = _Tree.new()
	tree.tile = Vector2(x,y)
	tree.growth = growth
	tree.structure_manager = self
	var image_index = tree.get_image_index()
	structure_list[y*50+x] = tree
	change_tile(x,y,image_index)
	self.connect("grow",tree,"grow")
	tree.connect("change_tile",self,"change_tile")


func spawn_structure(x,y,reference):
	var instance = load(str(reference)).instance()
	get_parent().call_deferred("add_child",instance)
	instance.global_position = Vector2((x+(instance.offset+1))*32,(y+(instance.offset+1))*32)
	instance.is_spawning = false
	instance.get_node("Sprite").set_visible(false)
	add_structure_to_tilemap(x,y,instance)


func signal_received():
	print("signal received")


func add_structure_to_tilemap(x,y,reference):
	for j in reference.size :
		for i in reference.size :
			map.set_cell(x+i,y+j,11)
	map.set_cell(x,y,reference.tile_index)
	structure_list[y*50+x] = reference
	register_structure(x,y,reference)
	#print(str(x) + " ; " + str(y) + " : " + str(reference))


func change_tile(x,y,index):
	map.set_cell(x,y,index)


func _on_tree_grow_timer_timeout():
	self.emit_signal("grow")
	

func register_structure(x,y,ID):
	print(str(x) + " ; " + str(y) + " : " + str(ID))
	structure_list[y*50+x] = ID


func get_structure_ID(x,y):
	var ID = structure_list[y*50+x]
	return ID

func remove_tree(x,y):
	structure_list[y*50+x] = []
	change_tile(x,y,3)












