extends Area2D
# prout

enum TypePiece{L, L2, I, T, Carre, Ziguouiguoui1, Ziguouiguoui2}

var formes = {
	TypePiece.L: [Vector2i(-1, 0),
		Vector2i(0, 0),
		Vector2i(1, 0),
		Vector2i(1, 1)],
	
	TypePiece.L2: [Vector2i(-1, 1),
		Vector2i(-1, 0),
		Vector2i(0, 0),
		Vector2i(1, 0)],
	
	TypePiece.I: [Vector2i(-1, 0),
		Vector2i(0, 0),
		Vector2i(1, 0),
		Vector2i(2, 0)],
		
	TypePiece.T: [Vector2i(-1, 0),
		Vector2i(0, 0),
		Vector2i(1, 0),
		Vector2i(0, 1)],
		
	TypePiece.Carre: [Vector2i(0, 0),
		Vector2i(1, 0),
		Vector2i(0, 1),
		Vector2i(1, 1)],
		
	TypePiece.Ziguouiguoui1: [Vector2i(-1, 0),
		Vector2i(0, 0),
		Vector2i(0, 1),
		Vector2i(1, 1)],
	
	TypePiece.Ziguouiguoui2: [Vector2i(-1, 1),
		Vector2i(0, 1),
		Vector2i(0, 0),
		Vector2i(1, 0)],
	
}


@export var taillex: int = 10
@export var tailley: int = 12

@export var taille_bloc: float = 50

@export var block_scene: PackedScene
@export var piece_scene: PackedScene

var spawn_point: Vector2i

# shift =def la pièce se décale automatiquement vers la droite 
@export var frequence_shift: float = 1
var shift_timer: Timer

# le temps qu'il faut laisser appuyé bas pour tp vers le bas
@export var delai_tp: float = 1
var tp_timer: Timer


# Array[Array[StaticBody2D]]
var blocks: Array[Array]


@onready var block_polygon = [
		Vector2(-taille_bloc/2, -taille_bloc/2),
		Vector2(taille_bloc/2, -taille_bloc/2),
		Vector2(taille_bloc/2, taille_bloc/2),
		Vector2(-taille_bloc/2, taille_bloc/2),
	]

var grille_polygon: Array[Vector2]

var arene: Node2D
var type_piece_tombante: TypePiece
var forme_piece_tombante: Array[Vector2i]
var position_piece_tombante: Vector2i
var noeud_piece_tombante: Area2D

func dans_grille(v: Vector2i) -> bool:
	return 0<=v.x and\
	v.x < taillex and\
	0<=v.y and\
	v.y < tailley

func dans_grille_ou_gauche(v: Vector2i) -> bool:
	""" permet aussi à v d'être trop à gauche """
	return v.x < taillex and\
	0<=v.y and\
	v.y < tailley

func occupe(v: Vector2i) -> bool:
	if not dans_grille(v):
		return false
	return blocks[v.y][v.x] != null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	blocks = []# on e remplit de null
	for y in range(tailley):
		var ligne = []
		for x in range(taillex):
			ligne.append(null)
		blocks.append(ligne)
	
	arene = get_parent()
	
	# ecart à réduire pour que les pièces se
	# collent bien sur le mur
	var ecart_droit: float = (arene.taillex - taillex*taille_bloc)/2
	
	grille_polygon = [
		Vector2(ecart_droit-taillex*taille_bloc/2, -tailley*taille_bloc/2),
		Vector2(ecart_droit-taillex*taille_bloc/2, tailley*taille_bloc/2),
		Vector2(ecart_droit+taillex*taille_bloc/2, tailley*taille_bloc/2),
		Vector2(ecart_droit+taillex*taille_bloc/2, -tailley*taille_bloc/2),
	]
	
	get_node("CollisionPolygon2D").polygon = grille_polygon
	
	shift_timer = get_node("Timer")
	shift_timer.start()
	
	spawn_point = Vector2i(0, tailley/2-1)
	var type_piece: TypePiece = randi_range(0, 6)
	spawn_piece(type_piece, spawn_point)

