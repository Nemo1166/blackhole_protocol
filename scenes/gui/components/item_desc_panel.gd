class_name ItemDescPanel extends Control


var desc_title: Label
var desc: Label
var texture_rect: TextureRect
var desc_2: Label

func set_tooltip(item: Item) -> void:
	desc_title = %DescTitle
	desc = %Desc
	desc_2 = %Desc2
	texture_rect = %TextureRect

	desc_title.text = item.display_name
	desc.text = item.desc_basic
	desc_2.text = item.desc_ext
	texture_rect.texture = item.icon
