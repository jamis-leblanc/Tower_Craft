extends "res://Scripts/StateMachine.gd"

var visited_building = null

func start_job():
	reset_target()
	print("start mage")
	current_task = enums.task.seek_home


func quit_job():
	reset_target()
	mytile = map.world_to_map(p.global_position)
	if in_building == true :
		find_home_cell(visited_building)
		visited_building = null
		p.global_position = map.map_to_world(Vector2(target_cell[0],target_cell[1]))
		p.get_node("Sprite").visible = true
		in_building = false
	print("quit mage")


func _update(delta):
	match current_task:
	
		enums.task.seek_home:
			reset_target()
			find_home_cell(p.home_building)
			if target_cell == null:
				current_task = enums.task.idle
			else :
				current_task = enums.task.go_home
				free_map_char_cell(mytile)
				lock_map_char_cell(target_cell)

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
			p.get_node("Sprite").visible = false
			p.global_position = p.home_building.global_position
			current_task = enums.task.gather_mana
			in_building = true
			free_map_char_cell(mytile)

		enums.task.gather_mana:
			gather_mana(visited_building)
			if p.home_building == worker_manager.core :
				current_task = enums.task.get_out
		
		enums.task.get_out:
			reset_target()
			mytile = map.world_to_map(p.global_position)
			find_home_cell(visited_building)
			visited_building = null
			p.global_position = map.map_to_world(Vector2(target_cell[0],target_cell[1]))
			p.get_node("Sprite").visible = true
			in_building = false
			current_task = enums.task.seek_home
			lock_map_char_cell(target_cell)

		enums.task.idle:
			if p.carried_ressource != 0 :
				p.get_node("AnimationPlayer").play("Idle_Log_"+ p.direction)
			else :
				p.get_node("AnimationPlayer").play("Idle_"+ p.direction)
			if p.ready_to_seek == true  and (p.at_home == false or p.home_building != worker_manager.core) :
				current_task = enums.task.seek_home
				p.ready_to_seek = false
