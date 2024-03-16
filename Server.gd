extends Node

const PORT: int = 27015


const ADDRESS: String = "199.244.48.63" #"45.78.139.67"


var dtls := DTLSServer.new()
var Peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()

var self_peer_id
var disconnected = false

var cert = load("res://Certificates/X509_Certificate.crt")

var summon_position = Vector2(-2000, -2000)

func _ready() -> void:
	multiplayer.connect("connected_to_server", _connected_to_server)
	multiplayer.connect("connection_failed", on_connection_failed)
	multiplayer.connect("server_disconnected", on_server_disconnected)

func _connected_to_server() -> void:
	disconnected = true
	VersionRequest()

func on_connection_failed():
	print("connection failed")

func on_server_disconnected():
	disconnected = true
	
	Disconnected.showDisconnect()
	print("server disconnected")

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		Peer.close()


func Connect() -> void:

	Peer.create_client(ADDRESS, PORT)
	#Peer.host.dtls_client_setup(ADDRESS, TLSOptions.client(cert))
	
	multiplayer.multiplayer_peer = Peer
	
	self_peer_id = multiplayer.get_unique_id()


func VersionRequest() -> void:
	rpc_id(1, "Version", Global.VERSION)


func RegisterRequest(_username: String, _password: String) -> void:
	rpc_id(1, "Register", _username, _password)

func LoginRequest(_username: String, _password: String) -> void:
	rpc_id(1, "Login", _username, _password)

func WorldJoinRequest(_world_name: String) -> void:
	rpc_id(1, "WorldJoin", _world_name)

func WorldLeaveRequest() -> void:
	rpc_id(1, "WorldLeave")

func PlaceBlockRequest(_block_id: int, _coordinates: Vector2i, metadata: Dictionary) -> void:
	rpc_id(1, "PlaceBlock", _block_id, _coordinates, metadata)


func BreakBlockRequest(_position: Vector2i) -> void:
	rpc_id(1, "BreakBlock", _position)


func UpdatePositionRequest(_position: Vector2, _current_state, _direction) -> void:
	rpc_id(1, "UpdatePosition", _position, _current_state, _direction)


func EquipClothingRequest(_item_id: int) -> void:
	rpc_id(1, "EquipClothing", _item_id)


func ShopPurchaseRequest(_pack_id: String) -> void:
	rpc_id(1, "ShopPurchase", _pack_id)


func CraftRequest(_item1_id: int, _item2_id: int, _item1_amount: int, _item2_amount: int) -> void:
	rpc_id(1, "Craft", _item1_id, _item2_id, _item1_amount, _item2_amount)


func GrindRequest(_item_id: int, _item_amount: int) -> void:
	rpc_id(1, "Grind", _item_id, _item_amount)


func ListItemRequest(_item_id: int, _item_amount: int, _price: int, _hours_active: int) -> void:
	rpc_id(1, "ListItem", _item_id, _item_amount, _price, _hours_active)


func SearchMarketplaceRequest(_item_name: String, _min_price: int, _max_price: int, _page_number: int, is_seller: bool) -> void:
	rpc_id(1, "SearchMarketplace", _item_name, _min_price, _max_price, _page_number, is_seller)


func BuyListingRequest(_id: int) -> void:
	rpc_id(1, "BuyListing", _id)


func SetBlockMetadataRequest(position: Vector2i, metadata_info: Dictionary) -> void:
	rpc_id(1, "SetBlockMetadata", position, metadata_info)


func WorldClaimRequest() -> void:
	rpc_id(1, "WorldClaim")

func ItemDropRequest(_item_id, _amount) -> void:
	rpc_id(1, "ItemDrop", _item_id, _amount)
	print("player sent drop request")

func ItemDropPickupRequest(_drop_uid) -> void:
	rpc_id(1, "ItemDropPickup", _drop_uid)

@rpc("authority")
func updateDropItem(dropped_data):
	
	Global.WorldNode.DroppedItemUpdate(dropped_data)

@rpc("authority")
func returnDropItem(dropped_data):
	
	Global.WorldNode.DroppedItemUpdate(dropped_data)

@rpc("authority")
func returnPickupItem(_drop_uid, _peer_id):
	print("picking up item")
	
	for dropped in Global.WorldNode.Dropped.get_children():
		if dropped.drop_UID == _drop_uid:
			dropped.initiatePickup(_peer_id)

@rpc("authority")
func Version(_valid: bool):
	if _valid:
		get_tree().change_scene_to_file("res://Frames/AccountMenu/AccountMenu.tscn")
	else:
		get_tree().change_scene_to_file("res://Frames/OutdatedClientWarning/OutdatedClientWarning.tscn")
	

