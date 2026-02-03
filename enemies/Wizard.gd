extends CharacterBody2D

@export var speed := 200.0
@export var gravity := 1500.0
@export var attack_range := 70.0
@export var attack_cooldown_time := 1.0 

var player = null
var is_attacking = false
var can_attack = true 
var patrol_direction := 1

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	if player and not is_attacking:
		var direction = sign(player.global_position.x - global_position.x)
		var dist = global_position.distance_to(player.global_position)

		update_facing(direction)

		if dist < attack_range and can_attack:
			velocity.x = 0
			start_fireball()
		else:
			velocity.x = direction * speed
			$AnimatedSprite.play("idle") 
			
	elif not is_attacking:
		velocity.x = patrol_direction * (speed * 0.4)
		update_facing(patrol_direction)
		if is_on_wall() or not $RayCast.is_colliding():
			patrol_direction *= -1
			$RayCast.position.x *= -1 
		$AnimatedSprite.play("idle")
	else:
		velocity.x = 0

	move_and_slide()

func update_facing(dir):
	if dir != 0:
		$AnimatedSprite.flip_h = (dir == 1) 
		$AttackHitbox.scale.x = dir
		$RayCast.position.x = dir * 15

func start_fireball():
	is_attacking = true
	can_attack = false
	$AnimatedSprite.play("fireball")
	$AttackHitbox/CollisionShape.disabled = false
	$AudioStreamPlayer2D.play()

func _on_animated_sprite_animation_finished():
	if $AnimatedSprite.animation == "fireball":
		is_attacking = false
		$AttackHitbox/CollisionShape.disabled = true
		
		await get_tree().create_timer(attack_cooldown_time).timeout
		can_attack = true

func _on_player_detection_body_entered(body):
	if body.is_in_group("player"):
		player = body

func _on_player_detection_body_exited(body):
	if body == player:
		player = null

func _on_attack_damage_area_body_entered(body):
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage()

func die():
	queue_free()
