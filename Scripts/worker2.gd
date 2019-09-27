extends Node2D


onready var jobs  = {	0 : "Jobs/Jobless",
						1 : "Jobs/Woodcutter",
						2 : "Jobs/Builder",
						3 : "Jobs/Scientist",
						4 : "Jobs/Mage"
						}


var current_job = 0
var ready_to_seek = false
var research_ready = true

var home_building = null

var max_search_dist = 15

var speed = units_stats.worker_speed
var anim_update = true
var direction = "Up"

var at_home = false

var strike_ready = true
var damage = units_stats.worker_damage
var ressource_bonus = units_stats.worker_ressource_bonus
var repair_amount = 5
var carried_ressource = 0
var carried_max = units_stats.worker_carried_max

onready var map = get_tree().get_root().get_node("World/nav/map_structure")
onready var mytile  = map.world_to_map(self.position)


func _process(delta):
	$Label2.text = str(carried_ressource)
	$Label3.text = str(home_building)
	get_node(jobs[current_job])._update(delta)


func change_job(new_job):
	get_node(jobs[current_job]).quit_job()
	get_node(jobs[new_job]).start_job()
	current_job = new_job
	


func _on_strike_cooldown_timeout():
	strike_ready = true


func _on_seek_cooldown_timeout():
	ready_to_seek = true


func _on_research_cooldown_timeout():
	research_ready = true
