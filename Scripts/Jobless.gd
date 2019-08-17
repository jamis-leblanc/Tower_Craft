extends "res://Scripts/StateMachine.gd"

func start_job():
	free_map_char_cell()
	reset_target()
	print("start jobless")
	current_task = enums.task.seek_home


func quit_job():
	free_map_char_cell()
	print("quit jobless")


func _update(delta):
	match current_task:

		enums.task.seek_home:
			reset_target()
			find_home_cell(p.home_building)
			if target_cell == null:
				current_task = enums.task.idle
			else :
				current_task = enums.task.go_home

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