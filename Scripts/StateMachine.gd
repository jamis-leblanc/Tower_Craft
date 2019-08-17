extends Node

var target_cell = null
var target_structure_cell = null
var target_structure_ref = null

var anim_update = true

var path = []

onready var nav = get_tree().get_root().get_node("World/nav")
onready var map = get_tree().get_root().get_node("World/nav/map_structure")
onready var map_char = get_tree().get_root().get_node("World/map_char")

onready var p = self.get_parent().get_parent()

onready var mytile  = map.world_to_map(p.position)

var current_task = enums.task.idle


func _process(delta):
	p.get_node("Label").text = str(current_task)


func find_target(type) :
	var search_dist = 1
	var cell_list = []
	var target_list = []
	var goal_cell = null
	
	while search_dist <= p.max_search_dist and goal_cell == null :
		target_list = get_target_list(type, search_dist)
		if target_list != [] :
			cell_list = get_adjacent_cells(target_list)
			if cell_list != [] :
				goal_cell = get_shortest_path(cell_list)
		if goal_cell == null :
			search_dist += 1
	if goal_cell != null :
		target_cell = goal_cell
		target_structure_cell = get_target_structure(target_cell,type)
		target_structure_ref = structure_manager.get_structure_ID(target_structure_cell[0],target_structure_cell[1])
		path = nav.get_simple_path(p.global_position,(map.map_to_world(Vector2(target_cell[0],target_cell[1])))+Vector2(16,17),false)
		map_char.set_cell(mytile.x,mytile.y,0)
		map_char.set_cell(target_cell[0],target_cell[1],1)
	return goal_cell


func find_home_cell(home_building):
	var cell_list = []
	var target_list = []
	var goal_cell = null
	
	target_list = get_home_cell_list(home_building)
	if target_list != [] :
		cell_list = get_adjacent_cells(target_list)
		if cell_list != [] :
			goal_cell = get_shortest_path(cell_list)
	if goal_cell != null :
		target_cell = goal_cell
		target_structure_cell = map.world_to_map(home_building.global_position)
		target_structure_ref = home_building
		path = nav.get_simple_path(p.global_position,(map.map_to_world(Vector2(target_cell[0],target_cell[1])))+Vector2(16,17),false)
		map_char.set_cell(mytile.x,mytile.y,0)
		map_char.set_cell(target_cell[0],target_cell[1],1)


func get_home_cell_list(home):
	var home_cell_list = []
	var size = home.size
	var tile_offset = home.tile_offset
	var tile = map.world_to_map(home.global_position) + tile_offset
	for i in range(tile.x,tile.x+size) :
		for j in range(tile.y,tile.y+size) :
			home_cell_list.append([i,j])
	return home_cell_list


func get_target_list(type, search_dist):
	var  target_list = []
	for i in range(mytile.x-search_dist,mytile.x+search_dist+1):
		for j in range(mytile.y-search_dist,mytile.y+search_dist+1):
			if 	i == mytile.x-search_dist or i == mytile.x+search_dist or \
				j == mytile.y-search_dist or j == mytile.y+search_dist :
				if map.get_cell(i,j) == type :
					target_list.append([i,j])
	return target_list


func get_adjacent_cells(cell_list):
	var valid_cell_list = []
	for k in cell_list:
		for i in range(k[0]-1,k[0]+2):
			for j in range(k[1]-1,k[1]+2):
				if (map.get_cell(i,j) == 5 or map.get_cell(i,j) == 3) and map_char.get_cell(i,j) != 1:
					if not valid_cell_list.has([i,j]) :
						valid_cell_list.append([i,j])
	return valid_cell_list


func get_shortest_path(cell_list):
	var shortest_path = null
	var path_lenght = null
	var shortest_lenght = 100000
	var goal_cell = null
	
	for i in cell_list:
		path = nav.get_simple_path(p.global_position,(map.map_to_world(Vector2(i[0],i[1])))+Vector2(16,17),false)
		if path.size() != 0 :
			path_lenght = 0
			for j in path.size()-1:
				path_lenght += path[j].distance_to(path[j+1])
				
			if path_lenght < shortest_lenght :
				shortest_lenght = path_lenght
				shortest_path = path
				goal_cell = i
	return goal_cell


func get_target_structure(cell,index):
	for i in range(cell[0]-1, cell[0]+2):
		for j in range(cell[1]-1, cell[1]+2):
			if i != cell[0] or j != cell[1]:
				if map.get_cell(i,j) == index:
					return [i,j]
						

func move_to_target(anim_prefix,delta) :
	var anim = null
	if path.size()>0:
		var d = p.position.distance_to(path[0])
		if d > 2:
			p.position = p.position.linear_interpolate(path[0],(p.speed * delta)/d)
			if anim_update == true:
				mytile = map.world_to_map(p.position)
				anim = anim_prefix + str(get_new_direction(p.global_position,path[0]))
				p.get_node("AnimationPlayer").play(anim)
				anim_update = false
		else :
			path.remove(0)
			anim_update = true


func get_new_direction(start,end) :
	
	var dir = rad2deg(((end-start).angle()))

	if dir > -20 and dir <20 : return("Right")
	if dir > 25 and dir <65 : return("Down_Right")
	if dir > 70 and dir <110 : return("Down")
	if dir > 115 and dir <155 : return("Down_Left")
	if dir > 160 or dir <-160 : return("Left")
	if dir > -155 and dir <-115 : return("Up_Left")
	if dir > -110 and dir <-70  : return("Up")
	if dir > -65 and dir <-25 : return("Up_Right")


func research(my_target):
	if p.research_ready == true : 
		get_tree().get_root().get_node("World").add_research(1)
		p.research_ready = false


func harvest(my_target):
	if is_instance_valid(my_target) :
		if p.strike_ready == true :
			var anim = "Strike_" + str(get_new_direction(p.global_position,Vector2(target_structure_cell[0]*32+16,target_structure_cell[1]*32+16)))
			p.get_node("AnimationPlayer").play(anim)
			damage(my_target,p.damage)
			p.strike_ready = false
			p.get_node("strike_cooldown").start()
		return true
	else :
		reset_target()
		return false


func build(my_target):
	if is_instance_valid(my_target) :
		if p.strike_ready == true :
			var anim = "Strike_" + str(get_new_direction(p.global_position,Vector2(target_structure_cell[0]*32+16,target_structure_cell[1]*32+16)))
			p.get_node("AnimationPlayer").play(anim)
			repair(my_target,p.repair_amount)
			p.strike_ready = false
			p.get_node("strike_cooldown").start()
		return true
	else :
		reset_target()
		return false


func damage(target,amount):
	
	amount = min(p.damage, p.carried_max-p.carried_ressource)
	var incoming_ressource = target.damage(amount)
	p.carried_ressource += incoming_ressource

	if incoming_ressource < amount :
		target.free()


func repair(target,amount):
	var incoming_ressource = target.repair(amount)
	if incoming_ressource < amount :
		print("Build complete!")


func unload(amount):
	var anim = "Log_Idle_" + str(get_new_direction(p.global_position,Vector2(target_structure_cell[0]*32+16,target_structure_cell[1]*32+16)))
	p.get_node("AnimationPlayer").play(anim)
	p.carried_ressource -= 1
	get_tree().get_root().get_node("World").add_wood(1)


func reset_target():
	target_cell = null
	target_structure_ref = null
	target_structure_cell = null
	path = []


func free_map_char_cell():
	if target_cell != null :
		map_char.set_cell(target_cell[0],target_cell[1],0)
		map_char.set_cell(mytile[0],mytile[1],0)
		print("free : " + str(target_cell))