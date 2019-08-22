extends "res://Scripts/technologies/technology.gd"


func _init():
	_name = "Increased\nspeed"
	tooltip = "Increase the worker speed."
	cost = 0
	techno_ref = enums.techno.worker_speed
	parent_techno_ref = enums.techno.harvest_amount


func update_stat():
	units_stats.worker_speed = 150
	for i in worker_manager.workers_list :
		i[0].speed = 150