@rpc("authority")
func Register(_status: String):
	Global.AccountMenuNode.StatusLabel.text = _status


@rpc("authority")
func Login(_success: bool, _username: String, database_id: int):
	if _success:
		get_tree().change_scene_to_file("res://Frames/WorldMenu/WorldMenu.tscn")
		Global.Username = _username
		Global.SelfData.DatabaseId = database_id
	else:
		Global.AccountMenuNode.StatusLabel.text = "Login error! Is the username/password correct?"


@rpc("authority")
func WorldJoin(_world_data: Dictionary, _inventory: Array, _bits: int, _clothes: Dictionary, permission_level: int):
	Global.SelfData.Inventory = _inventory
	Global.SelfData.Bits = _bits
	Global.SelfData.Clothes = _clothes
	Global.SelfData.PermissionLevel = permission_level
	
	var ReceivedWorldData: WorldData = WorldData.new()
	ReceivedWorldData.LoadFromDict(_world_data)
	Global.WorldData = ReceivedWorldData
	
	if Global.SelfData.DatabaseId == Global.WorldData.OwnerId:
		Global.SelfData.is_owner = true
		Global.SelfData.is_admin = false
	elif Global.SelfData.DatabaseId in Global.WorldData.AdminIds:
		Global.SelfData.is_admin = true
		Global.SelfData.is_owner = false
	else:
		Global.SelfData.is_owner = false
		Global.SelfData.is_admin = false
	
	Global.LastVisitedPlanet = Global.WorldData.Name
	print(Global.WorldData.OwnerId, "  |  ", Global.WorldData.AdminIds)
	Save.userData.Misc.RecentPlanet = Global.LastVisitedPlanet
	get_tree().change_scene_to_file("res://Frames/World/World.tscn")


@rpc("authority")
func PlaceBlock(_block_id: int, _position: Vector2i, _peer_id: int):
	if Global.WorldNode:
		Global.WorldNode.WorldBlockManager.PlaceAndAutotile(_block_id, _position, true, _peer_id)


@rpc("authority", "unreliable")
func BreakBlock(_broken_value: int, _position: Vector2i, _peer_id: int):

	if Global.WorldNode:
		Global.WorldNode.WorldBlockManager.BreakBlock(_broken_value, _position, _peer_id)


@rpc("authority")
func PeerJoined(_peer_id: int, _peer_name: String, _clothes: Dictionary, permission_level: int, database_id: int):
	Global.WorldNode.WorldPeerManager.AddPeer(_peer_id, _peer_name, _clothes, permission_level, database_id)


@rpc("authority")
func PeerLeft(_peer_id: int):
	print(_peer_id, " left the world.")
	Global.WorldNode.WorldPeerManager.RemovePeer(_peer_id)


@rpc("authority", "unreliable")
func UpdatePosition(_peer_id: int, _position: Vector2, _current_state, _direction) -> void:
	if Global.WorldNode:
		Global.WorldNode.WorldPeerManager.UpdatePeer(_peer_id, _position, _current_state, _direction)


@rpc("authority")
func WorldLeave():
	get_tree().change_scene_to_file("res://Frames/WorldMenu/WorldMenu.tscn")

	#if is_instance_valid(Global.WorldNode):
		#Global.WorldNode.queue_free()
	Global.InventoryNode = null

	Global.Peers = {}
	Global.WorldPeers = {}

@rpc("authority")
func SummonPlayer(world_name, position):
	Server.WorldJoinRequest(world_name)
	summon_position = position
	
@rpc("authority")
func setPlayerPosition(position):
	Global.PlayerNode.position = position

@rpc("authority")
func UpdateInventory(_slot_data: Array):
	# Bits check
	if _slot_data[0] == -100:
		Global.SelfData.Bits += _slot_data[1]
		if Global.WorldNode:
			Global.WorldNode.HUD.display_bits(Global.SelfData.Bits)
		return

	var inventory = Global.SelfData.Inventory
	for slot in inventory:
		if slot[0] == _slot_data[0]:
			slot[1] += _slot_data[1]
			if Global.InventoryNode:
				Global.InventoryNode.UpdateSlot(_slot_data)
			return

	for slot in inventory:
		if slot[0] == -1:
			slot[0] = _slot_data[0]
			slot[1] = _slot_data[1]
			if Global.InventoryNode:
				Global.InventoryNode.UpdateSlot(_slot_data)
			return


