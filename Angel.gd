extends CharacterBody2D

@export var wander_speed := 80.0
@export var charge_speed := 300.0
@export var detection_range := 400.0

var player = null
var wander_target = Vector2.ZERO
var is_charging = false

@onready var sprite = $AnimatedSprite

func _ready():
	# Set an initial random direction to float toward
	pick_new_wander_target()

func _physics_process(_delta):
	if player:
		# --- CHARGE STATE ---
		is_charging = true
		sprite.play("attack") # Swap to your attack animation
		
		# Move directly toward the player's center
		var dir = (player.global_position - global_position).normalized()
		velocity = dir * charge_speed
		
		# Flip to face player
		sprite.flip_h = (dir.x < 0)
	else:
		# --- WANDER STATE ---
		is_charging = false
		sprite.play("idle")
		
		# Move toward the current wander point
		var dir = (wander_target - global_position).normalized()
		velocity = dir * wander_speed
		
		sprite.flip_h = (velocity.x < 0)

		# If we reach the point, pick a new one
		if global_position.distance_to(wander_target) < 20:
			pick_new_wander_target()

	move_and_slide()

func pick_new_wander_target():
	# Picks a random spot within a 200px circle of its current position
	var random_offset = Vector2(randf_range(-200, 200), randf_range(-100, 100))
	wander_target = global_position + random_offset

# --- Signals ---

func _on_player_detection_body_entered(body):
	if body.is_in_group("player"):
		player = body

func _on_player_detection_body_exited(body):
	if body == player:
		player = null
		
# This should be connected to the Area2D that is meant to hurt the player
func _on_hit_box_body_entered(body):
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage()
			print("Angel hit the player!")

func die():
	queue_free()
