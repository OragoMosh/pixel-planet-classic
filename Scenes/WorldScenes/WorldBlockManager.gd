extends Node

var BlockTileMap = null
var BackgroundTileMap = null
var CrackBlockTileMap = null
var CrackBackgroundTileMap = null

var cur_block = 0
var last_pressed = Time.get_ticks_usec()
var cur_tilemap = null
var last_placed_pos = Vector2i(-10000, -10000)
var last_broken_pos = Vector2i(-10000, -10000)
var last_sent_id: int = -1
var last_edited_prop := Time.get_ticks_msec()

const SPECIALTIES: Array[String] = ["CRAFTING", "GRINDING", "SIGN", "DOOR", "LIGHT"]

var entrance_pos: Vector2i

var collisions_dict: Dictionary = {}
var platforms_dict: Dictionary = {}
var last_interacted_pos: Vector2i = Vector2i(-1, -1)


func collision_dict_check(_dict: Dictionary, _position: Vector2i) -> void:
	if "0," + str(_position.x) + "," + str(_position.y) in _dict.keys():
		_dict["0," + str(_position.x) + "," + str(_position.y)].queue_free()
		_dict.erase("0," + str(_position.x) + "," + str(_position.y))
	elif "1," + str(_position.x) + "," + str(_position.y) in _dict.keys():
		_dict["0," + str(_position.x) + "," + str(_position.y)].queue_free()
		_dict.erase("0," + str(_position.x) + "," + str(_position.y))


