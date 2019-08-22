extends "res://Scripts/technologies/technology.gd"


func _init():
	_name = "Harvest\nspeed"
	tooltip = "Increase the speed a\ntree is harvested"
	techno_ref = enums.techno.harvest_speed
	parent_techno_ref = null
	cost = 0


func update_stat():
	units_stats.worker_damage = 3
	for i in worker_manager.workers_list :
		i[0].damage = 3