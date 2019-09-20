extends "res://Scripts/building.gd"

var attack_range = 128
var target = null
var attack_ready = false
var attack_ref = "res://Scenes/projectile.tscn"
var target_list = []
var attack_cooldown = 1


func _ready():
	$detection_area/CollisionShape2D.shape.set_radius(attack_range)
	$attack_cooldown.wait_time = attack_cooldown


func _init():
	reference = "res://Scenes/tower_base.tscn"
	size = 1
	cost = 100
	tile_index = 19
	building_tile_index = 20
	destroyed_tile_index = 20
	health_max = 50
	$ProgressBar.max_value = health_max
	mouse_offset = fmod(size+1,2) * Vector2(16,16)	# mouse_offset = 16,16 if size is en even number,  0,0 otherwise
	position_offset = fmod(size,2) * Vector2(16,16)	# position_offset = 16,16 if size is en odd number,  0,0 otherwise
	tile_offset = floor(size/2) * Vector2(-1,-1)	# tile_offset = (0,0) is size  = 1, (-1,-1) otherwise
	_name = "tower_base"


func _process(delta):
	target_list = $detection_area.get_overlapping_areas()
	#print(str(is_instance_valid(target)))
	if is_instance_valid(target) and target_list.has(target.get_node("Area2D")) :
		attack(target)
	elif target_list.size()>0:
		target = target_list[0].get_parent()
	else :
		target = null
	$Label2.text = str(target)


func attack(my_target) :
	if attack_ready == true and state == enums.building_states.operate :
		var attack = load(str(attack_ref)).instance()
		attack.global_position = self.global_position
		attack.target = my_target
		get_parent().add_child(attack)
		attack_ready = false


func _on_attack_cooldown_timeout():
	if attack_ready == false : attack_ready = true

