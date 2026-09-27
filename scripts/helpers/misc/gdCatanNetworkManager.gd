
class_name gdCatanNetworkManager
extends Node

@export var PORT := 7000
@export var MAX_CLIENTS := 4
@export var LOAD_PATH : PackedScene  # "res://scenes/World.tscn"

var peer_connected_timer : Timer
	
func _ready() -> void:
	multiplayer.connection_failed.connect(_on_failed)

	multiplayer.connected_to_server.connect(_on_connected)
	multiplayer.peer_connected.connect(_on_peer_connected)

	multiplayer.server_disconnected.connect(_on_server_disconnected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

	var args := OS.get_cmdline_args()
	if "server" in args:
		peer_connected_timer = Timer.new()
		peer_connected_timer.wait_time = 5.0
		peer_connected_timer.one_shot = true
		peer_connected_timer.timeout.connect(_on_peer_timer_timeout)
		add_child(peer_connected_timer)

		host_game()

	elif "client" in args:
		await get_tree().create_timer(0.5).timeout
		join_game()
	else:
		await get_tree().create_timer(0.1).timeout
		_on_peer_timer_timeout()

func host_game() -> void:
	var peer := ENetMultiplayerPeer.new()
	var err := peer.create_server(PORT, MAX_CLIENTS)
	if err != OK:
		push_error("Server failed: %s" % error_string(err))
		return
	multiplayer.multiplayer_peer = peer
	print("[HOST] Server started on port %d" % PORT)

func join_game(address: String = "127.0.0.1") -> void:
	var peer := ENetMultiplayerPeer.new()
	var err := peer.create_client(address, PORT)
	if err != OK:
		push_error("Client failed: %s" % error_string(err))
		return
	multiplayer.multiplayer_peer = peer
	print("[CLIENT] Connecting to %s:%d..." % [address, PORT])

func _on_peer_connected(id: int) -> void:
	print("Peer %d connected" % id)

	if multiplayer.is_server():
		peer_connected_timer.start()  # restarts the 5s countdown

func _on_peer_disconnected(id: int) -> void:
	print("Peer %d disconnected" % id)

func _on_connected() -> void:
	print("[CLIENT] Connected! My ID: %d" % multiplayer.get_unique_id())

func _on_failed() -> void:
	print("[CLIENT] Connection failed")

func _on_server_disconnected() -> void:
	print("Server disconnected")   

func _on_peer_timer_timeout() -> void:
	change_scene.rpc()  # tell ALL peers (including self) to switch

@rpc("authority", "call_local", "reliable")
func change_scene() -> void:
	if peer_connected_timer:
		peer_connected_timer.queue_free()
	get_tree().change_scene_to_packed(LOAD_PATH)
