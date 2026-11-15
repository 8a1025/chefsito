extends CanvasLayer

@onready var label = $Control/Label


func _ready() -> void:
	Juego.zanahorias_cambiaron.connect(set_coins)
	set_coins(Juego.zanahorias)


func set_coins(cantidad):
	label.text = "%02d" % cantidad
