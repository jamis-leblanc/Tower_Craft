extends Node2D

enum task {	idle,
			go_harvest,
			back_castle
			cultivate,
			research,
			operate,
			}

var current_task = task.go_harvest
var task_step = 0

var max_search_dist = 15
var target_type = 0
var target_cell = []
var target_structure = null
var home_building = null
var target_ID = null
var path = []
var offset = 0.5
var anim_prefix = ""

var speed = 100
var anim_update = true
var strike_ready = true
var damage = 5

var carried_ressource = 0
var carried_max = 20


onready var nav = get_parent().get_node("nav")
#onready var map = get_parent().get_node("nav/map_structure")
onready var map_char = get_parent().get_node("map_char")
onready var mytile  = map.world_to_map(self.position)
onready var old_tile = mytile
onready var structure_manager = get_parent().get_node("structure_manager")


func _process(delta):
	#print(enum_to_str(task, current_task))
	
	$Label2.text = str(carried_ressource)
	$Label3.text = str(home_building)
	match current_task:
		task.go_harvest:
			match task_step:
				0:
					target_type = 0
					find_target(target_type)
					$Label.text = "seek target"
				1:
					var goal = map.map_to_world(Vector2(target_cell[0],target_cell[1]),true)
					path = nav.get_simple_path(self.global_position, goal + Vector2(16,17) ,false)
					task_step = 2
					$Label.text = "find path"
				2:
					anim_prefix ="Walk_"
					move_to_target(target_cell,delta)
					$Label.text = "move to"
				3:
					$Label.text = "harvest"
					harvest(target_structure)
		task.idle:
			$Label.text = "Idle"
		task.back_castle:
			match task_step:
				0:
					target_type = 9
					find_target(target_type)
					$Label.text = "seek castle"
				1:
					var goal = map.map_to_world(Vector2(target_cell[0],target_cell[1]),true)
					path = nav.get_simple_path(self.global_position, goal + Vector2(16,17) ,false)
					task_step = 2
					$Label.text = "find path"
				2:
					anim_prefix ="Walk_log_"
					move_to_target(target_cell,delta)
					$Label.text = "move to"
				3:
					anim_prefix ="Log_Idle_"
					$Label.text = "drop"
					unload(carried_ressource)


func enum_to_str(enumDict : Dictionary, value : int) -> String:
    for enumKey in enumDict.keys():
        if (enumDict[enumKey] == value):
            return enumKey;
    return ("{%d}" % value);


func go_home_building():
	var size = home_building.size
	var home_cell = map.world_to_map(home_building.global_position)
	var target_list = []
	for i in range (0,size):
		for j in range (0,size):
			target_list.append(home_cell.x+i,home_cell.y+j)
	var cell_list = []
	if target_list != [] :
			cell_list = get_adjacent_cells(target_list)



func find_target(index) :
	var target_size = get_target_size(index)
	#print("target size : " + str(target_size))
	var search_dist = 1
	var cell_list = []
	var goal_found = false
	var target_list = []
	
	while search_dist <= max_search_dist and goal_found == false:
		target_list = get_target_list(index, target_size, search_dist)
		#print("target list : " + str(target_list))
		if target_list != [] :
			cell_list = get_adjacent_cells(target_list)
			#print("cell list : " + str(cell_list))
			if cell_list != [] :
				target_cell = get_shortest_path(cell_list)
				#print("target_cell : " + str(target_cell))
				if target_cell != [] :
					target_structure = get_target_structure(target_cell,index,target_size)
					map_char.set_cell(target_cell[0],target_cell[1],1)
					goal_found = true
			else : print("no more space in structure type :" + str(index))
		
		if goal_found == false :
			search_dist += 1
	if goal_found == false :
		current_task = task.idle
	else : task_step = 1


func get_target_size(index):
	var target_list = map.get_used_cells_by_id(index)
	var target_reference = structure_manager.get_structure_ID(target_list[0].x,target_list[0].y)
	var target_size = target_reference.size
	
	return target_size


func get_target_list(index, target_size, search_dist):
	var  target_list = []
	#print("***********")
	for i in range(mytile.x-search_dist,mytile.x+search_dist+1):
		for j in range(mytile.y-search_dist,mytile.y+search_dist+1):
			if 	i == mytile.x-search_dist or i == mytile.x+search_dist or \
				j == mytile.y-search_dist or j == mytile.y+search_dist :
					#print("tile : " + str(i) + " ; " + str(j) + " / index : " + str(map.get_cell(i,j)))
					if map.get_cell(i,j) == index :
						if target_size == 1 :
							target_list.append([i,j])
						else : 
							for ii in range(i,i+target_size):
								for jj in range(j,j+target_size):
									target_list.append([ii,jj])
	return target_list


