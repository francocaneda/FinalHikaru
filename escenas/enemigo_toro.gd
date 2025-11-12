extends CharacterBody2D

@export var velocidad := 250.0
var jugador

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var sonido_muerte: AudioStreamPlayer = $SonidoMuerte

func _ready():
	# Referencia al jugador, verificando que exista.
	if get_parent().has_node("Jugador"):
		jugador = get_parent().get_node("Jugador")
	
	$Detector.body_entered.connect(_on_Detector_body_entered)
	
	pass

func _physics_process(delta):
	# Verifica que la referencia a jugador sea valida antes de usarla.
	if is_instance_valid(jugador):
		var direccion = (jugador.position - position).normalized()
		velocity = direccion * velocidad
		move_and_slide()
		_actualizar_animacion(direccion)
	else:
		velocity = Vector2.ZERO

func _actualizar_animacion(direccion: Vector2):
	if direccion == Vector2.ZERO:
		anim.stop()
		return

	if abs(direccion.x) > abs(direccion.y):
		if direccion.x > 0:
			anim.play("enemigoderecha")
		else:
			anim.play("enemigoizquierda")
	else:
		if direccion.y > 0:
			anim.play("enemigoabajo")
		else:
			anim.play("enemigoarriba")

func _on_Detector_body_entered(body: Node2D) -> void:
	if body.is_in_group("Jugador"):
		# 💥 CORRECCIÓN CLAVE: Llamamos a la función de muerte del JUGADOR
		if body.has_method("go_to_game_over"):
			body.go_to_game_over()
		
		print("¡Game Over activado por Enemigo Toro!")

# 🛑 IMPORTANTE: SE ELIMINÓ la función local 'go_to_game_over()' que era obsoleta.

func morir():
	# 🔹 1. Reproduce el sonido de muerte y lo desacopla para que persista.
	if is_instance_valid(sonido_muerte):
		# Desacopla y mueve el nodo de sonido a la raíz del juego para que no se elimine.
		sonido_muerte.get_parent().remove_child(sonido_muerte)
		get_tree().root.add_child(sonido_muerte)

		# Conecta la señal `finished` del sonido al método `queue_free` del *propio nodo de sonido*.
		sonido_muerte.finished.connect(sonido_muerte.queue_free, CONNECT_ONE_SHOT)
		
		# Inicia la reproducción.
		sonido_muerte.play()
	
	# 🔹 2. Detiene el enemigo visualmente.
	set_physics_process(false)
	anim.hide()
	
	# 🔹 3. Elimina el nodo del enemigo, lo cual es seguro porque el sonido ya no es un hijo.
	queue_free()
