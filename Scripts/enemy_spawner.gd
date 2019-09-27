extends Node2D

var wave = 1
var wave_difficulty = 2
var wave_points = wave_difficulty
var difficulty_factor = 3
var wave_time_factor = 0.9862
var enemy_spawn_time = 0.5

onready var spawn_point_list  = {	0 : $spawn_point_collection/spawn_point_1,
									1 : $spawn_point_collection/spawn_point_2,
									2 : $spawn_point_collection/spawn_point_3,
									3 : $spawn_point_collection/spawn_point_4
								}


onready var enemy_cost_list = 	{ 	0 : [ 1 , "res://Scenes/enemy.tscn" ],
									1 : [ 8 , "res://Scenes/troll_1.tscn" ],
									2 : [ 20 , "res://Scenes/grunt_1.tscn" ]
								}


var spawn_point = null
var spawning = false
var spawn_ok = true


func _process(delta):
	if spawning == true and spawn_ok == true:
		var enemy_rand = randi() %enemy_cost_list.size()
		var enemy_cost = enemy_cost_list[enemy_rand][0]
		while enemy_cost > wave_points : 
			enemy_rand = randi() %enemy_cost_list.size()
			enemy_cost = enemy_cost_list[enemy_rand][0]
			
		wave_points -= enemy_cost
		spawn_enemy(enemy_cost_list[enemy_rand][1])
		spawn_ok = false
		if wave_points > 1 :
			$enemy_spawn_timer.start()
		else :
			print("wave end")
			wave += 1
			spawning = false
			$wave_timer.start()


func new_wave():
	pick_spawn_point()
	setup_wave_spec()	


func pick_spawn_point():
	spawn_point = spawn_point_list[randi() %spawn_point_list.size()]


func setup_wave_spec():
	set_wave_points()
	$enemy_spawn_timer.wait_time = enemy_spawn_time / wave
	$wave_timer.wait_time = $wave_timer.wait_time * wave_time_factor
	print(str($wave_timer.wait_time))
	print("wave start : " + str(wave))
	spawning = true
	spawn_ok = true


func set_wave_points():
	wave_points = wave * difficulty_factor


func spawn_enemy(ref):
	var enemy = load(ref).instance()
	enemy.global_position = spawn_point.global_position
	get_parent().get_node("YSort").add_child(enemy)


func _on_wave_timer_timeout():
	new_wave()


func _on_enemy_spawn_timer_timeout():
	spawn_ok = true
	
