extends Node2D

const GIRO_AVISO = 2.2
const GIRO_RAYO = 0.35
const CONGELAR_ANTES = 0.35
const ANCHO_DANO = 6.0

var aviso = 1.0
var duracion = 1.4
var objetivo: Node2D
var desfase = 0.0
var perseguir_al_disparar = true
var tiempo = 0.0

@onready var linea_aviso = $Aviso
@onready var rayo = $Rayo
@onready var golpe = $Golpe


func _ready():
	add_to_group("ataque")
	rayo.visible = false
	golpe.monitoring = false
	var forma = $Golpe/CollisionShape2D.shape.duplicate()
	forma.size.y = ANCHO_DANO
	$Golpe/CollisionShape2D.shape = forma
	if objetivo:
		global_rotation = (objetivo.global_position - global_position).angle() + desfase


func _process(delta):
	tiempo += delta

	var apuntando = tiempo < aviso - CONGELAR_ANTES
	var disparando = tiempo >= aviso
	if objetivo:
		var deseado = (objetivo.global_position - global_position).angle() + desfase
		if apuntando:
			global_rotation = rotate_toward(global_rotation, deseado, GIRO_AVISO * delta)
		elif disparando and perseguir_al_disparar:
			global_rotation = rotate_toward(global_rotation, deseado, GIRO_RAYO * delta)

	if not disparando:
		linea_aviso.width = 1.0 + 3.0 * (tiempo / aviso)
		if not apuntando:
			linea_aviso.modulate.a = 1.0
			linea_aviso.default_color = Color(1, 1, 1, 0.9)
		else:
			linea_aviso.modulate.a = 0.4 + 0.4 * sin(tiempo * 25.0)
	elif not rayo.visible:
		linea_aviso.visible = false
		rayo.visible = true
		golpe.monitoring = true

	if rayo.visible:
		rayo.width = 12.0 + 2.0 * sin(tiempo * 40.0)
		for cuerpo in golpe.get_overlapping_bodies():
			if cuerpo.has_method("muerte"):
				get_tree().call_group("arena", "danar_jugador")

	if tiempo > aviso + duracion:
		queue_free()
