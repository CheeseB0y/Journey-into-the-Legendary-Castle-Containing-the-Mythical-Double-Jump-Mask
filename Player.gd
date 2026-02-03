extends CharacterBody2D

@export var speed := 300.0
@export var jump_force := 500.0
@export var gravity := 2500.0
@export var max_health := 3

var current_health := 3
var is_invincible := false
var can_double_jump := false
var has_double_jumped := false
var is_attacking := false
var is_dead := false
var is_crouching := false

func _ready():
	await get_tree().process_frame
	update_camera_limits()

func update_camera_limits(specific_tilemap = null):
	var tilemap = specific_tilemap
	
	if tilemap == null:
		tilemap = get_tree().get_first_node_in_group("level_tiles")
		
	var camera = $Camera
	if tilemap and camera:
		var map_rect = tilemap.get_used_rect()
		var tile_size = tilemap.tile_set.tile_size
		
		camera.limit_left = map_rect.position.x * tile_size.x
		camera.limit_top = map_rect.position.y * tile_size.y
		camera.limit_right = map_rect.end.x * tile_size.x
		camera.limit_bottom = map_rect.end.y * tile_size.y

func _physics_process(delta):
	if is_dead: return

	var was_in_air = not is_on_floor()

	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		has_double_jumped = false
	
	if Input.is_action_pressed("ui_down") and is_on_floor() and not is_attacking:
		is_crouching = true
		velocity.x = 0
	else:
		is_crouching = false

	if Input.is_action_just_pressed("kick") and not is_attacking:
		kick()
		
	if Input.is_action_just_pressed("punch") and not is_attacking:
		punch()

	if Input.is_action_just_pressed("ui_accept") and not is_attacking:
		if is_on_floor():
			velocity.y = -jump_force
			is_crouching = false
		elif can_double_jump and not has_double_jumped:
			velocity.y = -jump_force
			has_double_jumped = true

	var dir = Input.get_axis("ui_left", "ui_right")

	if is_on_floor() and is_attacking:
		velocity.x = move_toward(velocity.x, 0, speed * 0.05)
		
	elif is_crouching:
		velocity.x = 0
		
	else:
		velocity.x = dir * speed

	move_and_slide()
	
	# Landing cleanup
	if is_on_floor() and was_in_air:
		if is_attacking and $AnimatedSprite.animation == "jumping_kick":
			is_attacking = false
			$JumpingKickHitbox/CollisionShape.disabled = true

	update_animations(dir)

func kick():
	is_attacking = true
	if not is_on_floor():
		$AnimatedSprite.play("jumping_kick")
		$JumpingKickHitbox/CollisionShape.disabled = false
	elif is_crouching:
		$AnimatedSprite.play("crouching_kick")
		$CrouchingKickHitbox/CollisionShape.disabled = false
	else:
		$AnimatedSprite.play("kick")
		$KickHitbox/CollisionShape.disabled = false 
		
	$PunchSoundPlayer.play()

func punch():
	is_attacking = true
	$AnimatedSprite.play("punch")
	$PunchSoundPlayer.play()
	$PunchHitbox/CollisionShape.disabled = false
	
func update_animations(dir):
	if is_attacking or is_dead: return

	if not is_on_floor():
		if velocity.y < 0:
			$AnimatedSprite.play("jump")
		else:
			$AnimatedSprite.play("fall")
	elif is_crouching:
		$AnimatedSprite.play("crouch")
	elif dir != 0:
		$AnimatedSprite.play("walk")
	else:
		$AnimatedSprite.play("idle")

	if not is_crouching and dir != 0:
		$AnimatedSprite.flip_h = (dir < 0)

func _on_animated_sprite_animation_finished():
	var attacks = ["kick", "punch", "jumping_kick", "crouching_kick"]
	if $AnimatedSprite.animation in attacks:
		is_attacking = false
		$KickHitbox/CollisionShape.disabled = true
		$JumpingKickHitbox/CollisionShape.disabled = true
		$CrouchingKickHitbox/CollisionShape.disabled = true
		$PunchHitbox/CollisionShape.disabled = true
		
func take_damage():
	if is_dead or is_invincible: return
	
	current_health -= 1
	print("Health remaining: ", current_health)
	
	start_invincibility()

	if current_health <= 0:
		die()
	else:
		velocity.y = -300
		var tween = create_tween()
		tween.tween_property($AnimatedSprite, "modulate", Color.RED, 0.1)
		tween.tween_property($AnimatedSprite, "modulate", Color.WHITE, 0.1)
	
	update_hud()

func start_invincibility():
	is_invincible = true
	var blink_tween = create_tween().set_loops(5)
	blink_tween.tween_property($AnimatedSprite, "modulate:a", 0.5, 0.1)
	blink_tween.tween_property($AnimatedSprite, "modulate:a", 1.0, 0.1)
	
	await get_tree().create_timer(1.0).timeout
	is_invincible = false
	
func update_hud():
	var heart_nodes = get_tree().get_nodes_in_group("hearts") 
	for i in range(heart_nodes.size()):
		heart_nodes[i].visible = i < current_health

func die():
	is_dead = true
	$AnimatedSprite.play("idle") 
	$AnimatedSprite.stop()
	modulate = Color.BLACK
	
	print("Player defeated!")
	await get_tree().create_timer(1.0).timeout
	get_tree().reload_current_scene()

func _on_kick_hitbox_area_entered(area):
	if area.name == "HurtBox":
		var enemy = area.get_parent()
		if enemy.has_method("die"):
			enemy.die()

func _on_punch_hitbox_area_entered(area):
	if area.name == "HurtBox":
		var enemy = area.get_parent()
		if enemy.has_method("die"):
			enemy.die()
	
func _on_jumping_kick_hitbox_area_entered(area):
	if area.name == "HurtBox":
		var enemy = area.get_parent()
		if enemy.has_method("die"):
			enemy.die()
			
func _on_crouching_kick_hitbox_area_entered(area):
	if area.name == "HurtBox":
		var enemy = area.get_parent()
		if enemy.has_method("die"):
			enemy.die()