func Update(_mouse_pos: Vector2, _should_update_grid: bool, _player_pos: Vector2) -> void:
	
	if Global.WorldNode.SignBubble.visible == true:
		Global.WorldNode.SignBubble.visible = false
	
	if Global.WorldNode.Player.is_dead: return
	
	var current_item: int = Global.InventoryNode.current_item
	
	var item_data: Dictionary = Data.ItemData[str(current_item)]
	var mousePos: Vector2i = floor(_mouse_pos / 32)
	
	var map_to_check: TileMap
	if item_data.TYPE == "BLOCK":
		map_to_check = BlockTileMap
	elif item_data.TYPE == "BACKGROUND":
		map_to_check = BackgroundTileMap
	else:
		map_to_check = null
	cur_tilemap = map_to_check
	
	var interact_item_data: Dictionary = Data.ItemFromTilesetId(BlockTileMap.get_cell_source_id(0, mousePos), "BLOCK")
	
	if last_interacted_pos != mousePos and last_interacted_pos != Vector2i(-1, -1):
		var cell_atlas_original = BlockTileMap.get_cell_atlas_coords(0, last_interacted_pos)
		BlockTileMap.set_cell(0, last_interacted_pos, BlockTileMap.get_cell_source_id(0, last_interacted_pos), Vector2i(0, cell_atlas_original.y))
	
	if interact_item_data.has("SPECIALTY"):
		if interact_item_data.SPECIALTY in SPECIALTIES and Global.WorldNode.Grid.InRangeBreaking(Global.WorldNode.Player.position, _mouse_pos):
			last_interacted_pos = mousePos
			var cell_atlas_original = BlockTileMap.get_cell_atlas_coords(0, mousePos)
			BlockTileMap.set_cell(0, mousePos, BlockTileMap.get_cell_source_id(0, mousePos), Vector2i(1, cell_atlas_original.y))
			
		if interact_item_data.SPECIALTY == "SIGN" and Global.WorldData.BlockMetadata.has(str(mousePos)) and Global.WorldNode.Grid.InRangeBreaking(Global.WorldNode.Player.position, _mouse_pos):
			Global.WorldNode.SignBubble.text = Global.WorldData.BlockMetadata[str(mousePos)].SIGN_TEXT
			Global.WorldNode.SignBubble.visible = true
			#Global.WorldNode.SignBubble.get_node("AnimationPlayer").play("Zoom")
		#Global.WorldNode.SignBubble.get_node("AnimationPlayer").play_backwards("Zoom")
		
		if interact_item_data.SPECIALTY == "DOOR" and Global.WorldData.BlockMetadata.has(str(mousePos)) and Global.WorldNode.Grid.InRangeBreaking(Global.WorldNode.Player.position, _mouse_pos):
			Global.WorldNode.SignBubble.text = "Press E to join " + Global.WorldData.BlockMetadata[str(mousePos)].DOOR_LOCATION
			Global.WorldNode.SignBubble.visible = true
	
	if Input.is_action_pressed("use"):
		
		if _should_update_grid:
			
			var in_range: bool = false
			if item_data.TYPE == "BLOCK":
				in_range = Global.WorldNode.Grid.InRangePlacing(Global.WorldNode.Player.position, _mouse_pos)
			elif item_data.TYPE == "BACKGROUND":
				in_range = Global.WorldNode.Grid.InRangeBreaking(Global.WorldNode.Player.position, _mouse_pos)
			
			if map_to_check and not map_to_check.get_cell_tile_data(0, mousePos) and in_range:
				if last_sent_id == current_item and mousePos == last_placed_pos:
					return
				last_placed_pos = mousePos
				last_sent_id = current_item
				Global.WorldNode.Player.Hit()
				
				if item_data.has("SPECIALTY") and item_data.SPECIALTY in ["DOOR", "SIGN", "ENTRANCE", "CRAFTING", "DECORATION"]:
					Server.PlaceBlockRequest(current_item, mousePos, {TYPE = "_ALL", METADATA = {DIRECTION = Global.PlayerNode.Sprite.flip_h == false}})
				elif item_data.has("SPECIALTY") and item_data.SPECIALTY == "LIGHT":
					Server.PlaceBlockRequest(current_item, mousePos, {TYPE = "_ALL", METADATA = {DIRECTION = false}})
				else:
					Server.PlaceBlockRequest(current_item, mousePos, {})
		else: # (BlockTileMap.get_cell_tile_data(0, mousePos) or BackgroundTileMap.get_cell_tile_data(0, mousePos)) is added if we want to prevent hitting empty tiles
			if last_pressed < Time.get_ticks_usec() - (Global.HIT_INTERVAL * 1000000) and Global.WorldNode.Grid.InRangeBreaking(Global.WorldNode.Player.position, _mouse_pos):
				last_placed_pos = Vector2i(-100000, -100000)
				last_pressed = Time.get_ticks_usec()
				Global.WorldNode.Player.Hit()
				Server.BreakBlockRequest(mousePos)
	
	elif Input.is_action_just_pressed("interact") and Global.WorldNode.Grid.InRangeBreaking(Global.WorldNode.Player.position, _mouse_pos):
		
		if not interact_item_data.has("SPECIALTY"): return
		if PlayerState.current_state != PlayerState.STATE_TYPE.WORLD: return
		
		match interact_item_data.SPECIALTY:
			"CRAFTING":
				Global.WorldNode.WorldGUIManager.CloseGui()
				Global.WorldNode.WorldGUIManager.ChangeGui(Global.WorldNode.Crafting)
				Global.WorldNode.Crafting.item1_id = -1
				Global.WorldNode.Crafting.item2_id = -1
				Global.WorldNode.Crafting.item1_amount = 0
				Global.WorldNode.Crafting.item2_amount = 0
				Global.WorldNode.Crafting.update_slots()
				
			"GRINDING":
				Global.WorldNode.WorldGUIManager.CloseGui()
				Global.WorldNode.WorldGUIManager.ChangeGui(Global.WorldNode.Grinding)
				Global.WorldNode.Grinding.item_id = -1
				Global.WorldNode.Grinding.item_amount = 0
				Global.WorldNode.Grinding.update_slots()
				
			"SIGN":
				if Global.WorldData.OwnerId == Global.SelfData.DatabaseId or Global.SelfData.DatabaseId in Global.WorldData.AdminIds or Global.WorldData.OwnerId == -1:
					Global.WorldNode.WorldGUIManager.CloseGui()
					Global.WorldNode.WorldGUIManager.ChangeGui(Global.WorldNode.TextAdder)
					Global.WorldNode.TextAdder.label.text = "Set Sign Text"
					await Global.WorldNode.TextAdder.prompt_finished
					if Global.WorldNode.TextAdder.text != "":
						Server.SetBlockMetadataRequest(mousePos, {TYPE = "SIGN", METADATA = {SIGN_TEXT = Global.WorldNode.TextAdder.text}})
					Global.WorldNode.WorldGUIManager.CloseGui()
				
			"DOOR":
				if Global.WorldData.OwnerId == Global.SelfData.DatabaseId or Global.SelfData.DatabaseId in Global.WorldData.AdminIds or Global.WorldData.OwnerId == -1:
					Global.WorldNode.WorldGUIManager.CloseGui()
					Global.WorldNode.WorldGUIManager.ChangeGui(Global.WorldNode.TextAdder)
					Global.WorldNode.TextAdder.label.text = "Set Door Location"
					await Global.WorldNode.TextAdder.prompt_finished
					if Global.WorldNode.TextAdder.text != "":
						Server.SetBlockMetadataRequest(mousePos, {TYPE = "DOOR", METADATA = {DOOR_LOCATION = Global.WorldNode.TextAdder.text}})
					Global.WorldNode.WorldGUIManager.CloseGui()
			
			"LIGHT":
				if Global.WorldData.OwnerId == Global.SelfData.DatabaseId or Global.SelfData.DatabaseId in Global.WorldData.AdminIds or Global.WorldData.OwnerId == -1:
					if last_placed_pos != mousePos or Time.get_ticks_msec() > last_edited_prop + 200:
						last_edited_prop = Time.get_ticks_msec()
						last_placed_pos = mousePos
						print("ohio")
						Server.SetBlockMetadataRequest(mousePos, {TYPE = "LIGHT", METADATA = {DIRECTION = not Global.WorldData.BlockMetadata[str(mousePos)].DIRECTION}})
			
	elif Input.is_action_just_pressed("enter_door") and Global.WorldNode.Grid.InRangeBreaking(Global.WorldNode.Player.position, _mouse_pos):
		if Global.WorldData.BlockMetadata.has(str(mousePos)) and Global.WorldData.BlockMetadata[str(mousePos)].has("DOOR_LOCATION"):
			Server.WorldJoinRequest(Global.WorldData.BlockMetadata[str(mousePos)].DOOR_LOCATION)
	

