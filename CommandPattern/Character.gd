extends Node2D
class_name Character
signal SendCommand(cmd:command)

var characterCommands = preload("res://CommandPattern/CharacterCommands.gd").new()

func _process(delta):
	var newVec:Vector2
	if Input.is_action_just_pressed("ui_right"):
		newVec = Vector2(position.x+100,position.y)
		var newCmd = characterCommands.move_command.new(self,newVec)
		emit_signal("SendCommand",newCmd)
	elif Input.is_action_just_pressed("ui_left"):
		newVec = Vector2(position.x-100,position.y)
		var newCmd = characterCommands.move_command.new(self,newVec)
		emit_signal("SendCommand",newCmd)
	elif Input.is_action_just_pressed("ui_up"):
		newVec = Vector2(position.x,position.y-100)
		var newCmd = characterCommands.move_command.new(self,newVec)
		emit_signal("SendCommand",newCmd)
	elif Input.is_action_just_pressed("ui_down"):
		newVec = Vector2(position.x,position.y+100)
		var newCmd = characterCommands.move_command.new(self,newVec)
		emit_signal("SendCommand",newCmd)


