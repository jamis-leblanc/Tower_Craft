extends "res://Scripts/StateMachine.gd"

var build_task = []

func start_job():
	reset_target()
	print("start builder")
	current_task = enums.task.seek_home


func quit_job():
	print("quit builder")


func _update(delta):
	match current_task:
		
		enums.task.seek_target:
			if build_task != [] :
				reset_target()
				find_home_cell(build_task[1])
				if target_cell == null:
					current_task = enums.task.seek_home
				else :
					current_task = enums.task.go_target
					free_map_char_cell(mytile)
					lock_map_char_cell(target_cell)
		
		
		enums.task.go_target:
			if path.size() == 0 :
				current_task = enums.task.harvest
			else :
				if p.at_home == true :
					p.at_home = false
				move_to_target("Walk_",delta)


		enums.task.harvest:
			if target_structure_ref.health >= target_structure_ref.health_max :
				build_task[1].build_complete()
				current_task = enums.task.seek_home
				task_manager.task_complete(build_task)
			else : 
				build(target_structure_ref)
				

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
				current_task = enums.task.idle
			else :
				move_to_target("Walk_",delta)


		enums.task.idle:
			if p.carried_ressource != 0 :
				p.get_node("AnimationPlayer").play("Idle_Log_"+ p.direction)
			else :
				p.get_node("AnimationPlayer").play("Idle_"+ p.direction)
			if p.ready_to_seek == true  :
				if p.at_home == true :
					current_task = enums.task.seek_target
				else :
					current_task = enums.task.seek_home
				p.ready_to_seek = false