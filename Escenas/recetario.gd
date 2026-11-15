extends CanvasLayer

@onready var lista = $Panel/VBoxContainer/Lista
@onready var zanahorias_label = $Panel/VBoxContainer/Zanahorias
@onready var mensaje = $Panel/VBoxContainer/Mensaje


func _ready():
	visible = false
	$Panel/VBoxContainer/Cerrar.pressed.connect(cerrar)
	for id in Juego.RECETAS:
		var boton = Button.new()
		boton.name = id
		boton.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		boton.add_theme_font_size_override("font_size", 10)
		boton.pressed.connect(comprar.bind(id))
		lista.add_child(boton)


func _unhandled_input(event):
	if event.is_action_pressed("recetario"):
		if visible:
			cerrar()
		else:
			abrir()


func abrir():
	visible = true
	get_tree().paused = true
	mensaje.text = ""
	actualizar()


func cerrar():
	visible = false
	get_tree().paused = false


func actualizar():
	zanahorias_label.text = "Zanahorias: %d" % Juego.zanahorias
	for boton in lista.get_children():
		var id = String(boton.name)
		var receta = Juego.RECETAS[id]
		if id in Juego.recetas_compradas:
			boton.text = "✓ " + receta["nombre"]
			boton.disabled = true
		else:
			boton.text = "%s - %d" % [receta["nombre"], receta["precio"]]


func comprar(id):
	if Juego.comprar_receta(id):
		mensaje.text = "¡Aprendiste: " + Juego.RECETAS[id]["nombre"] + "!"
	else:
		mensaje.text = "Te faltan zanahorias"
	actualizar()
