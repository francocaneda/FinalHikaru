extends Node2D

# 📢 Referencias a nodos de la escena
@onready var boss_node: BossFinal = $BossFinal 
@onready var vida_boss_label: Label = $CanvasLayer/VidaBossLabel 

# ⚔️ 1. PACKED SCENES DE ENEMIGOS (¡DEBES ASIGNAR ESTOS EN EL EDITOR!)
@export var escena_enemigo_volador: PackedScene
@export var escena_enemigo: PackedScene 
@export var escena_enemigo_toro: PackedScene

# ⏱️ VARIABLES DE CONTROL DE SPAWN
var spawn_timer: Timer = null 

func _ready():
	# Inicialización de la vida del Boss
	if is_instance_valid(boss_node):
		boss_node.vida_cambiada.connect(_actualizar_contador_vida)
		_actualizar_contador_vida(boss_node.vida_actual, boss_node.vida_maxima)
	else:
		print("ERROR: No se encontró el BossFinal con el nombre 'BossFinal'.")
		
	# 💥 2. INICIAMOS EL SPAWN DE MINIONS AL COMENZAR LA PELEA
	_iniciar_spawneo_minions()

func _actualizar_contador_vida(actual: int, maximo: int):
	# Función que se ejecuta cada vez que el boss recibe daño.
	if actual > 0:
		vida_boss_label.text = "BOSS HP: " + str(actual) + " / " + str(maximo)
	else:
		vida_boss_label.text = "¡JEFE DERROTADO!"
		
		# Detenemos el spawn si el boss muere
		if is_instance_valid(spawn_timer):
			spawn_timer.stop()


# ⚔️ --- LÓGICA DE SPAWN ---

func _iniciar_spawneo_minions():
	# Creamos un Timer en código para mayor flexibilidad en el tiempo de espera
	spawn_timer = Timer.new()
	add_child(spawn_timer)
	
	# Conectamos la señal de timeout a la función de spawn
	spawn_timer.timeout.connect(_spawnear_enemigo_aleatorio)
	
	# Establecemos el primer timeout aleatorio y lo iniciamos
	_establecer_siguiente_spawn_aleatorio()

func _establecer_siguiente_spawn_aleatorio():
	# Tiempo de spawn entre 3.0 y 4.0 segundos
	var tiempo_spawn = randf_range(2.0, 3.0) 
	
	spawn_timer.set_wait_time(tiempo_spawn)
	spawn_timer.set_one_shot(true) # Se reinicia en la función de spawn
	spawn_timer.start()

func _spawnear_enemigo_aleatorio():
	# Verificación de que el boss siga vivo
	if not is_instance_valid(boss_node) or boss_node.vida_actual <= 0:
		spawn_timer.stop()
		return

	# Seleccionar el enemigo aleatoriamente
	var enemigos = [escena_enemigo_volador, escena_enemigo, escena_enemigo_toro]
	var indice_aleatorio = randi() % enemigos.size()
	var escena_enemigo_a_spawnear = enemigos[indice_aleatorio]
	
	if not escena_enemigo_a_spawnear:
		print("ADVERTENCIA: Falta una escena de enemigo exportada.")
		_establecer_siguiente_spawn_aleatorio()
		return

	var nuevo_enemigo = escena_enemigo_a_spawnear.instantiate()
	
	# Determinar posición aleatoria
	var spawn_min_x = 200 
	var spawn_max_x = 800
	var spawn_min_y = 200
	var spawn_max_y = 200
	
	var pos_x = randf_range(spawn_min_x, spawn_max_x)
	var pos_y = randf_range(spawn_min_y, spawn_max_y)
	
	nuevo_enemigo.global_position = Vector2(pos_x, pos_y)
	
	# Añadir al árbol de la escena
	add_child(nuevo_enemigo)
	
	# Establecer el siguiente spawn
	_establecer_siguiente_spawn_aleatorio()
