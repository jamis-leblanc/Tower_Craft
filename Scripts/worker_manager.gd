extends Node


var workers_list = []
var core = null

onready var map = get_parent().get_node("World/nav/map_structure")
onready var map_char = get_parent().get_node("World/map_char")


func create_new_worker(structure_ID):
	if workers_list.size() ==  0 :
		core = structure_ID
	var spawn_tile = free_tile(structure_ID)
	var instance = load("res://Scenes/worker.tscn").instance()
	instance.global_position = map.map_to_world(spawn_tile) + Vector2(16,16)
	get_parent().get_node("World").add_child(instance)
	map_char.set_cell(spawn_tile.x,spawn_tile.y,1)
	instance.mytile = spawn_tile
	instance.home_building = structure_ID
	workers_list.append([instance,enums.jobs.jobless,structure_ID])
	get_tree().call_group("UI", "_update")
	print(workers_list)


func count_jobs(job):
	var count = 0
	for i in workers_list :
		if i[1] == job :
			count += 1
	return count


func count_jobs_free(job) :
	var count = 0
	for i in workers_list :
		if i[1] == job and i[2] == core:
			count += 1
	return count


func count_jobs_building(job,building):
	var count = 0
	for i in workers_list :
		if i[1] == job and i[2] == building:
			count += 1
	return count


func add_woodcutter_to_struc(structure):
	for i in workers_list :
		if i[1] == enums.jobs.woodcutter and i[2] == core:
			i[2] = structure
			i[0].home_building = structure
			break
	get_tree().call_group("UI", "_update")


func remove_woodcutter_from_struc(structure):
	for i in workers_list :
		if i[1] == enums.jobs.woodcutter and i[2] == structure:
			i[2] = core
			i[0].home_building = core
			break
	get_tree().call_group("UI", "_update")


func add_builder():
	for i in workers_list :
		if i[1] == enums.jobs.jobless:
			i[0].change_job(enums.jobs.builder)
			i[1] = enums.jobs.builder
			task_manager.add_builder(i[0])
			break
	get_tree().call_group("UI", "_update")


func remove_builder() :
	var builder_removed = task_manager.remove_builder()
	if builder_removed != null :
		for i in workers_list :
			if i[0] == builder_removed :
				i[0].change_job(enums.jobs.jobless)
				i[1] = enums.jobs.jobless
	get_tree().call_group("UI", "_update")


func add_woodcutter():
	for i in workers_list :
		if i[1] == enums.jobs.jobless:
			i[0].change_job(enums.jobs.woodcutter)
			i[1] = enums.jobs.woodcutter
			break
	get_tree().call_group("UI", "_update")


func remove_woodcutter():
	for i in workers_list :
		if i[1] == enums.jobs.woodcutter:
			i[2] = core
			i[0].home_building = core
			i[0].change_job(enums.jobs.jobless)
			i[1] = enums.jobs.jobless
			break
	get_tree().call_group("UI", "_update")


func free_tile(structure_ID):
	var structure = structure_ID
	var size = structure.size
	var tile = map.world_to_map(structure.global_position) + structure.tile_offset + Vector2(-1,-1)
	var free_tile_found = false
	var free_tile = Vector2()
	var search_dist = 0
	var max_search_dist = 10
	
	while free_tile_found == false  and search_dist <= max_search_dist:
		for i in range(tile.x-search_dist, tile.x+size+2+search_dist):
			for j in range(tile.y-search_dist, tile.y+size+2+search_dist):
				if i == tile.x-search_dist or i == tile.x+size+1+search_dist or j== tile.y-search_dist or j == tile.y+size+1+search_dist :
					if (map.get_cell(i,j) == 3 or map.get_cell(i,j) == 5) and not map_char.get_cell(i,j) == 1:
						free_tile_found = true
						free_tile = Vector2(i,j)
		search_dist +=1
	
	if free_tile_found == true : 
		return free_tile
	