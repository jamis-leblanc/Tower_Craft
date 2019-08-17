extends Node2D

onready var parent = self.get_parent().get_parent()

func _ready():
	add_to_group("UI")
	_update()


func _update():
	$MarginContainer/CenterContainer/HBoxContainer/VBoxContainer/nbr_workers.text = "Free woodcutter : " + str(worker_manager.count_jobs_free(1))
	$MarginContainer/CenterContainer/HBoxContainer/VBoxContainer/HBoxContainer/nbr_woodcutter.text = str(worker_manager.count_jobs_building(1,parent))


func _on_Add_Woodcutter_button_pressed():
	worker_manager.add_worker_to_struct(enums.jobs.woodcutter,parent)


func _on_Remove_Woodcutter_button_pressed():
	worker_manager.remove_worker_from_struc(enums.jobs.woodcutter,parent)
	
	
func _on_TextureButton_pressed():
	get_parent().get_parent().UI_on = false
	queue_free()