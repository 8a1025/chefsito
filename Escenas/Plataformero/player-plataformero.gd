extends CharacterBody2D


const SPEED = 125.0
const JUMP_VELOCITY = -225.0

@onready var anim = $Sprite2D
@onready var espatula = $Espatula

var atacando = false
var muerto = false


func _ready() -> void:
	anim.animation_finished.connect(_on_anim_terminada)


func add_coin():
	Juego.agregar_zanahoria()


func muerte():
	if muerto:
		return
	muerto = true
	atacando = false
	velocity = Vector2(0, -180)
	anim.play("Death")
	await get_tree().create_timer(1.5).timeout
	get_tree().reload_current_scene()


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if muerto:
		velocity.x = 0
		move_and_slide()
		return

	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	if Input.is_action_just_pressed("Attack") and not atacando:
		atacando = true
		anim.play("Attack")

	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		if not atacando:
			anim.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

	espatula.scale.x = -1 if anim.flip_h else 1

	if atacando:
		if anim.frame >= 2 and anim.frame <= 4:
			for area in espatula.get_overlapping_areas():
				var enemigo = area.get_parent()
				if enemigo.has_method("morir"):
					enemigo.morir()
		return

	if not is_on_floor() and velocity.y < 0:
		anim.play("Jump")
	elif direction != 0:
		anim.play("Walk")
	else:
		anim.play("Idle")


func _on_anim_terminada() -> void:
	if anim.animation == "Attack":
		atacando = false
