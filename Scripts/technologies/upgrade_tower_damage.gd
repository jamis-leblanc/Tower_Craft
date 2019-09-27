extends "res://Scripts/technologies/technology.gd"


func _init():
	_name = "Upgrade\ndamages"
	tooltip = "Increase the amount of damage a tower can cause"
	techno_ref = enums.techno.tower_damage
	parent_techno_ref = null
	cost = 150

func update_stat():
	units_stats.base_tower_damage = 1.5
	for i in structure_manager.building_list :
		if i!=null and i._name == "Base tower":
			i.damage = units_stats.base_tower_damage
			