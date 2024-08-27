extends ColorRect

class_name Cell

var status:Resource

func _ready():
	var param = Parameters.new()
	color = param.empty_cell_color

## A way to get the cell state
func update_status(new_status: Resource):
	status = new_status