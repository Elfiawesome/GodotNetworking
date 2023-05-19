extends Node
class_name NetworkNode

var Port = 6503
var Address = "127.0.0.1"

enum{
	PLAYERCONNECT,
	PLAYERDISCONNECT,
	REQUESTFORPLAYERDATA,
	INITPLAYERDATA,
}
