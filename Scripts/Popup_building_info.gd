extends Control

onready var parent = self.get_parent().get_parent()

func _on_TextureButton_pressed():
	get_parent().get_parent().UI_on = false
	queue_free()


func _ready():
	print(str(parent))

func _on_add_worker_pressed():
	worker_manager.create_new_worker(parent)
