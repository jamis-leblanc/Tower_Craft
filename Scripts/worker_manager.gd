extends Node

enum jobs { 	no_job,
				woodcutter,
				peasant,
				defender,
				scientist
			}

var workers_list = []
var default_job = jobs.no_job

onready var map = get_parent().get_node("World/nav/map_structure")
onready var structure_manager = get_parent().get_node("World/structure_manager")


func create_new_worker(structure_ID):
	var spawn_tile = free_tile(structure_ID)
	var instance = load("res://Scenes/worker.tscn").instance()
	get_parent().get_node("World").add_child(instance)
	instance.global_position = map.map_to_world(spawn_tile)
	instance.mytile = spawn_tile
	instance.home_building = structure_ID


func free_tile(structure_ID):
	var structure = structure_ID
	var size = structure.size
	var tile = map.world_to_map(structure.global_position)
	var free_tile_found = false
	var free_tile = Vector2()
	var search_dist = 0
	var max_search_dist = 10
	
	while free_tile_found == false  and search_dist <= max_search_dist:
		for i in range(tile.x-search_dist, tile.x+size+1+search_dist):
			#print(i)
			for j in range(tile.y-search_dist, tile.y+size+1+search_dist):
				if 		i == tile.x-search_dist or i == tile.x+size+1+search_dist \
					 or j== tile.y-search_dist or j == tile.y+size+1+search_dist :
					#print(str(map.get_cell(i,j)))
					if map.get_cell(i,j) == 3 or map.get_cell(i,j) == 5 :
						free_tile_found = true
						free_tile = Vector2(i,j)
		search_dist +=1
	
	if free_tile_found == true : 
		#print(free_tile)
		return free_tile
	