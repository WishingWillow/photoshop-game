class_name CircuitData 
extends Resource
# the purpose of these simple nested resources is so that it is simple to create layers in the 
# editor, where every sub-element of the layer can be exported

enum CircuitColor { RED, BLUE }

@export var color : CircuitColor
@export var segments : Array[IntegerLine]
