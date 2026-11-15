extends Area2D


func _on_body_entered(body):
	if body.has_method("add_coin"):
		body.add_coin()
		queue_free()
