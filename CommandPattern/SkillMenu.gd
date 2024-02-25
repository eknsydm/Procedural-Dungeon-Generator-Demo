extends MenuButton
enum menu{
	ATTACK,
	HEAL
}
signal SendCommand(cmd:command)

func _ready():
	var popup=get_popup()
	popup.id_pressed.connect(file_menu)

func file_menu(id):
	var newCmd
	match id:
		menu.ATTACK:
			newCmd = testCommand.new("Attack ")
		menu.HEAL:
			newCmd = testCommand.new("Heal ")
	emit_signal("SendCommand",newCmd)

class testCommand extends command:
	var message:String
	func _init(a:String):
		message = a
	func execute():print(message)
	func undo():print("undo ", message)
	func merge_with(com:command):pass

