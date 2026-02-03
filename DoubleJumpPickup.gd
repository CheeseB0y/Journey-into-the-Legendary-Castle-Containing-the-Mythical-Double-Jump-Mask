extends Area2D

var was_opened = false

func _ready():
	$AnimatedSprite2D.play("default")	
	await get_tree().process_frame
	var player = get_tree().get_first_node_in_group("player")

	if player and player.can_double_jump == true:
		queue_free() 

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not was_opened:
		was_opened = true
		body.can_double_jump = true
		$AnimatedSprite2D.play("open")
		$AudioStreamPlayer2D.play()
		show_ui_message()

func show_ui_message():
	$CanvasLayer/Label.visible = true
	$CanvasLayer/Label.modulate.a = 1.0
	
	var tween = create_tween()
	tween.tween_interval(2.0)
	tween.tween_property($CanvasLayer/Label, "modulate:a", 0.0, 1.0)
	tween.tween_callback(queue_free)
