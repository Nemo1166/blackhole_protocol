class_name CurrencyUI extends Control

@onready var currency_value: Label = %CurrencyValue
@onready var texture_rect: TextureRect = $CurrencyItem/MarginContainer/TextureRect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func set_value(value: int):
	currency_value.text = str(value)
	#tooltip_text = "营地保有资产"
