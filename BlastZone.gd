extends Area2D

func _on_body_entered(body):
	if body.is_in_group("player"):
		print("Player fell into the abyss!")
		if body.has_method("die"):
			body.die()
