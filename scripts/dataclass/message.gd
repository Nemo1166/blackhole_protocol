class_name Message extends Resource

enum MessageType {
	INFO,
	WARNING,
	ERROR,
	OTHER
}

var title: String = ""
var content: String = ""
var icon: Texture = null
var type: MessageType = MessageType.OTHER
var duration: float = 0.0

func _init(_title, _content, _icon, _type, _duration) -> void:
	title = _title
	content = _content
	icon = _icon
	type = _type
	duration = _duration
