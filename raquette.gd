extends CharacterBody2D

var mainScene: Node2D
var arene: Node2D

@export var marge_x: float
@export var vitesse: float = 500
@export var taille_initiale: float = 50
@export var largeur: float = 10

# plus cette variable est grande, plus la vitesse de la
# raquette influencera le rebond de la balle
@export var influence_vitesse: float = 20

# si cette variable est grande, la balle rebondira de 
# manière plus verticale lorsqu'elle 
# frappera la raquette sur une de ses deux extrémités
@export var influence_cotes: float = 0.01

var taille: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	arene = get_parent()
	mainScene = arene.get_parent()
	
	var taillex_arene: float = arene.taillex
	position = Vector2(-taillex_arene/2+marge_x, 0)
	
	taille = taille_initiale	
	
	var polygon = [
		Vector2(largeur, -taille),
		Vector2(-largeur, -taille),
		Vector2(-largeur, taille),
		Vector2(largeur, taille),
	]
	get_node("CollisionPolygon2D").polygon = polygon
	get_node("Polygon2D").polygon = polygon
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _physics_process(delta):
	var direction_y = 0
	if Input.is_action_pressed("RaquetteDown"):
		direction_y += 1
	if Input.is_action_pressed("RaquetteUp"):
		direction_y -= 1
	
	velocity.y = direction_y*vitesse
	move_and_slide()

func frapper(balle: CharacterBody2D):
	pass

	
func _input(event):
	pass
