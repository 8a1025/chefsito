extends Node2D

const PEPINILLO = preload("res://Escenas/BossFight/Pepinillo.tscn")
const PAPA = preload("res://Escenas/BossFight/Papa.tscn")
const LECHUGA = preload("res://Escenas/BossFight/Lechuga.tscn")
const SALSA = preload("res://Escenas/BossFight/Salsa.tscn")
const FOTO_TU_PUEDES = preload("res://Assets/BossFight/animo_tu_puedes.png")
const FOTO_PODER = preload("res://Assets/BossFight/animo_saca_tu_poder.png")

const PULSO = 60.0 / 175.0
const DESVANECER = 0.3
const VIDA_MAX = 16
const VIDA_MINIMA_ANTES_DEL_FINAL = 3
const LIMITES = Rect2(32, 64, 416, 180)
const ESCENA_SALIDA = "res://Escenas/map.tscn"
const AVISOS = {"rugido": 0.0, "salsa": 1.0, "salsa_doble": 1.2, "pepinillos": 1.0, "papas": 0.9, "lechuga": 0.0}

const RAFAGAS = [0.25, 3.0, 11.0, 13.75, 16.5, 19.25]
const LECHUGAS = [6.0, 8.0, 10.0]

const FASES = [
	[["rugido"], ["salsa"], ["papas:8"], ["salsa"], ["papas:8:22"], ["salsa"]],
	[["pepinillos:3"], ["salsa"], ["papas:10"], ["pepinillos:4"], ["salsa", "papas:8"], ["pepinillos:4"]],
	[["salsa", "pepinillos:3"], ["papas:12:15"], ["pepinillos:5"], ["salsa", "papas:10"], ["pepinillos:5", "papas:10:18"], ["salsa_doble"]],
	[["pepinillos:6", "papas:12"], ["salsa_doble"], ["papas:14:12"], ["salsa", "pepinillos:5"], ["papas:14", "pepinillos:4"], ["salsa_doble", "papas:10"]],
	[["papas:16", "pepinillos:6"], ["salsa_doble", "pepinillos:4"], ["papas:16:11", "salsa"], ["pepinillos:8"], ["salsa_doble", "papas:14"], ["papas:16:11", "pepinillos:6"]],
	[["salsa_doble", "pepinillos:6"], ["papas:18", "salsa"], ["pepinillos:8", "papas:14:12"], ["salsa_doble", "papas:16"], ["pepinillos:8", "salsa_doble"], ["papas:18:10", "pepinillos:8"]],
]
const FINAL = [["papas:20", "pepinillos:8"], ["salsa_doble", "pepinillos:6"]]

@onready var musica = $Musica
@onready var jefe = $Jefe
@onready var jugador = $Player
@onready var barra = $UI/BarraJefe
@onready var corazones = [$UI/Corazones/C1, $UI/Corazones/C2, $UI/Corazones/C3]
@onready var mensaje = $UI/Mensaje
@onready var pantalla_victoria = $UI/Victoria

var base = 0.0
var largo = 20.0
var eventos = []
var indice = 0
var vida_jefe = VIDA_MAX
var vidas = 3
var invulnerable = false
var terminado = false
var fase_final = false
var en_dialogo = false
var inicio_final = 0.0
var proxima_lechuga_final = 0.0

var dialogo: Panel
var dialogo_foto: TextureRect
var dialogo_texto: Label


func _ready():
	add_to_group("arena")
	var camara_jugador = jugador.get_node_or_null("Camera2D")
	if camara_jugador:
		camara_jugador.enabled = false
	$Camara.make_current()

	var cancion = musica.stream
	if cancion is AudioStreamWAV:
		cancion.loop_mode = AudioStreamWAV.LOOP_DISABLED
	largo = cancion.get_length()
	musica.finished.connect(interludio)

	inicio_final = FASES.size() * largo + 5.5
	proxima_lechuga_final = inicio_final + 0.3

	barra.max_value = VIDA_MAX
	barra.value = VIDA_MAX
	mensaje.visible = false
	pantalla_victoria.visible = false
	crear_dialogo()
	crear_eventos()

	musica.volume_db = -25.0
	musica.play()
	create_tween().tween_property(musica, "volume_db", 0.0, 0.6)


