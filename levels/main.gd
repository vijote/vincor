extends Node3D

const ray_length = 1000
const vincor_layer = 1

@onready var camera = $Camera3D

var selected_vincor: StaticBody3D

func _process(delta):
	if Input.is_action_just_pressed("quit"):
		get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
		print("quit pressed!")
		
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
		
func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		get_tree().quit() # default behavior

func _physics_process(delta):
	if not Input.is_action_just_pressed("selection"):
		return
	
	# if no vincor is selected
	# assign the clicked one
	if not selected_vincor:
		select_vincor()
		return
		
	# if there is a vincor selected
	# move it to the clicked position
	move_vincor()

func cast_ray() -> Dictionary:
	var space_state = get_world_3d().direct_space_state
	var mouse_position = get_viewport().get_mouse_position()
	
	var from = camera.project_ray_origin(mouse_position)
	var to = from + camera.project_ray_normal(mouse_position) * ray_length
	var query = PhysicsRayQueryParameters3D.create(from, to)
	
	return space_state.intersect_ray(query)

func select_vincor() -> void:
	var ray_result = cast_ray()
	
	# return if clicked empty space
	if not ray_result.has("collider"):
		return

	var collided_body: StaticBody3D = cast_ray().collider
	
	# check if the clicked body is a vincor
	if collided_body.get_collision_layer_value(vincor_layer):
		selected_vincor = collided_body
	
func move_vincor() -> void:
	var ray_result = cast_ray()
	
	# return if clicked empty space
	if not ray_result.has("position"):
		return
		
	var new_position: Vector3 = ray_result.position
	
	selected_vincor.position = Vector3(new_position.x, selected_vincor.position.y, new_position.z)
	
	selected_vincor = null
