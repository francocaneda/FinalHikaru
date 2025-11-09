extends Node2D

# Referencias a los nodos
@onready var jugador := $Jugador
@onready var pared_secreta: Node2D = $ParedSecreta
@onready var detector_sala_3: Area2D = $DetectorSala3 
@onready var musica_sala: AudioStreamPlayer = $MusicaSala

@export var escena_enemigo_volador: PackedScene
@export var escena_pared_secreta: PackedScene

func _ready():
	# El jugador comienza en una posicion adecuada para la entrada de Sala 2
	# Ajusta estos valores segun la geometria de tu Sala2.
	jugador.position = Vector2(-400, 0) 
	
	# Registra la musica de la sala con el sistema de audio global.
	# Asume que tienes un sistema de audio global 'Audio'
	
	
	# Inicia la musica de la sala si el sonido esta activado.
	

func _physics_process(delta):
	Global.posicion_jugador = jugador.position

	# Logica para abrir la puerta/pared cuando todos los enemigos mueren
	var enemigos_restantes = get_tree().get_nodes_in_group("Enemigo")
	if enemigos_restantes.size() == 0:
		abrir_puerta()

# --- Funciones de Enemigos y Puerta ---

func spawn_enemigo_volador():
	# Puedes llamar a esta funcion desde el script Jugador.gd si recoge un item
	call_deferred("instanciar_enemigo_de_forma_segura")

func instanciar_enemigo_de_forma_segura():
	if escena_enemigo_volador:
		# Instancia la pared secreta si aun no existe
		if not is_instance_valid(pared_secreta):
			if escena_pared_secreta:
				var nueva_pared = escena_pared_secreta.instantiate()
				# Asegurate de posicionar la pared correctamente en Sala 2
				# Si no necesitas una pared, puedes eliminar esta parte.
				add_child(nueva_pared) 
				pared_secreta = nueva_pared
			
		var enemigo_volador = escena_enemigo_volador.instantiate()
		add_child(enemigo_volador)
		
		# --- Cambia estas coordenadas para un punto de spawn en Sala 2 ---
		enemigo_volador.global_position = Vector2(300, 200)
		print("¡Enemigo volador instanciado en Sala 2!")

func abrir_puerta():
	if is_instance_valid(pared_secreta):
		pared_secreta.queue_free()

# --- Transición a la Siguiente Escena ---

func _on_detector_sala_3_body_entered(body: Node2D) -> void:
	if body.is_in_group("Jugador"):
		print("¡El jugador ha pasado a la siguiente sala!")
		call_deferred("cambiar_a_siguiente_escena")

func cambiar_a_siguiente_escena():
	# Mueve el nodo de música a la raíz antes de cambiar de escena.
	musica_sala.get_parent().remove_child(musica_sala)
	get_tree().root.add_child(musica_sala)

	# ⚠️ MODIFICAR: Reemplaza con tu siguiente escena (Sala3, Victory, etc.)
	# Por ahora, usamos la misma Sala2 para no tener error, pero ajustalo.
	get_tree().change_scene_to_file("res://escenas/Sala3.tscn")
