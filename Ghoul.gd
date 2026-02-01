extends CharacterBody2D

@export var walk_speed := 100.0
@export var run_speed := 250.0
@export var gravity := 2000.0

var player = null
var patrol_direction := -1

@onready var sprite = $AnimatedSprite

func _physics_process(delta):
	# 1. Gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# 2. State Logic
	if player:
		# CHASE STATE
		var direction = sign(player.global_position.x - global_position.x)
		velocity.x = direction * run_speed
		
		update_facing(direction)
		sprite.play("run") # Switch to your run animation
	else:
		# PATROL STATE
		velocity.x = patrol_direction * walk_speed
		
		update_facing(patrol_direction)
		sprite.play("walk") # Switch to your walk animation
		
		if is_on_wall():
			patrol_direction *= -1

	move_and_slide()

func update_facing(dir):
	if dir != 0:
		# If he faces away, flip this (dir == 1)
		sprite.flip_h = (dir == 1)

# --- Signals ---

func _on_player_detection_body_entered(body):
	if body.is_in_group("player"):
		player = body

func _on_player_detection_body_exited(body):
	if body == player:
		player = null

# The Ghoul deals damage by touching the player
func _on_hitbox_body_entered(body):
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage()

func die():
	# Maybe add a fire-poof particle here later!
	queue_free()
