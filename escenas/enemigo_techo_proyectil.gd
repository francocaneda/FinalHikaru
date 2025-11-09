extends Area2D

@export var velocidad: float = 400.0
@export var dano: int = 1

var direccion: Vector2 = Vector2.ZERO

func _ready():
	# Conectamos la señal de colisión 
	#self.body_entered.connect(_on_body_entered)
	pass

func _physics_process(delta):
	# Mueve el proyectil
	global_position += direccion * velocidad * delta
	# 💡 PRUEBA: Verifica que la velocidad no sea cero
	if direccion != Vector2.ZERO:
		print("Proyectil moviéndose. Dirección: ", direccion)

# Función llamada por el EnemigoTecho para iniciar el movimiento
func lanzar_en_direccion(dir: Vector2):
	direccion = dir.normalized()
	print("Proyectil recibió dirección: ", direccion) # 💡 PRUEBA
	# No es necesario rotar para un disparo vertical.

func _on_body_entered(body: Node2D):
	# 1. IGNORAR ENEMIGOS: Evita que el proyectil colisione con su creador o aliados
	if body.is_in_group("Enemigo"):
		return

	# Si golpea al jugador
	if body.is_in_group("Jugador"):
		
		# ⚠️ Aquí deberías llamar a la función de daño del jugador (e.g., body.recibir_dano(dano))
		
		print("¡Jugador golpeado por Proyectil de Techo!")
		queue_free() # Destruye el proyectil
		return

	# Destruye el proyectil si golpea un cuerpo estático (paredes)
	# Asume que tus paredes están en el grupo "Pared"
	if body is StaticBody2D or body.is_in_group("Pared"):
		queue_free()
