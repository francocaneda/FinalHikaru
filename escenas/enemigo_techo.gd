extends CharacterBody2D

# 🛡️ Propiedades del Enemigo
@export var tiempo_entre_disparos: float = 3.0
@export var tiempo_de_carga: float = 1.0     

var puede_disparar: bool = true
var jugador

# 📢 Referencias a nodos hijos
@onready var anim: AnimatedSprite2D = $anim 
@onready var sonido_muerte: AudioStreamPlayer = $SonidoMuerte
@onready var rayo_laser: RayCast2D = $RayoLaser
@onready var linea_laser: Line2D = $LaserVisual

func _ready():
	# Referencia al jugador
	if get_parent().has_node("Jugador"):
		jugador = get_parent().get_node("Jugador")
	
	add_to_group("Enemigo")
	
	# 💥 ARREGLO FINAL PARA GODOT 4: Asegura que el Line2D tenga dos puntos.
	# Si falta el segundo punto, lo añadimos para evitar el error de índice.
	if linea_laser.points.size() < 2:
		var temp_points = linea_laser.points # Copia temporal
		if temp_points.is_empty():
			temp_points.append(Vector2.ZERO) # Asegura el punto 0
		temp_points.append(Vector2.ZERO)    # Añade el punto 1
		linea_laser.points = temp_points    # Reasigna el array corregido
	
	# Inicia con la animación de reposo
	anim.play("idle")
	
	# Inicia el ataque inmediatamente
	disparar()

func _physics_process(delta):
	velocity = Vector2.ZERO
	move_and_slide()

# 🔫 Lógica de Ataque
func disparar():
	if puede_disparar and is_instance_valid(jugador):
		
		puede_disparar = false
		
		
		anim.play("idle")
		
		var timer = get_tree().create_timer(tiempo_de_carga)
		timer.timeout.connect(lanzar_laser)

func lanzar_laser():
	if not is_instance_valid(jugador):
		reset_cooldown()
		return

	
	anim.play("disparo") 
	
	rayo_laser.force_raycast_update()
	
	var punto_final = rayo_laser.target_position
	
	if rayo_laser.is_colliding():
		punto_final = to_local(rayo_laser.get_collision_point())
		
		var cuerpo_golpeado = rayo_laser.get_collider()
		
		if cuerpo_golpeado.is_in_group("Jugador"):
			if cuerpo_golpeado.has_method("morir"):
				cuerpo_golpeado.morir()
			print("Láser golpeó al JUGADOR y lo mató!")
			
	# DIBUJAR EL LÁSER (Sintaxis Godot 4)
	linea_laser.show()
	
	# Crea una copia temporal del array para modificar el punto 1 de forma segura
	var temp_points = linea_laser.points
	temp_points[1] = punto_final # Modificación segura en Godot 4
	linea_laser.points = temp_points # Reasignación
	
	# Ocultar el láser (Efecto Flash) e iniciar cooldown
	var flash_timer = get_tree().create_timer(0.1) 
	flash_timer.timeout.connect(func():
		linea_laser.hide()
		reset_cooldown()
	)

func reset_cooldown():
	var cooldown_restante = tiempo_entre_disparos - tiempo_de_carga
	
	if cooldown_restante < 0.1:
		cooldown_restante = 0.1

	var timer = get_tree().create_timer(cooldown_restante)
	timer.timeout.connect(func():
		puede_disparar = true
		anim.play("idle")
		disparar() 
	)

func morir():
	if is_instance_valid(sonido_muerte):
		sonido_muerte.play()
		sonido_muerte.get_parent().remove_child(sonido_muerte)
		get_tree().root.add_child(sonido_muerte)
		sonido_muerte.finished.connect(sonido_muerte.queue_free)
	
	set_physics_process(false)
	anim.hide()
	queue_free()
