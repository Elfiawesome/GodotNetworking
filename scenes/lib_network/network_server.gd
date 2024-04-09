extends Node
class_name NetworkServer

# Network
var server: TCPServer # Holds the TCP Server Object
var client_datas:Dictionary = {}
var next_client_id = 1

signal client_connected(client_id)
signal client_disconnected(client_id)
signal data_received(client_id, data)


func _init(address: String = "127.0.0.1", port:int = 3115):
	server = TCPServer.new()
	var err = server.listen(port, address)
	if err == OK:
		print("Server started on port %d" % port)
	else:
		print("Failed to start server")


func _process(_delta):
	if server!=null:
		if server.is_connection_available():# Check if someone is trying to connect
			var client_connection:StreamPeerTCP = server.take_connection() # Accept Connection
			var client_id = next_client_id
			next_client_id+=1
			client_datas[client_id] = ClientData.new()
			client_datas[client_id].peer = PacketPeerStream.new()
			client_datas[client_id].peer.set_stream_peer(client_connection)
			client_datas[client_id].connection = client_connection
			print("[SERVER] A Client has Connected! "+str(client_id))
			client_connected.emit(client_id)
	
	for client_id in client_datas:
		var client_data:ClientData = client_datas[client_id]
		var connection = client_data.connection
		var peer = client_data.peer
		
		# Update connection status
		connection.poll()
		#Check for disconnection
		if connection.get_status() == connection.STATUS_ERROR or connection.get_status() == connection.STATUS_NONE:
			print("[SERVER] A Client has disconnected: "+str(client_id))
			client_datas.erase(client_id)
			client_disconnected.emit(client_id)
			continue
		# Check for receiving data
		while(peer.get_available_packet_count() > 0):
			var data = peer.get_var()
			data_received.emit(client_id, data)



func send_data(client_id:int, data):
	if client_datas.has(client_id):
		client_datas[client_id].peer.put_var(data)
