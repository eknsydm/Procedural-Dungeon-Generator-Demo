class_name CommandHistory
var cmdArray :Array[command] = []
var index:int = 0

func AddCommand(cmd:command):
	cmd.execute()
	cmdArray.push_back(cmd)
	
func Undo():
	if !cmdArray.is_empty():
		var c = cmdArray.pop_back()
		c.undo()
func Redo():
	pass
