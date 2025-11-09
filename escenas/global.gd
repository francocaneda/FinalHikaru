extends Node

var puntuacion_actual := 0
var posicion_jugador: Vector2 = Vector2.ZERO

func guardar_juego():
	var datos = {
		"posicion_jugador": posicion_jugador,
		"puntuacion": puntuacion_actual
	}
	
	var file = FileAccess.open("user://guardado.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(datos))
		file.close()
		print("Juego guardado!")

func cargar_juego():
	if FileAccess.file_exists("user://guardado.json"):
		var file = FileAccess.open("user://guardado.json", FileAccess.READ)
		if file:
			var datos = JSON.parse_string(file.get_as_text()).result
			file.close()
			posicion_jugador = datos["posicion_jugador"]
			puntuacion_actual = datos["puntuacion"]
			print("Juego cargado:", datos)
