extends VBoxContainer

class_name ServerConsole

var labels: Array[Label] = []
## Simple function to only display the first 15 messages
func add_message(msg: String, color: Color):
	var label = Label.new()
	label.text = msg
	label.add_theme_font_size_override("font_size", 10)
	label.add_theme_color_override("font_color", color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size = Vector2(400, 20)
	labels.append(label)
	add_child(label)

	if labels.size() > 15:
		var removed_label = labels.pop_front()
		remove_child(removed_label)
		removed_label.queue_free()