func get_adjacent_cells(goal_list):
	var valid_cell_list = []
	for k in goal_list:
		for i in range(k[0]-1,k[0]+2):
			for j in range(k[1]-1,k[1]+2):
				var add_cell = true
				if (map.get_cell(i,j) == 5 or map.get_cell(i,j) == 3) and map_char.get_cell(i,j) != 1:
					if valid_cell_list.size() != 0 :
						for w in valid_cell_list :
							if w[0] == i and w[1] == j:
								add_cell = false
					if add_cell == true :
						valid_cell_list.append([i,j])
	return valid_cell_list



func get_shortest_path(cell_list):
	var shortest_path = null
	var path_lenght
	var path_found = false
	var shortest_lenght 
	var goal_cell
	
	for i in cell_list:
		path = nav.get_simple_path(self.global_position,(map.map_to_world(Vector2(i[0],i[1])))+Vector2(16,17),false)
		#print("path from :" + str(self.global_position) + " to : " + str(map.map_to_world(Vector2(i[0],i[1]))+Vector2(16,17)))
		if path.size() != 0 :
			path_lenght = 0
			for j in path.size()-1:
				path_lenght += path[j].distance_to(path[j+1])
			
			if path_found == false :
				path_found = true
				shortest_path = path
				shortest_lenght = path_lenght
				goal_cell = i
				
			elif path_lenght < shortest_lenght :
				shortest_lenght = path_lenght
				shortest_path = path
				goal_cell = i
	if shortest_path != null:
		#print("shortest path : " + str(shortest_path) + " / lenght : " + str(shortest_lenght))
		return goal_cell
	else : return []


func get_target_structure(target_cell,index,size):
	if index == 0 :
		for i in range(target_cell[0]-1, target_cell[0]+2):
			for j in range(target_cell[1]-1, target_cell[1]+2):
				if i != target_cell[0] or j != target_cell[1]:
					if map.get_cell(i,j) == index:
						return [i,j]
	else :
		var target_cells_list = map.get_used_cells_by_id(index)
		var min_dist = 100000
		var closest_target = null
		for i in target_cells_list :
			var dist = (Vector2((i.x + size/2)*32,(i.y + size/2)*32)).distance_to(Vector2((target_cell[0]+0.5)*32, (target_cell[1]+0.5)*32))
			if dist < min_dist :
				min_dist = dist
				closest_target = i
		#print(closest_target)
		return closest_target


func move_to_target(target_cell,delta) :
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
	else:
		path=[]
		target_cell = null
		task_step = 3


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


func update_map_char_data(old_tile,new_tile):
	map_char.set_cell(old_tile.x,old_tile.y,0)
	map_char.set_cell(new_tile.x,new_tile.y,1)


func harvest(target_structure):
	var anim = null
	if target_ID == null :
		target_ID = structure_manager.get_structure_ID(target_structure[0],target_structure[1])
		anim = "Strike_" + str(get_new_direction(self.global_position,Vector2(target_structure[0]*32+16,target_structure[1]*32+16)))
		$AnimationPlayer.play(anim)
		
	elif is_instance_valid(target_ID) :
		if strike_ready == true :
			damage(target_ID,damage)
			strike_ready = false
			$strike_cooldown.start()
	else :
		task_step = 0
		map_char.set_cell(target_cell[0],target_cell[1],0)
		target_ID = null


func damage(target,amount):
	
	var incoming_ressource = target.damage(amount)
	carried_ressource += incoming_ressource

	if incoming_ressource < amount :
		map_char.set_cell(target_cell[0],target_cell[1],0)
		target.free()
		target_structure = null
		target_ID = null
		task_step = 0
	if carried_ressource >= carried_max :
		map_char.set_cell(target_cell[0],target_cell[1],0)
		current_task = task.back_castle
		task_step = 0


func _on_strike_cooldown_timeout():
	if strike_ready == false :
		strike_ready = true


func unload(amount):
	var anim = anim_prefix + str(get_new_direction(self.global_position,Vector2(target_structure[0]*32+16,target_structure[1]*32+16)))
	$AnimationPlayer.play(anim)
	carried_ressource -= 1
	get_tree().get_root().get_node("World").add_wood(1)
	if carried_ressource <= 0 :
		map_char.set_cell(target_cell[0],target_cell[1],0)
		current_task = task.go_harvest
		task_step = 0
		target_ID = null
	
	
	
	
	
	
	


func _on_seek_cooldown_timeout():
	pass # Replace with function body.
