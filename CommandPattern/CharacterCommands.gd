class_name CharacterCommands

class move_command extends command:  
	var newVec:Vector2
	var oldVec:Vector2
	var subject:Node2D 
	func _init(_subject:Node2D,_newVector:Vector2):
		newVec = _newVector
		subject = _subject
	func execute():
		oldVec = subject.position
		subject.position = newVec
	func undo():
		subject.position = oldVec
	func merge_with(com:command):pass

class attack_command extends command:
	pass
