extends Area2D

@export_file("*.tscn") var target_room_path: String
@export var target_spawn_name: String # Type the name of the Marker2D here (e.g., "WestEntrance")

func _on_body_entered(body):
	if body.is_in_group("player"):
		# We pass BOTH the room and the specific entrance name
		get_tree().current_scene.load_room(target_room_path, target_spawn_name)
