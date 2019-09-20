extends Node2D

var search_dist = 128

onready var map = get_parent().get_node("nav/map_structure")
onready var nav = get_parent().get_node("nav")
onready var map_enn = get_parent().get_node("map_enn")


func _ready():
	add_to_group("Enemy")


func _process(delta):
	follow_cursor()
	map_enn.clear()
	$path.points = []
	$Line2D.points = [self.position-$Line2D.global_position, worker_manager.core.global_position-Vector2(16,16)-$Line2D.global_position]
	var goal_spot = get_target_position(worker_manager.core.global_position-Vector2(16,16))
	$goal.global_position = goal_spot
	var goal_cell = get_goal_cell(goal_spot)
	$goal_cell.global_position = map.map_to_world(goal_cell) + Vector2(16,16)
	var goal_cell_avaibility = check_cell(goal_cell)
	var final_goal_cell = null
	var path = nav.get_simple_path(self.global_position+Vector2(0,1),map.map_to_world(goal_cell)+Vector2(16,17),false)
	$path.points=path
	$path.global_position = Vector2(0,0)
	if goal_cell_avaibility == true and path.size() != 0:
		final_goal_cell = goal_cell
	else :
		final_goal_cell = get_closest_cell(goal_cell)
	$final_goal_cell.global_position = map.map_to_world(final_goal_cell) + Vector2(16,16)


func follow_cursor():
	var mouse_cell = get_global_mouse_position()/(get_parent().cell_size)
	self.position.x = (floor(mouse_cell.x)+0.5)*get_parent().cell_size.x
	self.position.y = (floor(mouse_cell.y)+0.5)*get_parent().cell_size.y


func get_target_position(target_position):
	var direction = (target_position-self.global_position).normalized()
	var goal_position = self.global_position + (direction * search_dist)
	return goal_position


func get_goal_cell(goal_position):
	var goal_cell = map.world_to_map(goal_position)
	return goal_cell

func check_cell(cell):
	var map_cell_type = map.get_cellv(cell)
	var map_enn_cell_type = map_enn.get_cellv(cell)
	if (map_cell_type == 5 or map_cell_type == 3) and map_enn_cell_type == -1 	: return true
	else 																		: return false


func get_closest_cell(cell) :
	var d = 1
	var cell_found = false
	var dist_max = null
	var far_cell = null
	
	while cell_found == false and d < 10: 
		for i in range(cell.x - d , cell.x + d + 1) :
			for j in range(cell.y - d , cell.y + d + 1) :
				if 	i == cell.x - d		or \
					i == cell.x + d 	or \
					j == cell.y - d		or \
					j == cell.y + d :
					var current_cell_dist = map.map_to_world(Vector2(i,j)).distance_to(self.global_position)
					if  current_cell_dist <= search_dist :
						var dist_target =  map.map_to_world(Vector2(i,j)).distance_to(worker_manager.core.global_position-Vector2(16,16))
						map_enn.set_cellv(Vector2(i,j),0)
						if dist_max == null or dist_target < dist_max :
							var map_cell_type = map.get_cellv(Vector2(i,j))
							var map_enn_cell_type = map_enn.get_cellv(Vector2(i,j))
							if (map_cell_type == 5 or map_cell_type == 3) :
								var path = nav.get_simple_path(self.global_position+Vector2(0,1),map.map_to_world(Vector2(i,j))+Vector2(16,17),false)
								if path.size() != 0:
									$path.points=path
									$path.global_position = Vector2(0,0)
									dist_max = dist_target
									far_cell = Vector2(i,j)
									if cell_found == false : cell_found = true
		d += 1
	return far_cell
		
					






