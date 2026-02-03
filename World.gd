extends Node2D

@onready var room_container = $CurrentRoom
@onready var player = $Player

func _ready():
	load_room("res://rooms/Room_1.tscn", "GameStartSpawn")

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()

func toggle_pause():
	var is_paused = !get_tree().paused
	get_tree().paused = is_paused
	$PauseUI/Label.visible = is_paused
	
func load_room(room_path: String, spawn_name: String = ""):
	_do_load_room.call_deferred(room_path, spawn_name)

func _do_load_room(room_path: String, spawn_name: String):
	player.visible = false
	player.set_physics_process(false)
	player.get_node("CollisionShape").set_deferred("disabled", true)

	for child in room_container.get_children():
		child.queue_free()
	
	var room_scene = load(room_path)
	if room_scene:
		var new_room = room_scene.instantiate()
		room_container.add_child(new_room)
		
		await get_tree().process_frame 
		
		var new_tilemap = null
		
		if new_room.has_node("TileMap"):
			new_tilemap = new_room.get_node("TileMap")
		
		else:
			for child in new_room.get_children():
				if child.is_in_group("level_tiles"):
					new_tilemap = child
					break

		var all_spawns = get_tree().get_nodes_in_group("spawn_points")
		var spawn_point = null
		for s in all_spawns:
			if s.name == spawn_name:
				spawn_point = s
				break
		
		if spawn_point:
			player.global_position = spawn_point.global_position
		
		player.visible = true
		player.set_physics_process(true)
		player.get_node("CollisionShape").set_deferred("disabled", false)
		
		if new_tilemap:
			player.update_camera_limits(new_tilemap)
		else:
			print("Warning: No TileMap found in new room to set camera limits!")

	else:
		print("Error: Could not find room at ", room_path)
