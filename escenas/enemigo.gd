extends CharacterBody2D

@export var velocidad := 150.0
var jugador

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var sonido_muerte: AudioStreamPlayer = $SonidoMuerte

func _ready():
	# Referencia al jugador (con validacion)
	if get_parent().has_node("Jugador"):
		jugador = get_parent().get_node("Jugador")
		
	# Conecta la senal de colision del detector
	$Detector.body_entered.connect(_on_Detector_body_entered)
	
	pass 

func _physics_process(delta):
	# Evita errores si el jugador es eliminado de la escena
	if is_instance_valid(jugador):
		var direccion = (jugador.position - position).normalized()
		velocity = direccion * velocidad
		move_and_slide()
		_actualizar_animacion(direccion)
	else:
		velocity = Vector2.ZERO # Detiene al enemigo si no hay jugador

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
		
		print("¡Game Over activado por Enemigo!")

# 🛑 IMPORTANTE: SE ELIMINÓ la función local 'go_to_game_over()' que era obsoleta.

func morir():
	# 1. Reproduce el sonido de muerte inmediatamente.
	sonido_muerte.play()
	
	# 2. Conexión segura para eliminar el nodo de sonido después de reproducirse.
	if is_instance_valid(sonido_muerte):
		
		# Desacopla el sonido antes de que el enemigo muera:
		sonido_muerte.get_parent().remove_child(sonido_muerte)
		get_tree().root.add_child(sonido_muerte)

		# 🔹 Sintaxis de Godot 4 usando Callable
		sonido_muerte.finished.connect(sonido_muerte.queue_free, CONNECT_ONE_SHOT)
	
	# 3. Oculta el enemigo y detiene su movimiento.
	set_physics_process(false)
	anim.hide()
	
	# 4. Elimina el nodo del enemigo (ahora es seguro, el sonido ya no es su hijo).
	queue_free()
