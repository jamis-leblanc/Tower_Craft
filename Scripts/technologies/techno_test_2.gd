extends "res://Scripts/technologies/technology.gd"


func _init():
	_name = "Capacity\nincreased"
	tooltip = "Increase the amount of ressource a worker\nis able to harvest before returning"
	cost = 100
	techno_ref = enums.techno.worker_max_load
	parent_techno_ref = enums.techno.harvest_amount


func update_stat():
	units_stats.worker_carried_max = 30
	for i in worker_manager.workers_list :
		i[0].carried_max = 30