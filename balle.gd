extends CharacterBody2D

var mainScene: Node2D
var arene: Node2D

@export var vitesse_initiale: Vector2 = Vector2(-300, 0)
@export var vitesse_max: float = 800 # a faire
@export var acceleration: float = 10 # a faire

# dégâts faits aux blocs(à faire)
@export var puissance_initiale: float = 1
@export var puissance_max: float = 5
@export var derivee_puissance: float = 0.05
var puissance: float

# augmentation des stats de la balle lors d'un choc avec un block
@export var puissance_augm_choc_block = 0.1
@export var vitesse_augm_choc_block = 10


@export var pv_max: float = 10
var pv: float

@export var degats_mur_gauche: float = 2
@export var degats_mur_droite: float = 2

var rayon: float

# pi/2 -> la balle peut avoir une direction verticale
# 0 -> le balle ne peut avoir qu'une trajectoire horizontale

@export_range(0, PI/2) var angle_max: float = 1.2
var cos_angle_max = cos(angle_max)
var sin_angle_max = sin(angle_max)




var max_collisions = 5 # (par frame) (balec)

func _ready() -> void:
	arene = get_parent()
	mainScene = arene.get_parent()
	
	rayon = get_node("CollisionShape2D").shape.radius
	
	velocity = vitesse_initiale
	
	puissance = puissance_initiale
	
	pv = pv_max



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	
	var collision_count = 0
	var collision = move_and_collide(velocity * delta)
	
	# var doit_frapper: Array[Node2D] = []
	
	while (collision and collision_count < max_collisions):
		var collider: Object = collision.get_collider()
		
		var normal: Vector2 = collision.get_normal()

		
		if collider.is_in_group("bloc"):
			frapper_block(collider)
			
		elif collider.is_in_group("raquette"):
			normal = Vector2(1, 0)
			collider.frapper(self)
			normal += collider.velocity * collider.influence_vitesse * 10e-6
			normal += 0 * (collision.get_position() \
			- collider.get_global_transform().get_origin()) * collider.influence_cotes
			normal = normal.normalized()
			
			# rend la trajectoire plus horizontale
			if normal.x<cos_angle_max:
				if normal.y<0:
					normal.y = -sin_angle_max
				else:
					normal.y = sin_angle_max
				normal.x = cos_angle_max
			
			position.x = collider.position.x + rayon + collider.largeur
			collision_count = max_collisions
			# arrete la boucle après le bounce
		
		elif collider.is_in_group("mur"):
			if collider == arene.mur_gauche:
				frapper_mur_gauche()
			elif collider == arene.mur_droite:
				frapper_mur_droite()
		
		var remainder = collision.get_remainder()
		velocity = velocity.bounce(normal)
		remainder = remainder.bounce(normal)
		
		collision_count += 1
		collision = move_and_collide(remainder)

func frapper_block(block: StaticBody2D):
	block.frapper(self)
	puissance += puissance_augm_choc_block
	velocity += velocity.normalized()*vitesse_augm_choc_block

func frapper_mur_gauche():
	pv -= degats_mur_gauche
	if pv <= 0:
		mort()

func frapper_mur_droite():
	pv -= degats_mur_droite
	if pv <= 0:
		mort()


func mort():
	pass
	# print("mort")
