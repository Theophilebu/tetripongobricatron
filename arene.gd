extends Node2D

@export var taillex: float = 800
@export var tailley: float = 600


var interieur: Polygon2D

var mur_gauche: StaticBody2D
var mur_droite: StaticBody2D
var mur_bas: StaticBody2D
var mur_haut: StaticBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interieur = get_node("Interieur")
	interieur.polygon = [
		Vector2(-taillex/2, -tailley/2),
		Vector2(taillex/2, -tailley/2),
		Vector2(taillex/2, tailley/2),
		Vector2(-taillex/2, tailley/2),
	]
	
	# facteur balec de largeur de la bande périphérique
	const f: float = 1.2
	
	
	var polygon_gauche = [
		Vector2(-taillex/2, f*tailley/2),
		Vector2(-taillex/2, -f*tailley/2),
		Vector2(-f*taillex/2, -f*tailley/2),
		Vector2(-f*taillex/2, f*tailley/2),
	]
	
	mur_gauche = get_node("MurGauche")
	mur_gauche.get_node("CollisionPolygon2D").polygon = polygon_gauche
	mur_gauche.get_node("Polygon2D").polygon = polygon_gauche


	var polygon_droite = [
		Vector2(taillex/2, f*tailley/2),
		Vector2(taillex/2, -f*tailley/2),
		Vector2(f*taillex/2, -f*tailley/2),
		Vector2(f*taillex/2, f*tailley/2),
	]
	mur_droite = get_node("MurDroite")
	mur_droite.get_node("CollisionPolygon2D").polygon = polygon_droite
	mur_droite.get_node("Polygon2D").polygon = polygon_droite

	var polygon_haut = [
		Vector2(-f*taillex/2, -tailley/2),
		Vector2(f*taillex/2, -tailley/2),
		Vector2(f*taillex/2, -f*tailley/2),
		Vector2(-f*taillex/2, -f*tailley/2),
	]
	mur_haut = get_node("MurHaut")
	mur_haut.get_node("CollisionPolygon2D").polygon = polygon_haut
	mur_haut.get_node("Polygon2D").polygon = polygon_haut

	var polygon_bas = [
		Vector2(-f*taillex/2, tailley/2),
		Vector2(f*taillex/2, tailley/2),
		Vector2(f*taillex/2, f*tailley/2),
		Vector2(-f*taillex/2, f*tailley/2),
	]
	mur_bas = get_node("MurBas")
	mur_bas.get_node("CollisionPolygon2D").polygon = polygon_bas
	mur_bas.get_node("Polygon2D").polygon = polygon_bas



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
