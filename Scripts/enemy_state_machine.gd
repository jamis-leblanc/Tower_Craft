extends Node

var search_dist = 192
var path_tolerance = 1.5
var state = enums.enemy_task.seek_step
var step_cell = null
var tree_target_cell = null
var tree_target = null
var current_target = null
var path = []
var my_cell = null
var target_cell = null
var strike_ready = true
var anim_update = true
var ready_to_seek = false
var direction = "Up"
var damage = 20
var speed = randi() %20 + 90

var health = 3

onready var final_target = worker_manager.core
onready var map = get_parent().get_parent().get_node("nav/map_structure")
onready var nav = get_parent().get_parent().get_node("nav")
onready var map_enn = get_parent().get_parent().get_node("map_enn")

signal remove_me(ID)


func _process(delta):
	_update(delta)


func _update(delta):

	my_cell = map.world_to_map(self.global_position)

	match state :

		enums.enemy_task.seek_final_target :
		
			path = []
			var structure_list = $detection_area.get_overlapping_areas()		
			for i in structure_list.size() : 
				structure_list[i] = structure_list[i].get_parent()
				
			if structure_list.has(worker_manager.core) :
				path = path_to(worker_manager.core) #<-- met aussi target_cell à jour
				current_target = worker_manager.core
				free_map_enn_cell(my_cell)
				lock_map_enn_cell(target_cell)
				state = enums.enemy_task.move_to_final_target

			
			if 	((structure_list.size() >1 and structure_list.has(worker_manager.core)) or (structure_list.size() >0 and (not structure_list.has(worker_manager.core)))) and path.size() == 0 :
				#print("structure list : " + str(structure_list))
				structure_list = sort(structure_list)
				#print("structure list sorted : " + str(structure_list))
				for i in structure_list :
					path = path_to(i) #<-- met aussi target_cell à jour
					#print("path : " + str(path))
					if path.size() > 0 :
						current_target = i
						free_map_enn_cell(my_cell)
						lock_map_enn_cell(target_cell)
						state = enums.enemy_task.move_to_final_target
						break

			if structure_list.size() == 0 or path.size() == 0 :
				state = enums.enemy_task.seek_step
		
		enums.enemy_task.seek_step :
			
			path = find_target_cell(final_target)#<-- met aussi target_cell à jour
			#print("target cell : " + str(target_cell))
			#print("my cell : " + str(my_cell))
			#print("path : " + str(path))
			if target_cell == my_cell :
				state = enums.enemy_task.seek_tree
			else :
				state = enums.enemy_task.move_to_step
				free_map_enn_cell(my_cell)
				lock_map_enn_cell(target_cell)

		enums.enemy_task.move_to_step:
			$Label.text = "move to step"
			if path.size() > 0 :
				move_to("Walk_",delta)
			else :
				state = enums.enemy_task.seek_final_target
			
		enums.enemy_task.seek_tree:
			$Label.text = "seek_tree"
			tree_target_cell = check_adjacent_cell(my_cell)
			if tree_target_cell == null :
				state = enums.enemy_task.idle
			else :
				tree_target = structure_manager.get_structure_ID(tree_target_cell.x,tree_target_cell.y)
				state = enums.enemy_task.hit_tree
			
		enums.enemy_task.hit_tree:
			$Label.text = "hit tree"
			if hit(tree_target,tree_target_cell) == false :
				state = enums.enemy_task.seek_final_target
		
		enums.enemy_task.move_to_final_target:
			$Label.text = "move to final_target"
			if path.size() > 0 :
				move_to("Walk_",delta)
			else : state = enums.enemy_task.hit_final_target
		
		enums.enemy_task.hit_final_target:
			$Label.text = "hit final_target"
			if hit(current_target,target_cell) == false :
				state = enums.enemy_task.seek_final_target
			
		enums.enemy_task.idle:
			$Label.text = "idle"
			if ready_to_seek == true :
				state = enums.enemy_task.seek_final_target
				ready_to_seek = false


