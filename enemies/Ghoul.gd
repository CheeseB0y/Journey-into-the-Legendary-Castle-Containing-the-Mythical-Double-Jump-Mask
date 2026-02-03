extends CharacterBody2D

@export var walk_speed := 100.0
@export var run_speed := 250.0
@export var gravity := 2000.0

var player = null
var patrol_direction := -1

func _physics_process(delta):
    if not is_on_floor():
        velocity.y += gravity * delta

    if player:
        var direction = sign(player.global_position.x - global_position.x)
        velocity.x = direction * run_speed
        
        update_facing(direction)
        $AnimatedSprite.play("run")

    else:
        velocity.x = patrol_direction * walk_speed
        
        update_facing(patrol_direction)
        $AnimatedSprite.play("walk")
        
        if is_on_wall():
            patrol_direction *= -1

    move_and_slide()

func update_facing(dir):
    if dir != 0:
        $AnimatedSprite.flip_h = (dir == 1)

func _on_player_detection_body_entered(body):
    if body.is_in_group("player"):
        player = body
        $AudioStreamPlayer2D.play()

func _on_player_detection_body_exited(body):
    if body == player:
        player = null
        $AudioStreamPlayer2D.stop()

func _on_hitbox_body_entered(body):
    if body.is_in_group("player") and body.has_method("take_damage"):
        body.take_damage()

func die():
    queue_free()