func peut_spawn_piece(type_piece: TypePiece, grille_position: Vector2i) -> bool:
	# vérifie que la pièce a assez de place
	for coo_relative_block in formes[type_piece]:
		var block_coo = position_piece_tombante+coo_relative_block
		
		if not dans_grille(block_coo):
			return false
		
		if occupe(block_coo):
			return false
	return true

func spawn_piece(type_piece: TypePiece, grille_position: Vector2i):
	type_piece_tombante = type_piece
	forme_piece_tombante.assign(formes[type_piece])
	position_piece_tombante = grille_position
	
	noeud_piece_tombante = piece_scene.instantiate()
	add_child(noeud_piece_tombante)
	update_piece_node()


func peut_tourner_piece(sens_trigo: bool) -> bool:
	for coo_block in forme_piece_tombante:
		var nouv_coo_block = coo_block
		if sens_trigo:
			nouv_coo_block.x = coo_block.y
			nouv_coo_block.y = -coo_block.x
		else:
			nouv_coo_block.y = coo_block.x
			nouv_coo_block.x = -coo_block.y
		
		nouv_coo_block += position_piece_tombante
		
		if not dans_grille_ou_gauche(nouv_coo_block):
			print("problèùe dans: ", nouv_coo_block)
			return false
		if occupe(nouv_coo_block):
			print("problèùe: ", nouv_coo_block)
			return false
	return true
	
	
	update_piece_node()

func tourner_piece(sens_trigo: bool):
	
	for i in range(len(forme_piece_tombante)):
		var coo_block = forme_piece_tombante[i]
		if sens_trigo:
			var temp_x = coo_block.x
			coo_block.x = coo_block.y
			coo_block.y = -temp_x
		else:
			var temp_y = coo_block.y
			coo_block.y = coo_block.x
			coo_block.x = -temp_y
			
		forme_piece_tombante[i] = coo_block
	
	
	update_piece_node()


func update_piece_node():
	# update le node Piece avec la forme et la position
	noeud_piece_tombante.position = grille_polygon[0] +\
		 Vector2(
			(position_piece_tombante.x+0.5)*taille_bloc,
			(position_piece_tombante.y+0.5)*taille_bloc,
			)
			
	for i in range(len(forme_piece_tombante)):
		var nom_collision_polygon = "CollisionPolygon2D"+str(i+1)
		var nom_polygon = "Polygon2D"+str(i+1)

		noeud_piece_tombante.get_node(nom_collision_polygon).polygon = block_polygon
		noeud_piece_tombante.get_node(nom_polygon).polygon = block_polygon
		
		noeud_piece_tombante.get_node(nom_collision_polygon).position = forme_piece_tombante[i]*taille_bloc
		noeud_piece_tombante.get_node(nom_polygon).position = forme_piece_tombante[i]*taille_bloc


func peut_translationner_piece(translation: Vector2i) -> bool:
	# en pratique, translation = (1, 0), (0, -1), (0, 1)
	# sinon ça serait une téléportation
	
	# coos hypothétiques
	var nouv_position_piece_tombante = position_piece_tombante + translation
	for coo_relative_block in forme_piece_tombante:
		var coo_block = coo_relative_block + nouv_position_piece_tombante
		
		if coo_block.x>=taillex:
			return false
		
		if coo_block.y<0 or coo_block.y>=tailley:
			return false
		
		if coo_block.x>=0 and blocks[coo_block.y][coo_block.x] != null:
			return false
	
	return true

func translation_piece(translation: Vector2i):
	# en pratique, translation = (1, 0), (0, -1), (0, 1)
	# sinon ça serait une téléportation
	# on suppose que la translation est possible
	position_piece_tombante += translation
	noeud_piece_tombante.position += translation * taille_bloc


