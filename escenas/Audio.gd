# Audio.gd
extends Node

var musica_activada = true
var todas_las_musicas = []

func registrar_musica(reproductor: AudioStreamPlayer):
	if !todas_las_musicas.has(reproductor):
		todas_las_musicas.append(reproductor)

func toggle_musica():
	musica_activada = !musica_activada
	
	if musica_activada:
		for musica in todas_las_musicas:
			# Solo reproducir si está detenido
			if !musica.playing:
				musica.play()
	else:
		for musica in todas_las_musicas:
			musica.stop()

func iniciar_musica_de_escena(musica_actual: AudioStreamPlayer):
	if musica_activada:
		musica_actual.play()

# 💥 FUNCIÓN CORREGIDA: Detiene todas las músicas registradas de forma segura y limpia el array.
func detener_musica():
	# Iteramos hacia atrás para poder eliminar elementos sin problemas
	for i in range(todas_las_musicas.size() - 1, -1, -1):
		var musica = todas_las_musicas[i]
		
		# 1. Verificamos que el nodo AÚN exista y sea válido
		if is_instance_valid(musica):
			musica.stop()
			# Opcional: si quieres que el nodo de música que sobrevive en la raíz se elimine:
			# musica.queue_free()
			
		# 2. Eliminamos la referencia del array (esto es CRÍTICO para evitar el crash)
		todas_las_musicas.remove_at(i)
