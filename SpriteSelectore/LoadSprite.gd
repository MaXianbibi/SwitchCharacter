extends Node
class_name LoadingSprite


const FRAME_WIDTH = 16
const FRAME_HEIGHT = 32

var sprite_data : Dictionary = {
	"turn_arround_idle" : {
		"x" : 0,
		"y" : 0,
		"n" : 4
	},
	"idle_right" : {
		"x" : FRAME_WIDTH * 0,
		"y" : FRAME_HEIGHT * 1,
		"n" : 6,
	},
	"idle_up" : {
		"x" : FRAME_WIDTH * 6,
		"y" : FRAME_HEIGHT * 1,
		"n" : 6
	},
	"idle_left" : {
		"x" : FRAME_WIDTH * 12,
		"y" : FRAME_HEIGHT * 1,
		"n" : 6
	},
	"idle_down" : {
		"x" : FRAME_WIDTH * 18,
		"y" : FRAME_HEIGHT * 1,
		"n" : 6
	},
	"run_right" : {
		"x" : FRAME_WIDTH * 0,
		"y" : FRAME_HEIGHT * 2,
		"n" : 6
	},
	"run_up" : {
		"x" : FRAME_WIDTH * 6,
		"y" : FRAME_HEIGHT * 2,
		"n" : 6
	},
	"run_left" : {
		"x" : FRAME_WIDTH * 12,
		"y" : FRAME_HEIGHT * 2,
		"n" : 6
	},
	"run_down" : {
		"x" : FRAME_WIDTH * 18,
		"y" : FRAME_HEIGHT * 2,
		"n" : 6
	}
}

enum error {
	OK,
	ERR
}

@export var character : Character = null
@export var sprite_folder : String = "./"


var is_loaded : bool = false


var is_init : bool = false

func create_sprite_entry(path: String, array: Array, index : int, NodeAnimated : AnimatedSprite2D) -> Dictionary:
	return {
		"path": path,
		"Array": array,
		"Index" : index,
		"Node" : NodeAnimated
	}

var sprites_dict : Dictionary = {}
@export var sprite_name_label : Label = null

var selected_key : String = "body"

func delete_sprite_sheet(sprite_sheet: AnimatedSprite2D):
	if sprite_sheet.sprite_frames:
		sprite_sheet.sprite_frames.clear_all()
		sprite_sheet.sprite_frames = null





func add_sprite_sheet(sprite_sheet : AnimatedSprite2D, texture : Texture2D):
	delete_sprite_sheet(sprite_sheet)
	var frames : SpriteFrames = SpriteFrames.new()
	for key in sprite_data.keys():
		frames.add_animation(key)
		for i in range(sprite_data[key]["n"]):
			var _atlas : AtlasTexture = AtlasTexture.new()
			_atlas.atlas = texture
			_atlas.filter_clip = true
			_atlas.region = Rect2(16 * i + sprite_data[key]["x"] , sprite_data[key]["y"], 16, 32)
			frames.add_frame(key, _atlas)
	sprite_sheet.set_sprite_frames(frames)
	sprite_sheet.play("run_right")

func load_sprite_dir(sprite_ressource : Dictionary):
	if not sprite_ressource.path:
		return
		
	var dir = DirAccess.open(sprite_ressource.path)
	if dir:
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != "":
				if not file_name.ends_with(".import"):
					
					if sprite_name_label:
						sprite_name_label.text = file_name
					if dir.current_is_dir():
						print("Found directory: " + file_name)
					else:
						var texture = load(sprite_ressource.path + file_name) as Texture2D
						if (texture):
							sprite_ressource.Array.append(texture)
						else:
							print("texture loading error")
				file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")

func look_for_dir(folder_path : String) -> error:
	var dir = DirAccess.open(folder_path)
	if dir:
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != "":
				if dir.current_is_dir():
					print("Found directory: " + file_name)
					if sprites_dict.has(file_name.to_lower()):
						sprites_dict[file_name.to_lower()].path = folder_path  + file_name + "/"
					else:
						print("unsupported : ",  file_name)
				file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
		return error.ERR
	return error.OK




func generate_new_character() -> Character:
	character = Character.new()
	
	if not is_init:
		sprites_dict = {
			"body" : create_sprite_entry("", [], 0, character.body),
			"eyes" : create_sprite_entry("", [], 0, character.eyes),
			"hair" : create_sprite_entry("", [], 0, character.hair),
			"outfits" : create_sprite_entry("", [], 0, character.outfits)	
			}
		is_init =  true
	else:
		sprites_dict.body.Node = character.body
		sprites_dict.eyes.Node = character.eyes
		sprites_dict.hair.Node = character.hair
		sprites_dict.outfits.Node = character.outfits
		
		
	return character
	
func _ready():
	pass
	


func load_sprite() -> error:
	if is_loaded:
		return error.ERR
	
	if not is_init:
		print("not init")
		return error.ERR
	
	if (look_for_dir(sprite_folder) == error.ERR):
		return error.ERR
	for key in sprites_dict.values():
		load_sprite_dir(key)
		
	is_loaded = true
	return error.OK


func generate_sprites():
	for key in sprites_dict.values():
		add_sprite_sheet(key.Node, key.Array[0])
	synchronize_animations()
	
func _on_next_button_button_down():
	if sprites_dict[selected_key].Array.is_empty():
		return
		
	sprites_dict[selected_key].Index += 1
	if sprites_dict[selected_key].Index >= sprites_dict[selected_key].Array.size():
		sprites_dict[selected_key].Index = 0
	var index : int = sprites_dict[selected_key].Index
	add_sprite_sheet(sprites_dict[selected_key].Node, sprites_dict[selected_key].Array[index])
	synchronize_animations()

func synchronize_animations():
	for key in sprites_dict.keys():
		var entry = sprites_dict[key]
		if entry["Node"]:
			entry.Node.set_frame_and_progress(0, 0)
	
func _on_body_button_button_down():
	selected_key = "body"

func _on_eyes_button_button_up():
	selected_key = "eyes"

func _on_hair_button_button_up():
	selected_key = "hair"

func _on_outfit_button_button_down():
	selected_key = "outfits"
	

func randomAttributes(attributes_array : Array) -> int:
	var rng = RandomNumberGenerator.new()
	var index : int = rng.randi_range(0, attributes_array.size() - 1)
	return index
	
func randomCharacter(characterToRandomize : Character):
	add_sprite_sheet(characterToRandomize.body, sprites_dict.body.Array[randomAttributes(sprites_dict.body.Array)])
	add_sprite_sheet(characterToRandomize.eyes, sprites_dict.eyes.Array[randomAttributes(sprites_dict.eyes.Array)])
	add_sprite_sheet(characterToRandomize.hair, sprites_dict.hair.Array[randomAttributes(sprites_dict.hair.Array)])
	add_sprite_sheet(characterToRandomize.outfits, sprites_dict.outfits.Array[randomAttributes(sprites_dict.outfits.Array)])
	
	
	


func _on_randomize_button_up():
	randomCharacter(character)


func _on_button_button_down():
	if (load_sprite() == error.ERR):
		return
	
	
func _on_generate_sprite_button_up():
	generate_sprites()
