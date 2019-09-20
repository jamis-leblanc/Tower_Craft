extends Node2D

var speed = 400
var damage = 1
var target = null
var dir


func _ready():
	dir = target.global_position - global_position
	dir = dir.normalized()
	$AnimationPlayer.play("Fly")


func _process(delta):
	position += dir * speed * delta


func _on_Area2D_area_entered(area):
	if area.get_parent().is_in_group("Enemy"):
		area.get_parent().get_damage(damage)
		$AnimationPlayer.play("explode")
		speed = 0


func _on_VisibilityNotifier2D_viewport_exited(viewport):
	queue_free()
	

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "explode" :
		queue_free()