@rpc("authority")
func BlockDrop(_peer_id: int, _drop_data: Array):

	if _peer_id == multiplayer.get_unique_id():
		Global.WorldNode.Player.CreateDrop(_drop_data)
	else:
		Global.WorldNode.WorldPeerManager.CreateDrop(_peer_id, _drop_data)


@rpc("authority")
func EquipClothing(_peer_id: int, _clothing: Dictionary):

	if _peer_id == Global.WorldNode.WorldPeerManager.MultiplayerId:
		Global.SelfData.Clothes = _clothing
		Global.WorldNode.Player.SetClothing(_clothing)
		Global.InventoryNode.SetClothesSlots(_clothing)
	else:
		Global.WorldNode.WorldPeerManager.UpdatePeerClothing(_peer_id, _clothing)

@rpc("authority")
func MessageRequest(_nickname: String, _message: String, _peer_id: int, forced_by_server: bool = false):

	Global.ChatNode.incomingMessage(_nickname, _message)


	if _peer_id == Global.WorldNode.WorldPeerManager.MultiplayerId:
		print("YOU SENT THIS MESSAGE NOT THEM")
		Global.PlayerNode.messageSent(_message, forced_by_server)
	else:
		Global.WorldNode.WorldPeerManager.PeerMessage(_peer_id, _message, forced_by_server)
		print("MESSAGE SENT BY THEM")

@rpc("authority")
func ShopPurchase(_items: Array, _can_buy_again: bool):

	if is_instance_valid(Global.WorldNode):
		Global.WorldNode.ShowRewards(_items, _can_buy_again)


@rpc("authority")
func SearchMarketplace(_search_result: Array):
	if len(Global.WorldNode.WorldGUIManager.gui_stack) > 0 and Global.WorldNode.WorldGUIManager.gui_stack.front() == Global.WorldNode.Marketplace:
		Global.WorldNode.Marketplace.SetListings(_search_result)
	else:
		Global.WorldNode.SellItem.SetListings(_search_result)


@rpc("authority")
func BuyListing(listing_id: int):
	if len(Global.WorldNode.WorldGUIManager.gui_stack) > 0 and Global.WorldNode.WorldGUIManager.gui_stack.front() == Global.WorldNode.Marketplace:
		Global.WorldNode.Marketplace.DisableListing(listing_id)
	else:
		Global.WorldNode.SellItem.DisableListing(listing_id)


@rpc("authority")
func SetBlockMetadata(position: Vector2i, metadata: Dictionary):
	print("metadata update: ", metadata)
	Global.WorldData.BlockMetadata[str(position)] = metadata
	if metadata.has("DIRECTION"):
		Global.WorldNode.WorldBlockManager.ChangeDirection(position, metadata.DIRECTION)


@rpc("authority")
func WorldPermissionUpdate(database_id: int, permission_level: int, player_name: String = ""):
	if permission_level == Global.PERMISSIONS.WORLD_OWNER:
		Global.WorldData.OwnerId = database_id
		if player_name != "":
			Global.WorldData.OwnerName = player_name
	elif permission_level == Global.PERMISSIONS.WORLD_ADMIN:
		Global.WorldData.AdminIds.append(database_id)
		
	print(database_id)
	print(Global.WorldPeers)
	
	if Global.SelfData.DatabaseId != database_id:
		for peer_key in Global.WorldPeers:
			var peer = Global.WorldPeers[peer_key]
			if peer.DatabaseId == database_id:
				if permission_level == Global.PERMISSIONS.WORLD_OWNER:
					peer.is_owner = true
				elif permission_level == Global.PERMISSIONS.WORLD_ADMIN:
					peer.is_admin = true
				else:
					peer.is_owner = false
					peer.is_admin = false
	else:
		if permission_level == Global.PERMISSIONS.WORLD_OWNER:
			Global.SelfData.is_owner = true
		elif permission_level == Global.PERMISSIONS.WORLD_ADMIN:
			Global.SelfData.is_admin = true
		else:
			Global.SelfData.is_owner = false
			Global.SelfData.is_admin = false
	
	Global.WorldNode.WorldPeerManager.UpdateName(database_id)


@rpc("authority")
func Message(message: String, icon):
	
	if message == "Success creating account!":
		Global.AccountMenuNode.LoginAfterRegister()
		return
	
	if is_instance_valid(Global.NotificationsNode):
		Global.NotificationsNode.Notification(message, icon)
	
# Throwaway funcs
@rpc("authority") func Craft(): pass
@rpc("authority") func Grind(): pass
@rpc("authority") func ListItem(): pass
@rpc("authority") func WorldClaim(): pass
@rpc("authority") func ItemDropPickup(): pass
@rpc("authority") func ItemDrop(): pass
