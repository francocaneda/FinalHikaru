extends CharacterBody2D

# 🛡️ Propiedades del Enemigo
@export var tiempo_entre_disparos: float = 3.0 # Tiempo total (incluye carga)
@export var tiempo_de_carga: float = 1.0     # Cuánto dura la animación de carga

var puede_disparar: bool = true
# 🚫 Eliminada la variable 'esta_jugador_cerca'
var jugador

# 📢 Referencias a nodos hijos
@onready var anim: AnimatedSprite2D = $anim 
@onready var sonido_muerte: AudioStreamPlayer = $SonidoMuerte
# 🚫 Eliminada la referencia a 'area_disparo'
@onready var rayo_laser: RayCast2D = $RayoLaser 

func _ready():
	# Referencia al jugador
	if get_parent().has_node("Jugador"):
		jugador = get_parent().get_node("Jugador")
	
	# 🚫 Eliminadas las conexiones de body_entered/exited
	# 🚫 Eliminada la referencia a area_disparo
	add_to_group("Enemigo")
	
	# Inicia la animación de reposo
	anim.play("cargar")
	
	# 🆕 INICIA EL ATAQUE INMEDIATAMENTE al estar listo
	disparar()

func _physics_process(delta):
	# La torreta no se mueve
	velocity = Vector2.ZERO
	move_and_slide()

# 🔫 Lógica de Ataque
func disparar():
	if puede_disparar and is_instance_valid(jugador):
		
		puede_disparar = false
		
		
		# 🎬 INICIO DE CARGA
		anim.play("cargar")
		
		# 1. Espera el tiempo de carga
		var timer = get_tree().create_timer(tiempo_de_carga)
		timer.timeout.connect(lanzar_laser)

func lanzar_laser():
	# 🚫 Eliminada la verificación 'if not esta_jugador_cerca:'
	if not is_instance_valid(jugador):
		# Si el jugador fue eliminado o salió de la escena, detenemos
		reset_cooldown()
		return


	
	# 🎬 DISPARO
	anim.play("disparo") 
	
	# 2. Activar RayCast para detectar colisión
	rayo_laser.force_raycast_update()
	
	if rayo_laser.is_colliding():
		var cuerpo_golpeado = rayo_laser.get_collider()
		
		if cuerpo_golpeado.is_in_group("Jugador"):
			if cuerpo_golpeado.has_method("morir"):
				cuerpo_golpeado.morir()
			print("Láser golpeó al JUGADOR y lo mató!")
	
	# 3. Iniciar Cooldown restante
	var anim_time = 0.2 
	var anim_timer = get_tree().create_timer(anim_time)
	anim_timer.timeout.connect(reset_cooldown)

func reset_cooldown():
	# Calcula el tiempo restante (Cooldown Total - Tiempo de Carga)
	var cooldown_restante = tiempo_entre_disparos - tiempo_de_carga
	
	if cooldown_restante < 0.1:
		cooldown_restante = 0.1

	var timer = get_tree().create_timer(cooldown_restante)
	timer.timeout.connect(func():
		puede_disparar = true
		# 🎬 REPOSO
		anim.play("idle")
		
		# 🆕 Después del cooldown, DISPARA DE NUEVO
		disparar() 
	)

# 🚫 Eliminadas las funciones _on_AreaDisparo_body_entered y _on_AreaDisparo_body_exited
		
func morir():
	# ... (El código de morir se mantiene)
	if is_instance_valid(sonido_muerte):
		sonido_muerte.play()
		sonido_muerte.get_parent().remove_child(sonido_muerte)
		get_tree().root.add_child(sonido_muerte)
		sonido_muerte.finished.connect(sonido_muerte.queue_free, CONNECT_ONE_SHOT)
	
	set_physics_process(false)
	anim.hide()
	queue_free()
