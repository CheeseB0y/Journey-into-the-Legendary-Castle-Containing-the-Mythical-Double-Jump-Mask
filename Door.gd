extends Area2D

@export_file("*.tscn") var target_room_path: String
@export var target_spawn_name: String

func _on_body_entered(body):
	if body.is_in_group("player"):
		get_tree().current_scene.load_room(target_room_path, target_spawn_name)
