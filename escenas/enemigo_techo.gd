extends CharacterBody2D

# 🚫 Eliminada la variable @export var vida: int = 3
var jugador

# 🔫 Propiedades de Ataque
@export var tiempo_entre_disparos: float = 2.0
@export var escena_proyectil: PackedScene 

# ⏱️ Temporizador de Disparo
var puede_disparar: bool = true
var temporizador_disparo: float = 0.0
var esta_jugador_cerca: bool = false 

# 📢 Referencias a nodos hijos del EnemigoTecho
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var sonido_muerte: AudioStreamPlayer = $SonidoMuerte
@onready var area_disparo: Area2D = $AreaDisparo 

func _ready():
	# Referencia al jugador (se busca en el nodo padre, la Sala)
	if get_parent().has_node("Jugador"):
		jugador = get_parent().get_node("Jugador")
		
	# Conexión de las señales de detección del jugador
	area_disparo.body_entered.connect(_on_AreaDisparo_body_entered)
	area_disparo.body_exited.connect(_on_AreaDisparo_body_exited)
	
	add_to_group("Enemigo")

func _physics_process(delta):
	# Lógica del temporizador de disparo
	if not puede_disparar:
		temporizador_disparo += delta
		if temporizador_disparo >= tiempo_entre_disparos:
			# Dispara solo si el jugador AÚN está dentro del área
			if esta_jugador_cerca:
				disparar()
			else:
				# Reinicia el estado si el jugador salió durante el cooldown
				puede_disparar = true
				temporizador_disparo = 0.0
	
	# La torreta no se mueve
	velocity = Vector2.ZERO
	move_and_slide()

# 🚫 Eliminada la función recibir_dano(cantidad_dano: int) -> void

func morir():
	# 1. Reproduce el sonido de muerte y lo desacopla.
	if is_instance_valid(sonido_muerte):
		sonido_muerte.play()
		sonido_muerte.get_parent().remove_child(sonido_muerte)
		get_tree().root.add_child(sonido_muerte)
		sonido_muerte.finished.connect(sonido_muerte.queue_free, CONNECT_ONE_SHOT)
	
	# 2. Detiene la lógica y oculta.
	set_physics_process(false)
	anim.hide()
	
	# 3. Elimina el nodo del enemigo.
	queue_free()

# 🔫 Lógica de Disparo
func disparar():
	if puede_disparar and is_instance_valid(jugador) and escena_proyectil:
		
		# Marcamos que ya disparó y reiniciamos el temporizador
		puede_disparar = false
		temporizador_disparo = 0.0
		print("Enemigo Techo disparando...")
		
		instanciar_proyectil()

func instanciar_proyectil():
	if escena_proyectil: 
		var proyectil = escena_proyectil.instantiate()
		get_parent().add_child(proyectil) # Lo añade a la sala
		
		# Posiciona el proyectil justo debajo de la torreta
		proyectil.global_position = global_position + Vector2(0, 40)
		
		# Le dice al proyectil que se mueva directamente hacia abajo
		if proyectil.has_method("lanzar_en_direccion"):
			proyectil.lanzar_en_direccion(Vector2.DOWN)

# 🎯 Detección del Jugador
func _on_AreaDisparo_body_entered(body: Node2D) -> void:
	if body.is_in_group("Jugador"):
		esta_jugador_cerca = true 
		# Si el jugador entra, forzamos el primer disparo inmediato si es posible.
		if puede_disparar:
			disparar()

func _on_AreaDisparo_body_exited(body: Node2D) -> void:
	if body.is_in_group("Jugador"):
		esta_jugador_cerca = false 
		# Cuando el jugador sale, detenemos el ciclo de disparo inmediatamente si no está en cooldown
		if puede_disparar:
			temporizador_disparo = 0.0
