extends Node

signal zanahorias_cambiaron(cantidad)

const RECETAS = {
	"sopa": {"nombre": "Sopa de zanahoria", "precio": 5},
	"ensalada": {"nombre": "Ensalada de frutas", "precio": 10},
	"jugo": {"nombre": "Jugo verde", "precio": 15},
	"brocoli": {"nombre": "Brócoli al vapor", "precio": 20},
}

var zanahorias = 0
var recetas_compradas = []


func agregar_zanahoria():
	zanahorias += 1
	zanahorias_cambiaron.emit(zanahorias)


func comprar_receta(id) -> bool:
	if id in recetas_compradas:
		return false
	var precio = RECETAS[id]["precio"]
	if zanahorias < precio:
		return false
	zanahorias -= precio
	recetas_compradas.append(id)
	zanahorias_cambiaron.emit(zanahorias)
	return true