func peut_atterir_piece() -> bool:
	# vérification qu'il y a un truc à droite
	# et pas trop de bordel
	
	var truc_a_droite = false
	
	for coo_relative_block in forme_piece_tombante:
		var coo_block = coo_relative_block+position_piece_tombante
		
		# la pièce doit être dans la grille
		if coo_block.x<0 or coo_block.x>=taillex:
			return false
		
		if coo_block.y<0 or coo_block.y>=tailley:
			return false
		
		if coo_block.x == taillex - 1:
			truc_a_droite = true
		
		elif blocks[coo_block.y][coo_block.x + 1] != null:
			truc_a_droite = true
	
	return truc_a_droite

func atterir_piece():
	for coo_relative_block in forme_piece_tombante:
		var coo_block = coo_relative_block+position_piece_tombante
		creer_block(coo_block)
	
	var type_piece: TypePiece = randi_range(0, 6)
	noeud_piece_tombante.queue_free()
	spawn_piece(type_piece, spawn_point)


func creer_block(position_grille: Vector2i) -> bool:
	# renvoie True si le block s'est bien posé, False sinon
	if not dans_grille(position_grille):
		print("erreur: block ne peut pas être posé en dehors")
		return false
	
	if occupe(position_grille):
		print("block déjà présent")
		return false

	
	var vrai_position = grille_polygon[0] +\
	 Vector2((position_grille.x+0.5)*taille_bloc,
	(position_grille.y+0.5)*taille_bloc)
	
	var vrai_block_polygon = []
	for coin_block in block_polygon:
		vrai_block_polygon.append(vrai_position+coin_block)
	
	var nouv_block = block_scene.instantiate()
	
	nouv_block.grille = self
	nouv_block.coos = position_grille
	
	nouv_block.get_node("CollisionPolygon2D").polygon = vrai_block_polygon
	nouv_block.get_node("Polygon2D").polygon = vrai_block_polygon
	
	blocks[position_grille.y][position_grille.x] = nouv_block
	add_child(nouv_block)
	return true

func detruire_block(position_grille: Vector2i):
	var block = blocks[position_grille.y][position_grille.x]
	if block == null:
		return
	blocks[position_grille.y][position_grille.x] = null
	block.queue_free()
	

func _process(delta: float) -> void:
	pass


func _on_timer_timeout() -> void:
	pass
	# print("timeout")
	# translation_piece(Vector2i(1, 0))



func _input(event: InputEvent) -> void:
	
	if event.is_action_pressed("PieceDown") or\
	event.is_action_pressed("PieceUp") or\
	event.is_action_pressed("PieceLeft") or\
	event.is_action_pressed("PieceRight"):
		mouvement_input(event)
	
	if event.is_action_pressed("PieceTournerTrigo") or\
	event.is_action_pressed("PieceTournerAntiTrigo"):
		rotation_input(event)
	
	
		
		
		
func mouvement_input(event: InputEvent) -> void:
	var translation: Vector2i = Vector2i(0, 0)
	if event.is_action_pressed("PieceRight"):
		if peut_atterir_piece():
			atterir_piece()
			return
		translation = Vector2i(1, 0)
			
	elif event.is_action_pressed("PieceLeft"):
		translation = Vector2i(-1, 0)
	elif event.is_action_pressed("PieceUp"):
		translation = Vector2i(0, -1)
	elif event.is_action_pressed("PieceDown"):
		translation = Vector2i(0, 1)
	
	
	if peut_translationner_piece(translation):
		translation_piece(translation)
		return

func rotation_input(event: InputEvent) -> void:
	var sens_trigo: bool
	if event.is_action_pressed("PieceTournerTrigo"):
		sens_trigo = true

	elif event.is_action_pressed("PieceTournerAntiTrigo"):
		sens_trigo = false
	
	if peut_tourner_piece(sens_trigo):
		tourner_piece(sens_trigo)
