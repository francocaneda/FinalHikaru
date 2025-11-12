extends CharacterBody2D

@export var velocidad := 450.0
# Asume que el inventario se gestiona a través de Global.gd
# @export var inventario: Array = [] # 🛑 DEBE ESTAR COMENTADO O ELIMINADO

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var espada = $Espada    

var direccion_mirada: Vector2 = Vector2.RIGHT 

# ----------------- Funciones de Movimiento y Combate -----------------

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
	# Usa el inventario GLOBAL
	Global.inventario.append(item_name)
	print("Inventario:", Global.inventario)
	
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

# ----------------- Lógica de Muerte y Escudo -----------------

# FUNCIÓN PRINCIPAL DE MUERTE/GAME OVER
func go_to_game_over():
	
	# 🛑 1. VERIFICACIÓN DEL ESCUDO (Usa Global.inventario)
	if Global.inventario.has("Escudo"):
		_activar_escudo()
		return # EL ESCUDO HA SALVADO AL JUGADOR.
	
	# Si no tiene escudo, ejecuta la lógica de Game Over normal (diferida)
	print("El jugador ha muerto. Iniciando Game Over (deferido).")
	
	set_physics_process(false)
	set_process(false)
	
	call_deferred("_execute_game_over_actions")

func _activar_escudo():
	print("¡El escudo ha sido consumido y te ha salvado del golpe letal!")
	
	# 1. Quitar el Escudo del inventario (Usa Global.inventario)
	Global.inventario.erase("Escudo")
	
	# 2. Notificar al HUD para que remueva el ícono
	if is_instance_valid(HUD):
		HUD.remover_item() 
		
	# 💥 Teletransportar al jugador a una posición segura aleatoria
	teletransportar_a_posicion_segura()
	
# 💥 FUNCIÓN: Teletransporte a posición segura (con las coordenadas especificadas)
func teletransportar_a_posicion_segura():
	
	# Lista de las cuatro posiciones seguras deseadas
	var spawn_points = [
		Vector2(-250, 200), 
		Vector2(-350, 200), 
		Vector2(250, 200), 
		Vector2(350, 200)
	]
	
	# Elegir un punto aleatorio de la lista
	# randi() % array.size() asegura que se elija un índice válido.
	var nueva_posicion = spawn_points[randi() % spawn_points.size()]
	
	# Aplicar la nueva posición
	position = nueva_posicion 
	print("Jugador teletransportado por Escudo a:", nueva_posicion)


# ⚙️ FUNCIÓN QUE EJECUTA LAS ACCIONES PELIGROSAS (cambio de escena)
func _execute_game_over_actions():
	
	# Detención de la música
	if is_instance_valid(Audio):
		Audio.detener_musica() 
	
	get_tree().paused = true
	get_tree().change_scene_to_file("res://escenas/GameOver.tscn")

func morir():
	go_to_game_over()
