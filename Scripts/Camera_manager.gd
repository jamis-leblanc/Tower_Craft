extends Camera2D

enum camera_states { moving, not_moving}

var camera_state = camera_states.not_moving
var mouse_start_position = Vector2()
var camera_start_position = Vector2()


func _ready():
	pass # Replace with function body.


func _process(delta):
	if Input.is_action_pressed("mouse_middle_clic") :
		if camera_state == camera_states.not_moving :
			mouse_start_position = get_global_mouse_position()
			camera_start_position = self.global_position
			camera_state = camera_states.moving
		else : update_camera_position()
		
	if not Input.is_action_pressed("mouse_middle_clic") :
		camera_state = camera_states.not_moving
		mouse_start_position = Vector2()
		camera_start_position = Vector2()




func update_camera_position():
	self.global_position = camera_start_position - (get_global_mouse_position() - mouse_start_position)*5
	
	self.global_position.x = clamp(self.global_position.x,	(get_viewport().get_visible_rect().size.x  * self.get_zoom().x )/2,\
															get_parent().map_size.x - (get_viewport().get_visible_rect().size.x * self.get_zoom().x)/2)
	self.global_position.y = clamp(self.global_position.y,	(get_viewport().get_visible_rect().size.y * self.get_zoom().y)/2 ,\
															get_parent().map_size.y - (get_viewport().get_visible_rect().size.y * self.get_zoom().y)/2)
	#print(get_viewport().get_visible_rect().size)
	#print(self.get_zoom())