func path_to(structure): # return a path to a free cell adjacent to the given structure (path is not longer then a given lenght
	var adjacent_cells_list = get_adjacent_cells(structure)
	#print(str(adjacent_cells_list))
	if adjacent_cells_list.size() > 0 :
		path = find_path_to(adjacent_cells_list)
		if path.size() > 0 :
			target_cell = map.world_to_map(path[path.size()-1])
			return path
	else : return []
	return []


func sort(my_list) : # return a list of object, sorted on their distance to the agent
	var sorted_list = []
	
	
	while my_list.size() > 0 :
		var min_dist = null
		var min_obj = null
		for i in my_list :
			var dist = self.global_position.distance_to(i.global_position)
			if min_dist == null or dist < min_dist:
				min_obj = i
				min_dist = dist
#		print(str(my_list.find(min_obj)))
#		print(min_obj)
#		print(my_list)
#		print(sorted_list)
		my_list.remove(my_list.find(min_obj))
		sorted_list.append(min_obj)
	
	return sorted_list


func is_target_inrange(my_target) :
	var dist = self.global_position.distance_to(my_target.global_position)
	
	if dist <= search_dist :
		return true
	else :
		return false


func is_target_reachable(my_target) :
	var cell_list = get_adjacent_cells(my_target)
	#print(str(cell_list))
	cell_list.shuffle()
	var path = find_path_to(cell_list)
	if path.size() >0 :
		return true
	else : 
		return false



func reach_target(target) :
	var cell_list = get_adjacent_cells(target)
	cell_list.shuffle()
	var path = find_path_to(cell_list)
	return path


func find_path_to(cell_list) : #return a path to a random cell from the cell_list, shorter then a given lenght
	var _path = []
	for i in cell_list :
		_path = nav.get_simple_path(self.global_position+Vector2(0,1),map.map_to_world(i)+Vector2(16,17),false)
		var path_lenght = lenght(_path)
		if _path.size() > 0 and path_lenght < search_dist * path_tolerance:
			return _path
	return []


func get_path_target(target) :
	var cell_list = get_adjacent_cells(target)
	cell_list.shuffle()
	var path = find_path_to(cell_list)
	if path.size() >0 :
		return path
	else :
		return null


func get_adjacent_cells(target): # return a list of all the free cells adjacents to the structure
	var target_cell_list = get_target_cell_list(target)
	var valid_cell_list = []
	for k in target_cell_list:
		for i in range(k.x-1,k.x+2):
			for j in range(k.y-1,k.y+2):
				if (map.get_cell(i,j) == 5 or map.get_cell(i,j) == 3) and map_enn.get_cell(i,j) != 0:
					if not valid_cell_list.has(Vector2(i,j)) :
						valid_cell_list.append(Vector2(i,j))
	return valid_cell_list


func get_target_cell_list(target): # return a list of the cells occupied by the structure
	var target_cell_list = []
	var size = target.size
	var tile_offset = target.tile_offset
	var tile = map.world_to_map(target.global_position) + tile_offset
	for i in range(tile.x,tile.x+size) :
		for j in range(tile.y,tile.y+size) :
			target_cell_list.append(Vector2(i,j))
	return target_cell_list


func find_target_cell(my_target):
	var step_position = get_target_position(my_target)
	#print("step position : " + str(step_position))
	var step_cell = get_goal_cell(step_position)
	#print("step cell : " + str(step_cell))
	var step_cell_free = check_cell(step_cell)
	#print("is step cell free : " + str(step_cell_free))
	
	if step_cell_free == true :
		var my_path = nav.get_simple_path(self.global_position+Vector2(0,1),map.map_to_world(step_cell)+Vector2(16,17),false)
		var path_lenght = lenght(my_path)
		if my_path.size() > 0 and path_lenght < search_dist * path_tolerance :
			target_cell = step_cell
			return my_path
	
	var my_path = get_closest_cell(step_cell)

	return my_path


func get_target_position(target_position):
	var direction = (target_position.global_position-Vector2(16,16)-self.global_position).normalized()
	var goal_position = self.global_position + (direction * search_dist)
	return goal_position


func get_goal_cell(goal_position):
	var goal_cell = map.world_to_map(goal_position)
	return goal_cell


