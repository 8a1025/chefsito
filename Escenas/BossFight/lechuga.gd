extends Area2D

const VUELO = 0.6
const VIDA_EN_EL_SUELO = 5.0

var destino = Vector2.ZERO
var origen = Vector2.ZERO
var jefe: Node2D
var estado = "lanzada"
var tiempo = 0.0
var velocidad = 60.0

@onready var sprite = $Sprite2D


func _ready():
	add_to_group("ataque")
	origen = global_position
	monitoring = false
	body_entered.connect(_on_body_entered)


func _process(delta):
	tiempo += delta
	match estado:
		"lanzada":
			var a = clamp(tiempo / VUELO, 0.0, 1.0)
			global_position = origen.lerp(destino, a) + Vector2(0, -40.0 * sin(a * PI))
			rotation += delta * 10.0
			if a >= 1.0:
				estado = "suelo"
				tiempo = 0.0
				rotation = 0.0
				set_deferred("monitoring", true)
		"suelo":
			sprite.frame = int(tiempo * 4.0) % 2
			if tiempo > VIDA_EN_EL_SUELO - 1.5:
				visible = int(tiempo * 10.0) % 2 == 0
			if tiempo > VIDA_EN_EL_SUELO:
				queue_free()
		"al_jefe":
			if jefe == null:
				queue_free()
				return
			velocidad += 400.0 * delta
			var hacia = jefe.global_position - global_position
			global_position += hacia.normalized() * velocidad * delta
			rotation += delta * 15.0
			if hacia.length() < 16.0:
				get_tree().call_group("arena", "golpe_al_jefe")
				queue_free()


func _on_body_entered(body):
	if estado == "suelo" and body.has_method("muerte"):
		estado = "al_jefe"
		visible = true
		sprite.frame = 1
		set_deferred("monitoring", false)
