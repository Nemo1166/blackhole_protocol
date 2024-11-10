class_name Building extends Node

enum BuildingType {
	RESIDENTIAL,
	COMMERCIAL,
	INDUSTRIAL,
	DECORATION,
	OTHER
}

enum BuildingSize {
	SMALL=1,
	MEDIUM=2,
	LARGE=4,
	EXTRA_LARGE=16
}


var title: String = ""
var description: String = ""
var icon: Texture = null
var type: String = ""
var price: int = 0
var materials: Dictionary = {}