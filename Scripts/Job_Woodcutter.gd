extends "res://Scripts/StateMachine.gd"

func start_job():
	reset_target()
	print("start woodcutter")
	current_task = enums.task.seek_target


func quit_job():
	free_map_char_cell()
	print("quit woodcutter")


func _update(delta):
	match current_task:

		enums.task.seek_target:
			reset_target()
			find_target(0)
			if target_cell == null and p.at_home:
				current_task = enums.task.idle
			elif target_cell == null and not p.at_home:
				current_task = enums.task.seek_home
			else :
				current_task = enums.task.go_target

		enums.task.go_target:
			if path.size() == 0 :
				current_task = enums.task.harvest
			else :
				if p.at_home == true :
					p.at_home = false
				move_to_target("Walk_",delta)

		enums.task.harvest:
			if p.carried_ressource >= p.carried_max :
				current_task = enums.task.seek_home
			elif not harvest(target_structure_ref) : 
				current_task = enums.task.seek_target

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
					current_task = enums.task.seek_target
			else :
				if p.carried_ressource != 0 :
					move_to_target("Walk_log_",delta)
				else :
					move_to_target("Walk_",delta)

		enums.task.unload:
			if p.carried_ressource <= 0 :
				current_task = enums.task.seek_target
			else :
				unload(1)

		enums.task.idle:
			if p.ready_to_seek == true  :
				if p.at_home == true :
					current_task = enums.task.seek_target
				else :
					current_task = enums.task.seek_home
				p.ready_to_seek = false