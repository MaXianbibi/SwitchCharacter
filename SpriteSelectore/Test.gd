extends Node2D

@export var Character_Scene : PackedScene = null


@export var loadScript : LoadingSprite = null


var offset : int = 0

var index : int = 0
@onready var max_index  : int = $LoadSprite.sprite_data.keys().size()
@onready var animation_name : Array = $LoadSprite.sprite_data.keys()


func _ready():
	pass



func _on_generate_npc_button_up():
	
	var newCharacter : Character = loadScript.generate_new_character()
	
	newCharacter.position = Vector2(25 + offset, 500)
	offset += 75
	newCharacter.scale = Vector2(5, 5)
	
	
	add_child(newCharacter)
	loadScript.load_sprite()
	loadScript.randomCharacter(newCharacter)


func play_group_animation():
	get_tree().call_group("entity_sprite", "play_animation", animation_name[index])


func _on_timer_timeout():
	index += 1
	if index >= max_index: index = 0	
	play_group_animation()
