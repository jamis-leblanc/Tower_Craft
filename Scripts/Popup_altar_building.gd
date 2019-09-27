extends Node2D

onready var parent = self.get_parent().get_parent()
var UI_instance = null

func _ready():
	add_to_group("UI")
	_update()


func _update():
	$PanelContainer/VBoxContainer/nbr_workers.text = "Free mage : " + str(worker_manager.count_jobs_free(4))
	var nbr_mage = parent.current_user
	$PanelContainer/VBoxContainer/HBoxContainer/nbr_mage.text = str(nbr_mage) + " / " + str(parent.max_user)


func _on_Add_mage_button_pressed():
	if parent.add_user() == true and worker_manager.add_worker_to_struct(enums.jobs.mage,parent) == true:
		parent.current_user += 1


func _on_Remove_mage_button_pressed():
	if parent.remove_user() == true and worker_manager.remove_worker_from_struc(enums.jobs.mage,parent) == true :
		parent.current_user -= 1


func _on_TextureButton_pressed():
	get_parent().get_parent().UI_on = false
	queue_free()

