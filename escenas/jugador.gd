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

# 💥 FUNCIÓN CRÍTICA: LLAMADA POR EL LÁSER DEL ENEMIGO PARA TERMINAR EL JUEGO
func go_to_game_over():
	print("El jugador ha muerto. Iniciando Game Over.")
	
	# 1. Detiene la lógica y el movimiento
	set_physics_process(false)
	set_process(false)
	
	# 2. Lógica para Game Over: Pausa el árbol y cambia la escena.
	
	# NOTA: Asegúrate de que las llamadas a 'HUD' y 'MusicManager' son correctas
	# si son Autoloads o si las has comentado.
	
	# HUD.resetear_inventario()
	# inventario.clear()
	
	# if is_instance_valid(MusicManager):
	#     if MusicManager.is_playing():
	#         MusicManager.stop()
	
	get_tree().paused = true
	get_tree().change_scene_to_file("res://escenas/GameOver.tscn")

# Se mantiene 'morir' para ser compatible, simplemente llama a la función de Game Over.
func morir():
	go_to_game_over()
