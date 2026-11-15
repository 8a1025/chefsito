extends Area2D

const VELOCIDAD = 190.0

var direccion = Vector2.RIGHT
var aviso = 0.9
var tiempo = 0.0
var disparada = false

@onready var linea_aviso = $Aviso
@onready var sprite = $Sprite2D


func _ready():
	add_to_group("ataque")
	rotation = direccion.angle()
	sprite.visible = false
	monitoring = false
	body_entered.connect(_on_body_entered)


func _process(delta):
	tiempo += delta
	if tiempo < aviso:
		linea_aviso.modulate.a = 0.3 + 0.3 * sin(tiempo * 20.0)
		return
	if not disparada:
		disparada = true
		linea_aviso.visible = false
		sprite.visible = true
		set_deferred("monitoring", true)
	position += direccion * VELOCIDAD * delta
	if tiempo > aviso + 5.0:
		queue_free()


func _on_body_entered(body):
	if body.has_method("muerte"):
		get_tree().call_group("arena", "danar_jugador")
		queue_free()
	elif body.is_in_group("paredes"):
		queue_free()
