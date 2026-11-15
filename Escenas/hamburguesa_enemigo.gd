extends Node2D

@onready var anim = $AnimatedSprite2D

var muerta = false


func _ready():
	anim.play("bounce")


func _on_area_2d_body_entered(body):
	if not muerta and body.has_method("muerte"):
		body.muerte()


func morir():
	if muerta:
		return
	muerta = true
	$Area2D.set_deferred("monitoring", false)
	anim.play("death")
	await anim.animation_finished
	queue_free()
