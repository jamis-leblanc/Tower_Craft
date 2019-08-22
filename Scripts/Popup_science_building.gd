extends Node2D

onready var parent = self.get_parent().get_parent()
var science_panel = "res://Scenes/Technologies/Research_UI.tscn"
var UI_instance = null

func _ready():
	add_to_group("UI")
	_update()


func _update():
	$PanelContainer/VBoxContainer/nbr_workers.text = "Free scientist : " + str(worker_manager.count_jobs_free(3))
	var nbr_scientist = worker_manager.count_jobs_building(3,parent)
	$PanelContainer/VBoxContainer/HBoxContainer/nbr_scientist.text = str(nbr_scientist)
	parent.nbr_scientist = nbr_scientist
	$PanelContainer/VBoxContainer/Label.text = str(nbr_scientist)


func _on_Remove_scientist_button_pressed():
	worker_manager.remove_worker_from_struc(enums.jobs.scientist,parent)


func _on_Add_scientist_button_pressed():
	worker_manager.add_worker_to_struct(enums.jobs.scientist,parent)


func _on_TextureButton_pressed():
	get_parent().get_parent().UI_on = false
	queue_free()



func _on_TextureButton2_toggled(button_pressed):
	if button_pressed : 
		UI_instance = load(science_panel).instance()
		UI_instance.set_z_index(9)
		get_node("UI_anchor").add_child(UI_instance)
	else :
		UI_instance.queue_free()