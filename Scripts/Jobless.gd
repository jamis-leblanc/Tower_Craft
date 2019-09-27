extends "res://Scripts/StateMachine.gd"

func start_job():
	print("start jobless")
	current_task = enums.task.seek_home


func quit_job():
	print("quit jobless")
	if target_cell != null :
		free_map_char_cell(target_cell)


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
				if p.carried_ressource > 0 :
					current_task = enums.task.unload
				else :
					current_task = enums.task.idle
			else :
				if p.carried_ressource != 0 :
					move_to_target("Walk_log_",delta)
				else :
					move_to_target("Walk_",delta)

		enums.task.unload:
			if p.carried_ressource <= 0 :
				current_task = enums.task.idle
			else :
				unload(1)
		
		enums.task.idle:
			if p.carried_ressource != 0 :
				p.get_node("AnimationPlayer").play("Idle_Log_"+ p.direction)
			else :
				p.get_node("AnimationPlayer").play("Idle_"+ p.direction)