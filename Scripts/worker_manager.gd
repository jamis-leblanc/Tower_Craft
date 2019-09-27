extends Node


var workers_list = []
var worker_creation_time = 5
var worker_spawning = false
var core = null

onready var map = get_parent().get_node("World/nav/map_structure")
onready var map_char = get_parent().get_node("World/map_char")
onready var world = get_tree().get_root().get_node("World")

signal add_worker()
signal remove_worker()


func create_new_worker(structure_ID):
	if workers_list.size() ==  0 :
		core = structure_ID
	if workers_list.size() < world.food and worker_spawning == false:
		spawn_worker(structure_ID)
		worker_spawning = true
		return true
	elif worker_spawning == true:
		get_tree().call_group("UI", "show_notif","worker_spawning_cooldown")
		return false
	else :
		get_tree().call_group("UI", "show_notif","missing_food")
		return false


func spawn_worker(structure_ID):
	$worker_creation_cooldown.wait_time = worker_creation_time
	$worker_creation_cooldown.start()
	yield(get_tree().create_timer(worker_creation_time), "timeout")
	var spawn_tile = free_tile(structure_ID)
	var instance = load("res://Scenes/worker.tscn").instance()
	instance.global_position = map.map_to_world(spawn_tile) + Vector2(16,16)
	get_parent().get_node("World").add_child(instance)
	map_char.set_cell(spawn_tile.x,spawn_tile.y,1)
	instance.mytile = spawn_tile
	instance.home_building = structure_ID
	workers_list.append([instance,enums.jobs.jobless,structure_ID])
	get_tree().call_group("UI", "_update")
	worker_spawning = false


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

func add_worker_to_struct(job,structure):
	for i in workers_list :
		if i[1] == job and i[2] == core:
			i[2] = structure
			i[0].home_building = structure
			emit_signal("add_worker")
			get_tree().call_group("UI", "_update")
			return true
	return false
	


func remove_worker_from_struc(job,structure):
	for i in workers_list :
		if i[1] == job and i[2] == structure:
			i[2] = core
			i[0].home_building = core
			emit_signal("remove_worker")
			get_tree().call_group("UI", "_update")
			return true
	return false


func clear_struct(structure):
	for i in workers_list :
		if i[2] == structure:
			i[2] = core
			i[0].home_building = core
			print("worker : " + str(i[0]) + " from structure : " + str(structure))
	get_tree().call_group("UI", "_update")
	

func add_job(new_job):
	for i in workers_list :
		if i[1] == enums.jobs.jobless:
			i[0].change_job(new_job)
			i[1] = new_job
			if new_job == enums.jobs.builder :
				task_manager.add_builder(i[0])
			break
	get_tree().call_group("UI", "_update")


func remove_job(old_job):
	if old_job == enums.jobs.builder :
		var builder_removed = task_manager.remove_builder()
		if builder_removed != null :
			for i in workers_list :
				if i[0] == builder_removed :
					i[0].change_job(enums.jobs.jobless)
					i[1] = enums.jobs.jobless
	else :
		for i in workers_list :
			if i[1] == old_job:
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

