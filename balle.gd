extends CharacterBody2D

var mainScene: Node2D
var arene: Node2D

@export var vitesse_initiale: Vector2 = Vector2(-300, 0)
@export var vitesse_max: float = 800 # a faire
@export var acceleration: float = 10 # a faire

# dégâts faits aux blocs
@export var puissance: float = 1

var rayon: float

var max_collisions = 5 # (par frame)



func _ready() -> void:
	arene = get_parent()
	mainScene = arene.get_parent()
	
	rayon = get_node("CollisionShape2D").shape.radius
	
	velocity = vitesse_initiale


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	var collision_count = 0
	var collision = move_and_collide(velocity * delta)
	
	while (collision and collision_count < max_collisions):
		var collider: Object = collision.get_collider()
		var normal: Vector2 = collision.get_normal()
		
		if collider.is_in_group("bloc"):
			frapper_block(collider)
		
		
		var remainder = collision.get_remainder()
		velocity = velocity.bounce(normal)
		remainder = remainder.bounce(normal)
		
		collision_count += 1
		collision = move_and_collide(remainder)

func frapper_block(block: StaticBody2D):
	block.frapper(self)

func mort():
	print("mort")