func SetTilemaps(_block_tilemap, _background_tilemap, _crack_block_tilemap, _crack_background_tilemap) -> void:
	BlockTileMap = _block_tilemap
	BackgroundTileMap = _background_tilemap
	CrackBlockTileMap = _crack_block_tilemap
	CrackBackgroundTileMap = _crack_background_tilemap


func LoadBlockArray() -> void:
	if Global.WorldData:
		for z in 2:
			for x in Global.WorldData.WorldSize.x:
				for y in Global.WorldData.WorldSize.y:
					var blockId: int = Global.WorldData.BlockArray[z][x][y]
					
					if Data.ItemData.has(str(blockId)):
						#var Item: Dictionary = Data.ItemData[str(blockId)]
						
						PlaceAndAutotile(blockId, Vector2i(x, y), false, -1)
					
					if blockId == 22:
						entrance_pos = Vector2i(x, y)


func PlaceAndAutotile(_block_id: int, _position: Vector2i, from_server: bool, _peer_id: int) -> void:
	
	if from_server:
		var new_smoke = Global.WorldNode.Smoke.instantiate()
		
		new_smoke.position = _position * 32 + Vector2i(16, 16)
		Global.WorldNode.Particles.add_child(new_smoke)
		new_smoke.ShouldBreak(_block_id == -1)
	
	if Data.ItemData.has(str(_block_id)):
		var blockData: Dictionary = Data.ItemData[str(_block_id)]
		var tilesetId: int = blockData.TILESET_ID
		
		if blockData.TYPE == "BLOCK":
			Global.WorldData.BlockArray[0][_position.x][_position.y] = _block_id
			BlockTileMap.set_cell(0, _position, tilesetId, Vector2i.ZERO)
			if blockData.AUTOTILE == "TWO":
				BlockTileMap.Autotile2(tilesetId, _position)
			elif blockData.AUTOTILE == "FOUR":
				BlockTileMap.Autotile4(tilesetId, _position, true, "BLOCK")
			elif blockData.AUTOTILE == "SIXTEEN":
				BlockTileMap.Autotile16(tilesetId, _position, true, "BLOCK")
			
			if blockData.has("SPECIALTY"):
				match blockData.SPECIALTY:
					
					"HURT":
						var new_area = Global.WorldNode.HurtArea.instantiate()
						new_area.position = _position * 32
						Global.WorldNode.add_child(new_area)
						collisions_dict["0," + str(_position.x) + "," + str(_position.y)] = new_area
					
					"PLATFORM":
						var new_area = Global.WorldNode.PlatformArea.instantiate()
						new_area.position = _position * 32
						Global.WorldNode.add_child(new_area)
						platforms_dict["0," + str(_position.x) + "," + str(_position.y)] = new_area
			
			if Global.WorldData.BlockMetadata.has(str(_position)):
				if Global.WorldData.BlockMetadata[str(_position)].has("DIRECTION"):
					var top_bottom = 0
					if Global.WorldData.BlockMetadata[str(_position)].DIRECTION == false:
						top_bottom = 1
					BlockTileMap.set_cell(0, _position, tilesetId, Vector2i(0, top_bottom))


		elif blockData.TYPE == "BACKGROUND":
			Global.WorldData.BlockArray[1][_position.x][_position.y] = _block_id
			BackgroundTileMap.set_cell(0, _position, tilesetId, Vector2i.ZERO)
			if blockData.AUTOTILE == "TWO":
				BackgroundTileMap.Autotile2(tilesetId, _position)
			elif blockData.AUTOTILE == "FOUR":
				BackgroundTileMap.Autotile4(tilesetId, _position, true, "BACKGROUND")
			elif blockData.AUTOTILE == "SIXTEEN":
				BackgroundTileMap.Autotile16(tilesetId, _position, true, "BACKGROUND")
				
			if blockData.has("SPECIALTY"):
				match blockData.SPECIALTY:
					"HURT":
						var new_area = Global.WorldNode.HurtArea.instantiate()
						new_area.position = _position * 32
						Global.WorldNode.add_child(new_area)
						collisions_dict["1," + str(_position.x) + "," + str(_position.y)] = new_area
						
					"PLATFORM":
						var new_area = Global.WorldNode.PlatformArea.instantiate()
						new_area.position = _position * 32
						Global.WorldNode.add_child(new_area)
						platforms_dict["0," + str(_position.x) + "," + str(_position.y)] = new_area
	
	
	elif _block_id == -1:
		
		collision_dict_check(collisions_dict, _position)
		collision_dict_check(platforms_dict, _position)
		
		var blockArray = Global.WorldData.BlockArray
		

		if blockArray[0][_position.x][_position.y] != -1:

			var blockId = blockArray[0][_position.x][_position.y]
			var blockData: Dictionary = Data.ItemData[str(blockId)]
			var tilesetId: int = blockData.TILESET_ID
			
			blockArray[0][_position.x][_position.y] = -1
			BlockTileMap.set_cell(0, _position, -1, Vector2i.ZERO)
			CrackBlockTileMap.set_cell(0, _position, -1)

			if blockData.AUTOTILE == "TWO":
				BlockTileMap.Autotile2(tilesetId, _position)
			elif blockData.AUTOTILE == "FOUR":
				BlockTileMap.Autotile4(tilesetId, _position, true, "BLOCK")
			elif blockData.AUTOTILE == "SIXTEEN":
				BlockTileMap.Autotile16(tilesetId, _position, true, "BLOCK")

			
		elif blockArray[1][_position.x][_position.y] != -1:
			var blockId = blockArray[1][_position.x][_position.y]
			var blockData: Dictionary = Data.ItemData[str(blockId)]
			var tilesetId: int = blockData.TILESET_ID
			
			blockArray[1][_position.x][_position.y] = -1
			BackgroundTileMap.Autotile2(BlockTileMap.get_cell_source_id(0, _position), _position)
			BackgroundTileMap.set_cell(0, _position, -1, Vector2i.ZERO)
			CrackBackgroundTileMap.set_cell(0, _position, -1)
			
			if blockData.AUTOTILE == "TWO":
				BackgroundTileMap.Autotile2(blockData.TILESET_ID, _position)
			elif blockData.AUTOTILE == "FOUR":
				BackgroundTileMap.Autotile4(tilesetId, _position, true, "BACKGROUND")
			elif blockData.AUTOTILE == "SIXTEEN":
				BackgroundTileMap.Autotile16(tilesetId, _position, true, "BACKGROUND")
		

