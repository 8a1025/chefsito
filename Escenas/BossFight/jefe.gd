extends Node2D

@onready var anim = $AnimatedSprite2D

var base_x = 0.0
var tiempo = 0.0
var ocupado = 0.0
var cansada = false
var muerta = false
var nivel = 0


func _ready():
	base_x = position.x
	anim.play("idle")


func _process(delta):
	if muerta:
		return
	tiempo += delta * (1.0 + nivel * 0.25)
	if not cansada:
		var amplitud = 70.0 + nivel * 15.0
		position.x = base_x + sin(tiempo * 0.7) * amplitud
	if ocupado > 0.0:
		ocupado -= delta
		if ocupado <= 0.0:
			anim.play("idle")


func atacar(segundos = 0.8):
	if muerta:
		return
	anim.play("ataque")
	ocupado = segundos


func golpe():
	if muerta:
		return
	anim.play("golpe")
	ocupado = 0.15


func cansado():
	cansada = true
	anim.speed_scale = 0.5
	var volver = create_tween()
	volver.tween_property(self, "position:x", base_x, 1.0)


func morir():
	muerta = true
	anim.speed_scale = 1.0
	anim.play("muerte")
	$Cuerpo/CollisionShape2D.set_deferred("disabled", true)
