extends "res://Scripts/technologies/technology.gd"


func _init():
	_name = "Harvest\nefficiency"
	tooltip = "Increase the quantity of\nressources harvested per tree"
	techno_ref = enums.techno.harvest_amount
	parent_techno_ref = null
	cost = 50

func update_stat():
	units_stats.worker_ressource_bonus = 1
	for i in worker_manager.workers_list :
		i[0].ressource_bonus = 1