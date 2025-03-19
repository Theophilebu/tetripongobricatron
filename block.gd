extends StaticBody2D

@export var pv_base: float

var grille: Area2D
var coos: Vector2i # coos dans la grille

var pv: float

func _ready() -> void:
	pv = pv_base


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func frapper(balle: CharacterBody2D):
	pv -= balle.puissance
	if pv<=0:
		grille.detruire_block(coos)
	
