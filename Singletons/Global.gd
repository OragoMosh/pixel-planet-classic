extends Node

var AccountMenuNode: Control
var WorldNode: Node2D
var PeersNode: Node2D
var InventoryNode: Control
var NotificationsNode: Control
var WorldData: WorldData
var SelfData: PeerData = PeerData.new()
var Peers: Dictionary
var Username: String
var WorldPeers: Dictionary
var LastVisitedPlanet: String = ""
var ChatNode: Control
var CurrentItem: int = -1
var PlayerNode
var DisconnectionNode

const HIT_INTERVAL: float = 0.2
const VERSION: String = "a1.1_green"

enum PERMISSIONS { NORMAL = 0, WORLD_OWNER = 1, WORLD_ADMIN = 2, CREATOR = 3, MODERATOR = 4, DEVELOPER = 5 }

var drop_id

func getCoordsFromUID(dropped_UID: String) -> String:
	var coords_str = dropped_UID.split("_")[0]  # Get the substring before the first "_"
	var coords = coords_str.split("x")  # Split by "x" to get X and Y parts
	var x = int(coords[0])
	var y = int(coords[1])
	return (str(x) + "," + str(y))

func getVector2CoordsFromUID(dropped_UID: String) -> Vector2:
	var coords_str = dropped_UID.split("_")[0]  # Get the substring before the first "_"
	var coords = coords_str.split("x")  # Split by "x" to get X and Y parts
	var x = int(coords[0])
	var y = int(coords[1])
	return Vector2(x, y)
