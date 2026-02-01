extends Area2D

@onready var sprite = $AnimatedSprite2D
var was_opened = false

func _ready():
	# Start with the closed chest look
	sprite.play("default")
	
	await get_tree().process_frame
	var player = get_tree().get_first_node_in_group("player")
	
	if player and player.can_double_jump == true:
		queue_free() 

func _on_body_entered(body: Node2D) -> void:
	# Only trigger if it's the player AND the chest isn't already open
	if body.is_in_group("player") and not was_opened:
		was_opened = true
		
		# Give the ability
		body.can_double_jump = true
		
		# Play the opening animation
		sprite.play("open")
		
		print("Chest opened! Double Jump Unlocked!")
		
		# Optional: If you have a separate sprite for the 'item' 
		# floating inside, you could hide it here:
		# $ItemSprite.visible = false
