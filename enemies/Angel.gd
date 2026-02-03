extends CharacterBody2D

@export var wander_speed := 80.0
@export var charge_speed := 300.0
@export var detection_range := 400.0

var player = null
var wander_target = Vector2.ZERO
var is_charging = false

func _ready():
	pick_new_wander_target()

func _physics_process(_delta):
	if player:
		is_charging = true
		$AnimatedSprite.play("attack")

		var dir = (player.global_position - global_position).normalized()
		velocity = dir * charge_speed
		
		$AnimatedSprite.flip_h = (dir.x < 0)
	else:
		is_charging = false
		$AnimatedSprite.play("idle")
		
		var dir = (wander_target - global_position).normalized()
		velocity = dir * wander_speed
		
		$AnimatedSprite.flip_h = (velocity.x < 0)

		if global_position.distance_to(wander_target) < 20:
			pick_new_wander_target()

	move_and_slide()

func pick_new_wander_target():
	var random_offset = Vector2(randf_range(-200, 200), randf_range(-100, 100))
	wander_target = global_position + random_offset


func _on_player_detection_body_entered(body):
	if body.is_in_group("player"):
		player = body
		$AudioStreamPlayer2D.play()

func _on_player_detection_body_exited(body):
	if body == player:
		player = null
		
func _on_hit_box_body_entered(body):
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage()
			print("Angel hit the player!")

func die():
	queue_free()