func check_cell(cell):
	var map_cell_type = map.get_cellv(cell)
	var map_enn_cell_type = map_enn.get_cellv(cell)
	if ((map_cell_type == 5 or map_cell_type == 3) and map_enn_cell_type == -1) or cell == my_cell 	: return true
	else 																							: return false


func get_closest_cell(cell) :
	#print("get_closest_cell")
	var d = 1
	var cell_found = false
	var dist_max = null
	var far_cell = null
	var selected_path = []
	
	while cell_found == false : 
		for i in range(cell.x - d , cell.x + d + 1) :
			for j in range(cell.y - d , cell.y + d + 1) :
				if 	i == cell.x - d		or \
					i == cell.x + d 	or \
					j == cell.y - d		or \
					j == cell.y + d :
					var current_cell = Vector2(i,j)
					var current_cell_dist = map.map_to_world(current_cell).distance_to(self.global_position)
					if  current_cell_dist <= search_dist :
						var target_dist =  map.map_to_world(current_cell).distance_to(final_target.global_position)
						if dist_max == null or target_dist < dist_max :
							if check_cell(current_cell) == true :
								var path = nav.get_simple_path(self.global_position+Vector2(0,1),map.map_to_world(current_cell)+Vector2(16,17),false)
								var path_lenght = lenght(path)
								if path.size() != 0 and path_lenght < search_dist * path_tolerance :
									dist_max = target_dist
									far_cell = current_cell
									selected_path = path
									if cell_found == false : cell_found = true
		d += 1
	target_cell = far_cell
	return selected_path


func free_map_enn_cell(cell):
	map_enn.set_cellv(cell,-1)


func lock_map_enn_cell(cell):
	map_enn.set_cellv(cell,0)


func move_to(anim_prefix,delta):
	
	var anim = null
	if path.size()>0:
		#$path.points = path
		var d = self.position.distance_to(path[0])
		if d > 2:
			self.position = self.position.linear_interpolate(path[0],(speed * delta)/d)
			if anim_update == true:
				direction = str(get_new_direction(self.global_position,path[0]))
				anim = anim_prefix + direction
				$AnimationPlayer.play(anim)
				anim_update = false
		else :
			path.remove(0)
			anim_update = true


func check_adjacent_cell(cell):
	var dist_min = null
	var cell_min = null
	for i in range(cell.x-1, cell.x+2):
		for j in range(cell.y-1, cell.y+2):
			if i != cell.x or j != cell.y:
				if map.get_cell(i,j) == 0:
					var dist = map.map_to_world(Vector2(i,j)).distance_to(final_target.global_position)
					if dist_min == null or dist <= dist_min :
						dist_min = dist
						cell_min = Vector2(i,j)
	return cell_min


func lenght(my_path):
	var my_lenght = 0
	for i in range(1, my_path.size()):
		my_lenght += my_path[i].distance_to(my_path[i-1])
	#print(my_lenght)
	return my_lenght


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


func hit(target,cell):
	if is_instance_valid(target) :
		if strike_ready == true :
			if target.is_in_group("Tree") :
				direction = str(get_new_direction(self.global_position,Vector2(tree_target_cell.x*32+16,tree_target_cell.y*32+16)))
			else :
				direction = str(get_new_direction(self.global_position,Vector2(target.global_position.x,target.global_position.y)))
			var anim = "Strike_" + direction
			$AnimationPlayer.play(anim)
			if target.has_method("damage") :
				damage(target,damage)
			strike_ready = false
			$strike_cooldown.start()
		return true
	else :
		return false


func damage(target,amount):
	target.damage(amount)


func get_damage(amount):
	if state != enums.enemy_task.death:
		health -= amount
		if health <= 0 :
			die()


func die() :
	$AnimationPlayer.play("death")
	state = enums.enemy_task.death
	free_map_enn_cell(target_cell)
	

func _on_strike_cooldown_timeout():
	strike_ready = true


func _on_seek_cooldown_timeout():
	ready_to_seek = true


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "death" :
		queue_free()
