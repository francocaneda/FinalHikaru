extends Area2D

# Exporta la textura del icono para que se pueda asignar en el Inspector.
@export var icono: Texture2D

func _ready():

	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.name == "Jugador":
		# Agregar el escudo al inventario temporal del jugador.
		body.inventario.append("Escudo")
		
		# Llamamos a la función del HUD para que muestre el ícono.
		HUD.mostrar_item(icono)
		# Generar un nuevo enemigo volador.
		get_parent().spawn_enemigo_volador()
		# El escudo desaparece.
		queue_free()
