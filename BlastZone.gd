extends Area2D

func _on_body_entered(body):
	# Check if the thing that fell in is the player
	if body.is_in_group("player"):
		print("Player fell into the abyss!")
		
		# Since your player's take_damage() handles death and reloading,
		# we just call that.
		if body.has_method("die"):
			body.die()
