extends DialogPanel


@onready var font_icon: Label = %FontIcon

func set_msg_icon(level: Global.MessageBoxLevel):
	match level:
		Global.MessageBoxLevel.Info:
			font_icon.text = "circle-info"
		Global.MessageBoxLevel.Warning:
			font_icon.text = "circle-exclamation"
		Global.MessageBoxLevel.Error:
			font_icon.text = "circle-xmark"
		Global.MessageBoxLevel.Check:
			font_icon.text = "circle-check"

func set_content(text: String):
	%RichTextLabel.text = text
