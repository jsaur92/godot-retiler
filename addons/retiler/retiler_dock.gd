@tool
extends Control
## Script for the Retiler dock.
##
## Provides functionality for the UI on the dock to allow users to generate "retiled" TileMapLayer nodes from the editor.

@export var save_to_path_field : TextEdit
@export var file_name_field : TextEdit
@export var open_scene_checkbox : CheckBox
@export var use_similar_checkbox : CheckBox

var tileset : TileSet
var texture : Texture2D

var tile_dict : Dictionary[Image, Vector2i]


## Called when the selected TileSet changes. 
func _on_tile_set_picker_resource_changed(resource: Resource) -> void:
	tileset = resource
	populate_tile_dict()


## Called when the selected Texture changes.
func _on_texture_picker_resource_changed(resource: Resource) -> void:
	texture = resource


## Called when the Generate TileMapLayer button is pressed.
func _on_generate_button_pressed() -> void:
	if tileset != null and texture != null:
		var tilemap = generate_tilemaplayer()
		tilemap.name = get_tilemap_name()
		var scene = PackedScene.new()
		scene.pack(tilemap)
		ResourceSaver.save(scene, get_tilemap_abs_path())
		if is_open_scene_checked():
			EditorInterface.open_scene_from_path(get_tilemap_abs_path())


## Populate the tile dictionary by matching the texture for each tile in tileset to its coords on the TileSetAtlas.
func populate_tile_dict() -> void:
	if tileset != null and tileset is TileSet:
		var source_id = tileset.get_source_id(0)
		var source : TileSetAtlasSource = tileset.get_source( source_id )
		var source_img = source.texture.get_image()
		var tile_size = tileset.tile_size
		
		#iterate through every tile in the tileset
		for row in source.get_atlas_grid_size().y:
			for col in source.get_atlas_grid_size().x:
				if source.has_tile(Vector2i(col, row)):
					#get the 2D color array of the current tile
					var this_tile = source_img.get_region(get_tile_region(Vector2i(col, row)))
					#register this 2D color array into the dictionary as the key to the tile's coords.
					tile_dict[this_tile] = Vector2i(col, row)
	
	else:
		tile_dict = {}


## Generate a TileMapLayer based on the given tileset and texture.
func generate_tilemaplayer() -> TileMapLayer:
	var tilemap := TileMapLayer.new()
	tilemap.tile_set = tileset
	
	var tile_arrays : Array[Array] = get_tiles_from_texture()
	
	#loops through the rows and columns of the "map" (inputed texture).
	for map_row in tile_arrays.size():
		for map_col in tile_arrays[map_row].size():
			if dict_has_img_key(tile_arrays[map_row][map_col]):
				tilemap.set_cell(Vector2i(map_col, map_row), 0, get_value_of_key(tile_arrays[map_row][map_col]))
			elif is_use_similar_checked():
				tilemap.set_cell(Vector2i(map_col, map_row), 0, get_best_match(tile_arrays[map_row][map_col]))
	return tilemap


## Returns an array of 2D color arrays, to represent each tile in the texture.
## True return type is Array[Array[Image]]]
func get_tiles_from_texture() -> Array[Array]:
	var tile_size = tileset.tile_size
	var image = texture.get_image()
	var map_width = image.get_width() / tile_size.x
	var map_height = image.get_height() / tile_size.y
	
	var tiles : Array[Array] = []
	
	for row in map_height:
		tiles.append([])
		for col in map_width:
			var cropped = image.get_region(Rect2i(col*tile_size.x, row*tile_size.y, tile_size.x, tile_size.y))
			tiles[row].append( cropped )
			#tested by exporting the cropped images, can confirm the tiles are correct here.
	
	return tiles


## Returns the absolute path of the TileMapLayer that will be generated.
func get_tilemap_abs_path() -> String:
	return save_to_path_field.text + file_name_field.text + ".tscn"


## Returns the name of the TileMapLayer scene.
func get_tilemap_name() -> String:
	return file_name_field.text


## Compare two images to see if they are equal.
func is_img_equal(img1:Image, img2:Image) -> bool:
	if img1.get_size() != img2.get_size():
		return false
	#print(tile_dict[img1])
	for row in img1.get_size().y:
		for col in img1.get_size().x:
			#print(img1.get_pixel(col, row), ", ", img2.get_pixel(col, row))
			if img1.get_pixel(col, row) != img2.get_pixel(col, row):
				return false
	return true


## Input the atlas coordinates of a tile of the tileset, return the region of pixels that it takes up on the tileset's source texture.
func get_tile_region(coords:Vector2i) -> Rect2i:
	
	var source_id = tileset.get_source_id(0)
	var source : TileSetAtlasSource = tileset.get_source( source_id )
	
	var tile_size = tileset.tile_size
	var margins = source.margins
	var separation = source.separation
	
	return Rect2i(margins.x + coords.x*(tile_size.x+separation.x), margins.y + coords.y*(tile_size.y+separation.y), tile_size.x, tile_size.y)


## Check to see if the tile_dict dictionary has a given image as a key.
func dict_has_img_key(img:Image) -> bool:
	for key in tile_dict.keys():
		if is_img_equal(key, img):
			return true
	return false


## Get the value in tile_dict of the given key, using is_img_equal to check the true value of the key rather than the reference.
func get_value_of_key(img:Image) -> Vector2i:
	for key in tile_dict:
		if is_img_equal(key, img):
			return tile_dict[key]
	return Vector2i(-1,-1)


## Find the tile of the tileset most similar to the given tile.
func get_best_match(img:Image) -> Vector2i:
	var best = tile_dict.keys().get(0)
	var best_value = 0 #float ranging from 0 (no matching pixels) to 1 (complete match)
	for key in tile_dict:
		var match_value = get_match_value(img, key)
		if match_value > best_value:
			best = key
			best_value = match_value
	return tile_dict[best]


func get_match_value(img1:Image, img2:Image) -> float:
	var matches = 0.
	var total = img1.get_size().x * img1.get_size().y
	
	for row in img1.get_size().y:
		for col in img1.get_size().x:
			if img1.get_pixel(col, row) == img2.get_pixel(col, row):
				matches += 1
	
	return matches / total


func is_open_scene_checked() -> bool:
	return open_scene_checkbox.button_pressed


func is_use_similar_checked() -> bool:
	return open_scene_checkbox.button_pressed