var crack_dict: Dictionary = {}

func BreakBlock(_broken_value: int, _position: Vector2i, _peer_id: int) -> void:
	var blockId: int
	if Global.WorldData.BlockArray[0][_position.x][_position.y] != -1:
		blockId = Global.WorldData.BlockArray[0][_position.x][_position.y]
	elif Global.WorldData.BlockArray[1][_position.x][_position.y] != -1:
		blockId = Global.WorldData.BlockArray[1][_position.x][_position.y]

	var blockData: Dictionary = Data.ItemData[str(blockId)]

	var animationPosition: Vector2i = Vector2i((8 / blockData.HARDNESS) * floor(blockData.HARDNESS - _broken_value), 0)

	
	var new_smoke = Global.WorldNode.Smoke.instantiate()
	
	if Server.self_peer_id != _peer_id:
		new_smoke.peer_breaking = true
		print("Peer hitting this")
	
	new_smoke.position = _position * 32 + Vector2i(16, 16)
	Global.WorldNode.Particles.add_child(new_smoke)
	new_smoke.ShouldBreak(true)
	
	if blockData.TYPE == "BLOCK":
		print("destroying")
		crack_dict["0,"+str(_position.x)+","+str(_position.y)] = Time.get_ticks_msec()
		CrackBlockTileMap.set_cell(0, _position, 1, animationPosition)
		await Global.WorldNode.get_tree().create_timer(15).timeout
		if Time.get_ticks_msec() - crack_dict["0,"+str(_position.x)+","+str(_position.y)] >= 14000 and is_instance_valid(CrackBlockTileMap):
			CrackBlockTileMap.set_cell(0, _position, 0)
		
	elif blockData.TYPE == "BACKGROUND":
			
		crack_dict["1,"+str(_position.x)+","+str(_position.y)] = Time.get_ticks_msec()
		CrackBackgroundTileMap.set_cell(0, _position, 1, animationPosition)
		await Global.WorldNode.get_tree().create_timer(15).timeout
		if Time.get_ticks_msec() - crack_dict["1,"+str(_position.x)+","+str(_position.y)] >= 14000 and is_instance_valid(CrackBackgroundTileMap):
			CrackBackgroundTileMap.set_cell(0, _position, 0)

func ChangeDirection(position: Vector2i, direction: bool) -> void:
	var cell_atlas = BlockTileMap.get_cell_atlas_coords(0, position)
	var top_bottom = 0
	if direction == false:
		top_bottom = 1
	print(Vector2i(cell_atlas.x, top_bottom))
	BlockTileMap.set_cell(0, position, BlockTileMap.get_cell_source_id(0, position), Vector2i(cell_atlas.x, top_bottom))
	
