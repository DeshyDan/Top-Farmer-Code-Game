extends Button

var instance: int
var server = TCPServer.new()
var peer
var client
var port = 12345

func _on_pressed():
	start_server()
	
	#instance = OS.create_instance(["-s", "child_process.gd", "--headless", ">", "res://player_log.txt"])
	#_stream = tcp.take_connection()

func start_server():
	var result = server.listen(port,"127.0.0.1")
	if result == OK:
		print("Server is listening on port %d" % port)
	else:
		print("Failed to start server: %s" % result)

var peers: Array[PacketPeerStream] = []
func _process(_delta):
	if server.is_connection_available():
		var client = server.take_connection()
		if client:
			var peer = PacketPeerStream.new()
			peer.stream_peer = client
			peers.append(peer)
			print("connected")
			peer.put_packet("Hello from server".to_utf8_buffer())

	for peer in peers:
		if peer.get_available_packet_count() > 0:
			var packet = peer.get_packet().get_string_from_utf8()
			print("Received: %s" % packet)

func send_data_to_client(client: StreamPeerTCP, data: String):
	var peer = PacketPeerStream.new()
	peer.set_stream_peer(client)
	peer.put_packet(data.to_utf8_buffer())
