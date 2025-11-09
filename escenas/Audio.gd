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
			musica.play()
	else:
		for musica in todas_las_musicas:
			musica.stop()

func iniciar_musica_de_escena(musica_actual: AudioStreamPlayer):
	if musica_activada:
		musica_actual.play()
