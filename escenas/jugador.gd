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

# FUNCIÓN PRINCIPAL DE MUERTE/GAME OVER
func go_to_game_over():
	print("El jugador ha muerto. Iniciando Game Over (deferido).")
	
	set_physics_process(false)
	set_process(false)
	
	call_deferred("_execute_game_over_actions")
	
# FUNCIÓN QUE EJECUTA LAS ACCIONES PELIGROSAS (cambio de escena, destrucción)
func _execute_game_over_actions():
	
	# 🛑 CORRECCIÓN: Confiamos en que Audio.detener_musica() hace la limpieza segura.
	if is_instance_valid(Audio):
		Audio.detener_musica() 
	
	# Resto de la lógica de Game Over
	# NOTA: Comenta o ajusta las siguientes líneas si HUD y MusicManager no existen:
	# HUD.resetear_inventario()
	# inventario.clear()
	
	get_tree().paused = true
	get_tree().change_scene_to_file("res://escenas/GameOver.tscn")

# Se mantiene 'morir' para ser compatible
func morir():
	go_to_game_over()
