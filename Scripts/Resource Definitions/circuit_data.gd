## A simple class that contains the data for all segments of a particularly colored circuit on a 
## layer. Rather than just embed this information in a layer, CircuitData has been extracted so 
## that the LayerData resource's nested data can fully visible in the editor.
class_name CircuitData 
extends Resource

enum CircuitColor { RED, BLUE }

@export var color : CircuitColor
@export var segments : Array[IntegerLine]
