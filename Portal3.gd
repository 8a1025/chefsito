extends Node2D



func _on_area_2d_body_entered(body):
	if body is CharacterBody2D:
		get_tree().call_deferred("change_scene_to_file", "res://Escenas/level_4.tscn")
