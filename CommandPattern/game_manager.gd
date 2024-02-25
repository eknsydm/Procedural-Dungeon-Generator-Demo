extends Node2D
class_name GameManager
var commandBuffer = CommandHistory.new()

func _on_character_send_command(cmd):
	commandBuffer.AddCommand(cmd)
	
func _on_menu_button_send_command(cmd):
	commandBuffer.AddCommand(cmd)

func _on_button_pressed():
	commandBuffer.Undo()

func _on_button_2_pressed():
	commandBuffer.Redo()


