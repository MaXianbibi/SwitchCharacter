extends Node2D
class_name Character


@onready var body : AnimatedSprite2D
@onready var eyes : AnimatedSprite2D
@onready var hair : AnimatedSprite2D
@onready var outfits : AnimatedSprite2D

func _init():
	add_to_group("entity_sprite")
	if not body:
		body = AnimatedSprite2D.new()
		add_child(body)
	if not eyes:
		eyes = AnimatedSprite2D.new()
		add_child(eyes)
	if not hair:
		hair = AnimatedSprite2D.new()
		add_child(hair)
	if not outfits:
		outfits = AnimatedSprite2D.new()
		add_child(outfits)
		
		
func play_animation(animation_name : String):
	body.play(animation_name)
	eyes.play(animation_name)
	hair.play(animation_name)
	outfits.play(animation_name)
	
	



