extends Control

onready var structure = get_tree().get_root().find_node("Popup_building_info")

func _on_TextureButton_pressed():
	
	worker_manager.create_new_worker(structure.parent)
