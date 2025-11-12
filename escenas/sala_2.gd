extends Node2D

# Referencias a los nodos
@onready var jugador := $Jugador
@onready var pared_secreta: Node2D = $ParedSecreta
@onready var detector_sala_3: Area2D = $DetectorSala3
@onready var musica_sala: AudioStreamPlayer = $MusicaSala # Se mantiene para moverlo a la raíz

@export var escena_enemigo_volador: PackedScene
@export var escena_pared_secreta: PackedScene
@export var escena_enemigo_techo: PackedScene 

func _ready():
	# El jugador comienza en una posicion adecuada para la entrada de Sala 2
	jugador.position = Vector2(-400, 0)
	
	# INICIA EL COMBATE AL ENTRAR EN LA SALA
	spawn_enemigos_sala2()

func _physics_process(delta):
	Global.posicion_jugador = jugador.position

	# Logica para abrir la puerta/pared cuando todos los enemigos mueren
	var enemigos_restantes = get_tree().get_nodes_in_group("Enemigo")
	if enemigos_restantes.size() == 0:
		abrir_puerta()

# ⚔️ ENCUENTRO: Define dónde y qué enemigos aparecen
func spawn_enemigos_sala2():
	# Instancia 2 Enemigos Voladores en posiciones variadas
	instanciar_enemigo_volador(Vector2(900, 500))
	instanciar_enemigo_volador(Vector2(900, 500))

	# Instancia 2 Enemigo Techo
	instanciar_enemigo_techo(Vector2(800, 50))
	instanciar_enemigo_techo(Vector2(490, 50))
	print("Encuentro de Sala 2 iniciado.")

# --- Funciones de Instanciación ---

func instanciar_enemigo_volador(posicion_spawn: Vector2):
	call_deferred("instanciar_enemigo_volador_de_forma_segura", posicion_spawn)

func instanciar_enemigo_volador_de_forma_segura(posicion_spawn: Vector2):
	if escena_enemigo_volador:
		# Instancia la pared secreta si aun no existe (solo si es necesario)
		if not is_instance_valid(pared_secreta):
			if escena_pared_secreta:
				var nueva_pared = escena_pared_secreta.instantiate()
				add_child(nueva_pared)
				pared_secreta = nueva_pared
			
		var enemigo_volador = escena_enemigo_volador.instantiate()
		add_child(enemigo_volador)
		
		# Usa la posición de spawn
		enemigo_volador.global_position = posicion_spawn
		print("¡Enemigo volador instanciado en:", posicion_spawn, "!")

func instanciar_enemigo_techo(posicion_spawn: Vector2):
	call_deferred("instanciar_enemigo_techo_de_forma_segura", posicion_spawn)

func instanciar_enemigo_techo_de_forma_segura(posicion_spawn: Vector2):
	if escena_enemigo_techo:
		var enemigo_techo = escena_enemigo_techo.instantiate()
		add_child(enemigo_techo)
		enemigo_techo.global_position = posicion_spawn
		print("¡Enemigo Techo instanciado en:", posicion_spawn, "!")


func abrir_puerta():
	if is_instance_valid(pared_secreta):
		pared_secreta.queue_free()

# --- Transición a la Siguiente Escena ---

func _on_detector_sala_3_body_entered(body: Node2D) -> void:
	if body.is_in_group("Jugador"):
		print("¡El jugador ha pasado a la siguiente sala!")
		call_deferred("cambiar_a_siguiente_escena")

func cambiar_a_siguiente_escena():
	# Mueve el nodo de música a la raíz antes de cambiar de escena (para que sobreviva en Sala3)
	musica_sala.get_parent().remove_child(musica_sala)
	get_tree().root.add_child(musica_sala)

	get_tree().change_scene_to_file("res://escenas/Sala3.tscn")
