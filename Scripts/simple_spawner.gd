extends Node2D

var spawning_object = "res://Scenes/explosion_1.tscn"
var size = 32

signal delete()


func _on_spawn_delay_timeout():
	var instance = load(spawning_object).instance()
	add_child(instance)
	instance.position = Vector2(rand_range(-size,size),rand_range(-size,size))


func _on_spawn_duration_timeout():
	emit_signal("delete")
	queue_free()
