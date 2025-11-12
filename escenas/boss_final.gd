extends CharacterBody2D
class_name BossFinal 

# 💥 NUEVA LÍNEA: Señal para notificar el cambio de vida
signal vida_cambiada(vida_actual: int, vida_maxima: int)

# 🛡️ Propiedades del Boss
@export var velocidad: float = 200.0
@export var vida_maxima: int = 4 # La vida máxima es 4
@export var tiempo_cooldown_danio: float = 0.5 # Tiempo en segundos para evitar que se pegue

var vida_actual: int
var jugador: CharacterBody2D = null

# 💥 NUEVO: Control para evitar el "pegado" y spam de daño
var puede_danar: bool = true 

# 📢 Referencias a nodos hijos
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D 
@onready var sonido_muerte: AudioStreamPlayer = $SonidoMuerte 
@onready var detector: Area2D = $Detector 

func _ready():
	vida_actual = vida_maxima
	add_to_group("Enemigo")
	
	var root = get_tree().get_root()
	if root.find_child("Jugador", true, false):
		jugador = root.find_child("Jugador", true, false)

	# 💥 Al inicio, emitimos la señal para que el contador se inicialice
	vida_cambiada.emit(vida_actual, vida_maxima) 

func _physics_process(delta):
	if is_instance_valid(jugador) and vida_actual > 0:
		var direccion = (jugador.position - position).normalized()
		velocity = direccion * velocidad
		move_and_slide()
		
		_actualizar_animacion(direccion)
	else:
		velocity = Vector2.ZERO
		move_and_slide()
		anim.stop()

# 🎨 FUNCIÓN DE ANIMACIÓN (sin cambios)
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

# 💥 FUNCIÓN DE COLISIÓN MORTAL (CORREGIDA)
func _on_detector_body_entered(body: Node2D) -> void:
	if body.is_in_group("Jugador"):
		
		# 💥 NUEVO: Solo causa daño si no está en cooldown
		if puede_danar:
			puede_danar = false
			
			if body.has_method("go_to_game_over"):
				body.go_to_game_over()
			
			# Lógica de separación (Knockback visual y Cooldown)
			_aplicar_separacion(body)

func _aplicar_separacion(body: Node2D):
	# 1. Empujar al Boss lejos del jugador (Knockback al Boss)
	var direccion_separacion = (position - body.position).normalized()
	velocity = direccion_separacion * velocidad # Usa la velocidad como fuerza de empuje
	
	# 2. Detener el movimiento normal por un instante
	set_physics_process(false)
	
	# 3. Iniciar el cooldown de daño
	var timer_cooldown = get_tree().create_timer(tiempo_cooldown_danio)
	timer_cooldown.timeout.connect(func():
		# Reanudar movimiento normal
		set_physics_process(true) 
		# Permitir que el Boss vuelva a dañar
		puede_danar = true 
	)

# ⚔️ Función de daño (sin cambios)
func recibir_danio(cantidad: int = 1):
	vida_actual -= cantidad
	print("Boss recibió daño. Vida restante:", vida_actual)
	
	# 💥 NUEVA LÍNEA: Emitimos la señal DESPUÉS de cambiar la vida
	vida_cambiada.emit(vida_actual, vida_maxima)
	
	if vida_actual <= 0:
		morir()

func morir():
	print("¡BOSS FINAL DERROTADO!")
	set_physics_process(false)
	
	if is_instance_valid(sonido_muerte):
		sonido_muerte.play()
		sonido_muerte.get_parent().remove_child(sonido_muerte)
		get_tree().get_root().add_child(sonido_muerte)
		sonido_muerte.finished.connect(sonido_muerte.queue_free, CONNECT_ONE_SHOT)
	
	await get_tree().create_timer(0.5).timeout
	
	queue_free()
	
func iniciar_pelea():
	pass
