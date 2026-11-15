extends Node2D

const CAIDA = 0.3
const RADIO_GOLPE = 16.0

var aviso = 1.0
var objetivo: Node2D
var tiempo = 0.0
var cayo = false

@onready var sombra = $Sombra
@onready var pepinillo = $Pepinillo


func _ready():
	add_to_group("ataque")
	pepinillo.visible = false
	sombra.scale = Vector2(0.3, 0.3)


func _process(delta):
	tiempo += delta
	if cayo:
		if tiempo > aviso + 0.5:
			queue_free()
		return

	var avance = clamp(tiempo / aviso, 0.0, 1.0)
	sombra.scale = Vector2.ONE * lerp(0.3, 1.2, avance)
	if tiempo > aviso - 0.35 and int(tiempo * 16.0) % 2 == 0:
		sombra.modulate = Color(0.9, 0.1, 0.1, 0.7)
	else:
		sombra.modulate = Color(0, 0, 0, 0.5)

	var falta = aviso - tiempo
	if falta <= CAIDA:
		pepinillo.visible = true
		pepinillo.position.y = -220.0 * (falta / CAIDA)
		pepinillo.frame = int(tiempo * 12.0) % 2

	if tiempo >= aviso:
		impacto()


func impacto():
	cayo = true
	pepinillo.position.y = 0
	pepinillo.frame = 2
	sombra.visible = false
	if objetivo and objetivo.global_position.distance_to(global_position) < RADIO_GOLPE:
		get_tree().call_group("arena", "danar_jugador")
