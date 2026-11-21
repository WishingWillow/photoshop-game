## A trivial container class meant to mimic a Line2D, but forcing the typing of the vertex points
## as integer vectors. One IntegerLine composes the data to create a PathSegment.
class_name IntegerLine
extends Resource

@export var points : Array[Vector2i]
