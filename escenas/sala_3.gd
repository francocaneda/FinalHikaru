extends Node2D

# 📢 Referencias a nodos de la escena
@onready var boss_node: BossFinal = $BossFinal 
@onready var vida_boss_label: Label = $CanvasLayer/VidaBossLabel # Asegúrate de que esta ruta sea correcta

func _ready():
	if is_instance_valid(boss_node):
		# 1. Conectamos la señal de vida del boss a nuestra función de actualización
		boss_node.vida_cambiada.connect(_actualizar_contador_vida)
		
		# 2. Inicializamos el contador al cargar la escena
		_actualizar_contador_vida(boss_node.vida_actual, boss_node.vida_maxima)
	else:
		print("ERROR: No se encontró el BossFinal con el nombre 'BossFinal'.")

func _actualizar_contador_vida(actual: int, maximo: int):
	# Función que se ejecuta cada vez que el boss recibe daño.
	if actual > 0:
		vida_boss_label.text = "BOSS HP: " + str(actual) + " / " + str(maximo)
	else:
		# El boss ha muerto
		vida_boss_label.text = "¡JEFE DERROTADO!"
