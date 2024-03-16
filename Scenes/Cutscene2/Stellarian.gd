extends CharacterBody2D

# Constants
const GRAVITY = 800
const MOVE_SPEED = 150
const JUMP_SPEED = -300

var is_on_ground = false

func _ready():
	$Username.text = "Subject_" + str(randi_range(100, 999))

func _physics_process(delta):
	# Apply Gravity
	velocity.y += GRAVITY * delta

	# Move Horizontally
	velocity.x = 0
	if Input.is_action_pressed("right"):
		velocity.x += MOVE_SPEED
		$Sprite.flip_h = false
		if is_on_ground:
			$Sprite.play("Walk")
	elif Input.is_action_pressed("left"):
		velocity.x -= MOVE_SPEED
		$Sprite.flip_h = true
		if is_on_ground:
			$Sprite.play("Walk")
	else:
		if is_on_ground:
			$Sprite.play("Idle")

	# Jump
	if is_on_ground and Input.is_action_just_pressed("up"):
		velocity.y = JUMP_SPEED
		is_on_ground = false
		# Update Sprite Animation
		$Sprite.play("Jump")

	# Move the player
	floor_max_angle = deg_to_rad(89)
	
	floor_snap_length  = 3
	
	move_and_slide()

	# Check if on ground
	is_on_ground = is_on_floor()

	# Check if falling
	if velocity.y > 10:
		# Update Sprite Animation
		$Sprite.play("Fall")
		pass
