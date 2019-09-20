extends Node2D

func _ready():
	$AnimationPlayer.play("explosion")


func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()
