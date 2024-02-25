extends Camera2D

const CAMERA_SPEED = 300

func _process(delta):
	var velocity = Vector2.ZERO

	# Check for arrow key inputs and adjust the camera's velocity accordingly
	if Input.is_action_pressed("right"):
		velocity.x += 1
	if Input.is_action_pressed("left"):
		velocity.x -= 1
	if Input.is_action_pressed("down"):
		velocity.y += 1
	if Input.is_action_pressed("up"):
		velocity.y -= 1
	if Input.is_action_pressed("ui_page_up"):
		zoom *= 1.1
	if Input.is_action_pressed("ui_page_down"):
		zoom *= 0.9
	

	# Normalize the velocity to maintain constant speed in all directions
	velocity = velocity.normalized() * CAMERA_SPEED * delta

	# Move the camera
	position += velocity
