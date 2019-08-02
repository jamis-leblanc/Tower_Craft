extends Node2D

enum task {	idle,
			seek_target,
			go_target,
			harvest,
			seek_home,
			go_home,
			unload,
			cultivate,
			research,
			operate,
			}

var current_task = task.idle
var ready_to_seek = false

var home_building = null
var target_cell = null
var target_structure_ref = null
var target_structure_cell = null
var max_search_dist = 5

var path = []
var speed = 150
var anim_update = true
var at_home = false

var strike_ready = true
var damage = 9
var carried_ressource = 0
var carried_max = 20

onready var nav = get_parent().get_node("nav")
onready var map = get_parent().get_node("nav/map_structure")
onready var map_char = get_parent().get_node("map_char")
onready var structure_manager = get_parent().get_node("structure_manager")
onready var mytile  = map.world_to_map(self.position)

func _process(delta):
	$Label2.text = str(carried_ressource)
#	$Label2.text = str(path.size())
	$Label3.text = str(home_building)
	match current_task:
		
		task.seek_target:
			$Label.text = "seek target"
			reset_target()
			find_target(0)
			if target_cell == null and at_home:
				current_task = task.idle
			elif target_cell == null and not at_home:
				current_task = task.seek_home
			else :
				current_task = task.go_target
		
		task.go_target:
			$Label.text = "go target"
			if path.size() == 0 :
				current_task = task.harvest
			else :
				if at_home == true :
					at_home = false
				move_to_target("Walk_",delta)
			
		task.harvest:
			$Label.text = "harvest"
			if carried_ressource >= carried_max :
				current_task = task.seek_home
			elif not harvest(target_structure_ref) : 
				current_task = task.seek_target
			
		task.seek_home:
			$Label.text = "seek home"
			reset_target()
			find_home_cell(home_building)
			if target_cell == null:
				current_task = task.idle
			else :
				current_task = task.go_home
		
		task.go_home:
			$Label.text = "go home"
			if path.size() == 0 :
				at_home = true
				if carried_ressource > 0 :
					current_task = task.unload
				else :
					current_task = task.seek_target
			else :
				move_to_target("Walk_log_",delta)

		task.unload:
			$Label.text = "unload"
			if carried_ressource <= 0 :
				current_task = task.seek_target
			else :
				unload(1)
			
		task.idle:
			$Label.text = "Idle"
			if ready_to_seek == true :
				current_task = task.seek_target
				ready_to_seek = false




func find_target(type) :
	var search_dist = 1
	var cell_list = []
	var target_list = []
	var goal_cell = null
	
	while search_dist <= max_search_dist and goal_cell == null :
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
		path = nav.get_simple_path(self.global_position,(map.map_to_world(Vector2(target_cell[0],target_cell[1])))+Vector2(16,17),false)
		map_char.set_cell(target_cell[0],target_cell[1],1)
		map_char.set_cell(mytile.x,mytile.y,0)
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
		path = nav.get_simple_path(self.global_position,(map.map_to_world(Vector2(target_cell[0],target_cell[1])))+Vector2(16,17),false)
		map_char.set_cell(target_cell[0],target_cell[1],1)
		map_char.set_cell(mytile.x,mytile.y,0)


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
		path = nav.get_simple_path(self.global_position,(map.map_to_world(Vector2(i[0],i[1])))+Vector2(16,17),false)
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
		var d = self.position.distance_to(path[0])
		if d > 2:
			self.position = self.position.linear_interpolate(path[0],(speed * delta)/d)
			if anim_update == true:
				mytile = map.world_to_map(self.position)
				anim = anim_prefix + str(get_new_direction(self.global_position,path[0]))
				$AnimationPlayer.play(anim)
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


func harvest(my_target):
	if is_instance_valid(my_target) :
		if strike_ready == true :
			var anim = "Strike_" + str(get_new_direction(self.global_position,Vector2(target_structure_cell[0]*32+16,target_structure_cell[1]*32+16)))
			$AnimationPlayer.play(anim)
			damage(my_target,damage)
			strike_ready = false
			$strike_cooldown.start()
		return true
	else :
		reset_target()
		return false


func damage(target,amount):
	
	amount = min(damage, carried_max-carried_ressource)
	var incoming_ressource = target.damage(amount)
	carried_ressource += incoming_ressource

	if incoming_ressource < amount :
		target.free()


func unload(amount):
	var anim = "Log_Idle_" + str(get_new_direction(self.global_position,Vector2(target_structure_cell[0]*32+16,target_structure_cell[1]*32+16)))
	$AnimationPlayer.play(anim)
	carried_ressource -= 1
	get_tree().get_root().get_node("World").add_wood(1)


func _on_strike_cooldown_timeout():
	strike_ready = true


func _on_seek_cooldown_timeout():
	ready_to_seek = true


func reset_target():
	target_cell = null
	target_structure_ref = null
	target_structure_cell = null
	path = []
