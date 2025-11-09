extends CharacterBody2D
class_name BossFinal 

# 🛡️ Propiedades del Boss
@export var velocidad: float = 200.0 # Velocidad del boss (un poco más rápido que el enemigo normal)
@export var vida_maxima: int = 100

var vida_actual: int
var jugador: CharacterBody2D = null

# 📢 Referencias a nodos hijos
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D 
@onready var sonido_muerte: AudioStreamPlayer = $SonidoMuerte # Asumiendo que tienes este nodo
# Agrega aquí cualquier otro nodo que use el boss (ej: RayCast2D, Area2D, etc.)

func _ready():
	vida_actual = vida_maxima
	add_to_group("Enemigo") # Para que la espada lo pueda golpear
	
	# Referencia al jugador (debe estar en el árbol principal)
	if get_parent() and get_parent().has_node("Jugador"):
		jugador = get_parent().get_node("Jugador")
	
	# Inicia con una animación de reposo o la pelea inmediatamente
	# anim.play("boss_idle")
	
	# 💥 Opcional: Iniciar la pelea si no se llama desde World.gd
	# iniciar_pelea() 

func _physics_process(delta):
	# Lógica de movimiento: por ahora, persigue al jugador (puedes cambiar esto por fases)
	if is_instance_valid(jugador) and vida_actual > 0:
		var direccion = (jugador.position - position).normalized()
		velocity = direccion * velocidad
		move_and_slide()
		
		_actualizar_animacion(direccion) # <-- LLAMADA CLAVE PARA ANIMACIONES
	else:
		velocity = Vector2.ZERO
		move_and_slide()
		anim.stop()

# 🎨 FUNCIÓN DE ANIMACIÓN (COPIA DEL PATRÓN DE TU ENEMIGO)
func _actualizar_animacion(direccion: Vector2):
	if direccion == Vector2.ZERO:
		anim.stop()
		return

	if abs(direccion.x) > abs(direccion.y):
		if direccion.x > 0:
			anim.play("bossderecha") # Asume que tienes esta animación
		else:
			anim.play("bossizquierda") # Asume que tienes esta animación
	else:
		if direccion.y > 0:
			anim.play("bossabajo") # Asume que tienes esta animación
		else:
			anim.play("bossarriba") # Asume que tienes esta animación

# ⚔️ Función llamada por la espada del jugador
func recibir_danio(cantidad: int = 1):
	vida_actual -= cantidad
	print("Boss recibió daño. Vida restante:", vida_actual)
	
	# Opcional: Añade un efecto visual o sonido de golpe
	# anim.play("boss_hit")
	
	if vida_actual <= 0:
		morir()

func morir():
	print("¡BOSS FINAL DERROTADO!")
	# Deshabilitar colisiones y movimiento
	set_physics_process(false)
	# anim.play("boss_muerte") # Animación de explosión/muerte
	
	# Lógica de sonido (similar a tu otro enemigo)
	if is_instance_valid(sonido_muerte):
		sonido_muerte.play()
		sonido_muerte.get_parent().remove_child(sonido_muerte)
		get_tree().root.add_child(sonido_muerte)
		sonido_muerte.finished.connect(sonido_muerte.queue_free, CONNECT_ONE_SHOT)
	
	# Esperar la animación de muerte (si la hubiera)
	await get_tree().create_timer(0.5).timeout
	
	# Eliminar el nodo
	queue_free()

# ⚔️ Función para iniciar el patrón de ataque (a desarrollar)
func iniciar_pelea():
	print("Pelea con el Boss Iniciada!")
	# Aquí irá la lógica de fases, temporizadores de ataque, etc.
	# Por ahora, solo se mueve hacia el jugador.
	pass

# NOTA: Debes conectar las funciones de daño y Game Over al boss
# si tu otro enemigo usa un Detector. Para el boss, es mejor que el JUGADOR lo mate.
