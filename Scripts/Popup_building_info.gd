extends Node2D

onready var parent = self.get_parent().get_parent()


func _ready():
	add_to_group("UI")
	_update()


func _update():
	$MarginContainer/CenterContainer/HBoxContainer/VBoxContainer/nbr_workers.text = "Total Workers : " + str(worker_manager.workers_list.size())
	$MarginContainer/CenterContainer/HBoxContainer/VBoxContainer/nbr_jobless.text = "Jobless worker : " + str(worker_manager.count_jobs(0))
	$MarginContainer/CenterContainer/HBoxContainer/VBoxContainer/HBoxContainer/nbr_woodcutter.text = str(worker_manager.count_jobs(1))
	$MarginContainer/CenterContainer/HBoxContainer/VBoxContainer/HBoxContainer2/HBoxContainer/nbr_builder.text = str(worker_manager.count_jobs(2))

func _on_TextureButton_pressed():
	get_parent().get_parent().UI_on = false
	queue_free()


func _on_add_worker_pressed():
	worker_manager.create_new_worker(parent)


func _on_Add_Woodcutter_button_pressed():
	worker_manager.add_woodcutter()


func _on_Remove_Woodcutter_button_pressed():
	worker_manager.remove_woodcutter()


func _on_Add_builder_button_pressed():
	worker_manager.add_builder()


func _on_Remove_builder_button_pressed():
	worker_manager.remove_builder()
