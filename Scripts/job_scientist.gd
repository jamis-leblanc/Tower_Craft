extends "res://Scripts/StateMachine.gd"

var visited_building = null

func start_job():
	reset_target()
	print("start scientist")
	current_task = enums.task.seek_home


func quit_job():
	reset_target()
	mytile = map.world_to_map(p.global_position)
	find_home_cell(visited_building)
	free_map_char_cell()
	visited_building = null
	p.global_position = map.map_to_world(Vector2(target_cell[0],target_cell[1]))
	p.get_node("Sprite").visible = true
	print("quit scientist")


func _update(delta):
	match current_task:
	
		enums.task.seek_home:
			free_map_char_cell()
			reset_target()
			find_home_cell(p.home_building)
			if target_cell == null:
				current_task = enums.task.idle
			else :
				current_task = enums.task.go_home

		enums.task.go_home:
			if path.size() == 0 :
				p.at_home = true
				if p.home_building == worker_manager.core :
					current_task = enums.task.idle
				else :
					current_task = enums.task.get_in
			else :
				move_to_target("Walk_",delta)

		enums.task.get_in:
			visited_building = p.home_building
			free_map_char_cell()
			p.get_node("Sprite").visible = false
			p.global_position = p.home_building.global_position
			current_task = enums.task.research
		
		enums.task.research:
			research(visited_building)
			if p.home_building == worker_manager.core :
				current_task = enums.task.get_out
		
		enums.task.get_out:
			reset_target()
			mytile = map.world_to_map(p.global_position)
			find_home_cell(visited_building)
			visited_building = null
			p.global_position = map.map_to_world(Vector2(target_cell[0],target_cell[1]))
			p.get_node("Sprite").visible = true
			current_task = enums.task.seek_home

		enums.task.idle:
			if p.ready_to_seek == true  and (p.at_home == false or p.home_building != worker_manager.core) :
				current_task = enums.task.seek_home
				p.ready_to_seek = false