func crear_dialogo():
	dialogo = Panel.new()
	dialogo.size = Vector2(270, 70)
	dialogo.position = Vector2(105, -80)
	var estilo = StyleBoxFlat.new()
	estilo.bg_color = Color(0.12, 0.08, 0.06, 0.92)
	estilo.border_color = Color(1, 0.8, 0.3)
	estilo.set_border_width_all(2)
	estilo.set_corner_radius_all(6)
	dialogo.add_theme_stylebox_override("panel", estilo)
	$UI.add_child(dialogo)

	dialogo_foto = TextureRect.new()
	dialogo_foto.position = Vector2(5, 5)
	dialogo_foto.size = Vector2(50, 60)
	dialogo_foto.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	dialogo_foto.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	dialogo_foto.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	dialogo.add_child(dialogo_foto)

	dialogo_texto = Label.new()
	dialogo_texto.position = Vector2(60, 5)
	dialogo_texto.size = Vector2(205, 60)
	dialogo_texto.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	dialogo_texto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	dialogo_texto.autowrap_mode = TextServer.AUTOWRAP_WORD
	dialogo_texto.add_theme_font_size_override("font_size", 16)
	dialogo_texto.add_theme_color_override("font_color", Color(1, 0.85, 0.35))
	dialogo_texto.add_theme_color_override("font_outline_color", Color.BLACK)
	dialogo_texto.add_theme_constant_override("outline_size", 4)
	dialogo.add_child(dialogo_texto)


