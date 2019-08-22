extends "res://Scripts/technologies/technology.gd"


func _init():
	_name = "Harvest\nspeed II"
	tooltip = "Increase the speed a\ntree is harvested"
	techno_ref = enums.techno.harvest_speed_2
	parent_techno_ref = enums.techno.harvest_speed
	cost = 0


func update_stat():
	units_stats.worker_damage = 4
	for i in worker_manager.workers_list :
		i[0].damage = 4