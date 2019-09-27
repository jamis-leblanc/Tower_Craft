extends Node2D

onready var parent = self.get_parent().get_parent()
onready var worker_Pbar = $MarginContainer/CenterContainer/HBoxContainer/VBoxContainer/CenterContainer/HBoxContainer/add_worker/ProgressBar
onready var worker_cooldown_timer = worker_manager.get_node("worker_creation_cooldown")


func _ready():
	add_to_group("UI")
	_update()


func _process(delta):
	if worker_manager.worker_spawning == true :
		_update_progress_bar()


func _update_progress_bar() :
	if worker_Pbar.is_visible() == false:
		worker_Pbar.set_visible(true)
	worker_Pbar.value = ((worker_cooldown_timer.wait_time-worker_cooldown_timer.time_left) / worker_cooldown_timer.wait_time)*100
	if worker_Pbar.value >= 99 :
		worker_Pbar.set_visible(false)


func _update():
	$MarginContainer/CenterContainer/HBoxContainer/VBoxContainer/nbr_workers.text = "Total Workers : " + str(worker_manager.workers_list.size())
	$MarginContainer/CenterContainer/HBoxContainer/VBoxContainer/nbr_jobless.text = "Jobless worker : " + str(worker_manager.count_jobs(0))
	$MarginContainer/CenterContainer/HBoxContainer/VBoxContainer/HBoxContainer/nbr_woodcutter.text = str(worker_manager.count_jobs(1))
	$MarginContainer/CenterContainer/HBoxContainer/VBoxContainer/HBoxContainer2/HBoxContainer/nbr_builder.text = str(worker_manager.count_jobs(2))
	$MarginContainer/CenterContainer/HBoxContainer/VBoxContainer/HBoxContainer3/HBoxContainer/nbr_scientist.text = str(worker_manager.count_jobs(enums.jobs.scientist))
	$MarginContainer/CenterContainer/HBoxContainer/VBoxContainer/HBoxContainer4/HBoxContainer/nbr_mage.text = str(worker_manager.count_jobs(enums.jobs.mage))
	
func _on_TextureButton_pressed():
	get_parent().get_parent().UI_on = false
	queue_free()


func _on_add_worker_pressed():
	worker_manager.create_new_worker(parent)



func _on_Add_Woodcutter_button_pressed():
	worker_manager.add_job(enums.jobs.woodcutter)

func _on_Remove_Woodcutter_button_pressed():
	worker_manager.remove_job(enums.jobs.woodcutter)


func _on_Add_builder_button_pressed():
	worker_manager.add_job(enums.jobs.builder)

func _on_Remove_builder_button_pressed():
	worker_manager.remove_job(enums.jobs.builder)


func _on_Add_scientist_button_pressed():
	worker_manager.add_job(enums.jobs.scientist)

func _on_Remove_scientist_button_pressed():
	worker_manager.remove_job(enums.jobs.scientist)


func _on_Add_mage_button_pressed():
	worker_manager.add_job(enums.jobs.mage)

func _on_Remove_mage_button_pressed():
	worker_manager.remove_job(enums.jobs.mage)