func decir(foto, texto):
	dialogo_foto.texture = foto
	dialogo_texto.text = texto
	var anim = create_tween()
	anim.tween_property(dialogo, "position:y", 28.0, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	anim.tween_interval(1.3)
	anim.tween_property(dialogo, "position:y", -80.0, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	await anim.finished


func interludio():
	if terminado:
		return
	en_dialogo = true
	base += largo
	await decir(FOTO_TU_PUEDES, "¡Tú puedes!")
	await decir(FOTO_PODER, "¡Libera todo tu poder!")
	if terminado:
		return
	musica.volume_db = 0.0
	musica.play()
	en_dialogo = false


func tiempo_musica() -> float:
	if en_dialogo:
		return base
	var pos = musica.get_playback_position() + AudioServer.get_time_since_last_mix() - AudioServer.get_output_latency()
	pos = clamp(pos, 0.0, largo)
	var falta = largo - pos
	if falta < DESVANECER:
		musica.volume_db = linear_to_db(max(falta / DESVANECER, 0.01))
	return base + pos


func apagar_musica(segundos):
	var bajar = create_tween()
	bajar.tween_property(musica, "volume_db", -40.0, segundos)
	bajar.tween_callback(musica.stop)


func agregar(t_golpe, texto):
	var partes = texto.split(":")
	var tipo = partes[0]
	var datos = {}
	if partes.size() > 1:
		datos["n"] = int(partes[1])
	if partes.size() > 2:
		datos["giro"] = float(partes[2])
	var aviso = AVISOS[tipo]
	eventos.append({"t": t_golpe - aviso, "tipo": tipo, "datos": datos, "aviso": aviso})


func crear_eventos():
	for vuelta in FASES.size():
		var inicio = vuelta * largo
		for i in RAFAGAS.size():
			for ataque in FASES[vuelta][i]:
				agregar(inicio + RAFAGAS[i], ataque)
		var cuantas = 2 if vuelta == 0 else 3
		for k in cuantas:
			agregar(inicio + LECHUGAS[k], "lechuga")
		if vuelta >= 2:
			agregar(inicio + 8.6, "pepinillos:" + str(vuelta))

	var inicio_ultima = FASES.size() * largo
	for i in FINAL.size():
		for ataque in FINAL[i]:
			agregar(inicio_ultima + RAFAGAS[i], ataque)

	eventos.sort_custom(func(a, b): return a["t"] < b["t"])


func _process(_delta):
	if terminado or en_dialogo:
		return
	var t = tiempo_musica()

	jefe.nivel = min(int(t / largo), FASES.size() - 1)

	while indice < eventos.size() and eventos[indice]["t"] <= t:
		lanzar(eventos[indice])
		indice += 1

	if t >= inicio_final and not fase_final:
		fase_final = true
		vida_jefe = min(vida_jefe, VIDA_MINIMA_ANTES_DEL_FINAL)
		barra.value = vida_jefe
		jefe.cansado()

	if fase_final and t >= proxima_lechuga_final:
		lanzar_lechuga()
		proxima_lechuga_final += 1.2


func lanzar(e):
	match e["tipo"]:
		"rugido":
			jefe.atacar(1.2)
		"salsa":
			atacar_salsa(e["aviso"], [0.0], true)
		"salsa_doble":
			atacar_salsa(e["aviso"], [-0.6, 0.6], false)
		"pepinillos":
			atacar_pepinillos(e["datos"].get("n", 3), e["aviso"])
		"papas":
			atacar_papas(e["datos"].get("n", 8), e["datos"].get("giro", 0.0), e["aviso"])
		"lechuga":
			lanzar_lechuga()


func atacar_salsa(aviso, desfases, perseguir):
	for d in desfases:
		var s = SALSA.instantiate()
		s.aviso = aviso
		s.duracion = PULSO * 4
		s.objetivo = jugador
		s.desfase = d
		s.perseguir_al_disparar = perseguir
		jefe.get_node("Boca").add_child(s)
	jefe.atacar(aviso + PULSO * 4)


func atacar_pepinillos(n, aviso):
	jefe.atacar(0.6)
	for i in n:
		var p = PEPINILLO.instantiate()
		if i == 0:
			p.position = dentro_de_la_arena(jugador.global_position)
		else:
			p.position = punto_al_azar()
		p.aviso = aviso + i * PULSO * 0.75
		p.objetivo = jugador
		add_child(p)


func atacar_papas(n, giro, aviso):
	jefe.atacar(aviso + 0.3)
	for i in n:
		var p = PAPA.instantiate()
		p.position = jefe.global_position + Vector2(0, 6)
		p.direccion = Vector2.RIGHT.rotated(TAU * i / n + deg_to_rad(giro))
		p.aviso = aviso
		add_child(p)


func lanzar_lechuga():
	if vida_jefe <= 0:
		return
	var l = LECHUGA.instantiate()
	l.position = jefe.global_position
	var desvio = Vector2.RIGHT.rotated(randf() * TAU) * randf_range(50.0, 100.0)
	l.destino = dentro_de_la_arena(jugador.global_position + desvio)
	l.jefe = jefe
	add_child(l)


func punto_al_azar() -> Vector2:
	return Vector2(randf_range(LIMITES.position.x, LIMITES.end.x), randf_range(LIMITES.position.y, LIMITES.end.y))


func dentro_de_la_arena(p: Vector2) -> Vector2:
	return Vector2(clamp(p.x, LIMITES.position.x, LIMITES.end.x), clamp(p.y, LIMITES.position.y, LIMITES.end.y))


func golpe_al_jefe():
	if vida_jefe <= 0:
		return
	if fase_final:
		vida_jefe -= 1
	else:
		vida_jefe = max(vida_jefe - 1, VIDA_MINIMA_ANTES_DEL_FINAL)
	barra.value = vida_jefe
	jefe.golpe()
	if vida_jefe <= 0:
		victoria()


func danar_jugador():
	if invulnerable or terminado or vidas <= 0:
		return
	vidas -= 1
	corazones[vidas].frame = 1
	if vidas <= 0:
		terminado = true
		apagar_musica(0.8)
		if jugador.has_method("muerte"):
			jugador.muerte()
		else:
			get_tree().call_deferred("reload_current_scene")
		return
	invulnerable = true
	var parpadeo = create_tween().set_loops(6)
	parpadeo.tween_property(jugador, "modulate:a", 0.2, 0.1)
	parpadeo.tween_property(jugador, "modulate:a", 1.0, 0.1)
	await get_tree().create_timer(1.2).timeout
	invulnerable = false


func victoria():
	terminado = true
	jefe.morir()
	for ataque in get_tree().get_nodes_in_group("ataque"):
		ataque.queue_free()
	apagar_musica(3.0)
	dialogo.visible = false
	await get_tree().create_timer(1.5).timeout
	pantalla_victoria.visible = true
	pantalla_victoria.modulate.a = 0.0
	pantalla_victoria.scale = Vector2(0.6, 0.6)
	var aparecer = create_tween().set_parallel(true)
	aparecer.tween_property(pantalla_victoria, "modulate:a", 1.0, 0.5)
	aparecer.tween_property(pantalla_victoria, "scale", Vector2.ONE, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await get_tree().create_timer(5.0).timeout
	get_tree().change_scene_to_file(ESCENA_SALIDA)
