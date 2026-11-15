@abstract
class_name AbstractLayer
extends Node2D

## slice along x=? or y=? axes. Since the operation splits a layer into 2, the function
## returns a new AbstractLayer
@abstract func slice_x(axis : int) -> AbstractLayer
@abstract func slice_y(axis : int) -> AbstractLayer

# TODO: there should be some registering of move here to support undo
func rotate_90_cw(count : int) -> void:
	rotation += count * PI / 2
func rotate_90_ccw(count : int) -> void:
	rotation -= count * PI / 2

# to preserve everything being on grid, I think only scales up should be supported 
# by integer amounts
func scale_up(factor : int) -> void:
	scale *= factor
