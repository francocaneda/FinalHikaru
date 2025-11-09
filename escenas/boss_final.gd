extends CharacterBody2D
class_name BossFinal 

# 💥 NUEVA LÍNEA: Señal para notificar el cambio de vida
signal vida_cambiada(vida_actual: int, vida_maxima: int)

# 🛡️ Propiedades del Boss
@export var velocidad: float = 200.0
@export var vida_maxima: int = 4 # La vida máxima es 4

var vida_actual: int
var jugador: CharacterBody2D = null

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

# 💥 FUNCIÓN DE COLISIÓN MORTAL (sin cambios)
func _on_detector_body_entered(body: Node2D) -> void:
	if body.is_in_group("Jugador"):
		if body.has_method("go_to_game_over"):
			body.go_to_game_over()

# ⚔️ Función de daño
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
