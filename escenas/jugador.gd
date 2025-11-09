# Jugador.gd
extends CharacterBody2D

@export var velocidad := 450.0
@export var inventario: Array = []

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var espada = $Espada    

var direccion_mirada: Vector2 = Vector2.RIGHT 

func _physics_process(delta: float) -> void:
	var direccion = Vector2.ZERO
	direccion.x = Input.get_action_strength("ui_derecha") - Input.get_action_strength("ui_izquierda")
	direccion.y = Input.get_action_strength("ui_abajo") - Input.get_action_strength("ui_arriba")

	if direccion != Vector2.ZERO:
		direccion = direccion.normalized() * velocidad
		_actualizar_animacion(direccion)
		direccion_mirada = direccion.normalized() 
	else:
		anim.stop()

	velocity = direccion
	move_and_slide()

	if Input.is_action_just_pressed("ui_accept"): 
		_lanzar_espada()

func _actualizar_animacion(direccion: Vector2) -> void:
	if abs(direccion.x) > abs(direccion.y):
		if direccion.x > 0:
			anim.play("personajederecha")
		else:
			anim.play("personajeizquierda")
	else:
		if direccion.y > 0:
			anim.play("personajeabajo")
		else:
			anim.play("personajearriba")

func agregar_item(item_name: String):
	inventario.append(item_name)
	print("Inventario:", inventario)
	
	# Si el item es el "Escudo", instanciar el enemigo
	if item_name == "Escudo":
		if get_parent() and get_parent().has_method("spawn_enemigo_volador"):
			get_parent().spawn_enemigo_volador()

func _lanzar_espada() -> void:
	if espada.lanzada:
		return

	var dir = direccion_mirada
	if dir != Vector2.ZERO:
		espada.show()
		espada.lanzar(espada.global_position, dir, self)

# 🆕 FUNCIÓN DE MUERTE INSTANTÁNEA
func morir():
	print("El jugador ha sido fulminado por el rayo láser.")
	# 1. Deshabilitar el movimiento y la colisión
	set_physics_process(false)
	set_process(false)
	set_collision_mask_value(1, false) # Opcional: Deshabilita la colisión con paredes

	# 2. Ocultar el jugador o mostrar animación de muerte
	anim.play("muerte") # Asume que tienes una animación "muerte"
	
	# 3. Mostrar pantalla de Game Over o reiniciar la escena después de un tiempo
	# Ejemplo: Reiniciar la escena después de 1 segundo
	await get_tree().create_timer(1.0).timeout
	get_tree().reload_current_scene()
