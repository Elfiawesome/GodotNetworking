extends Node2D

func _ready():
	var address = "127.0.0.1"
	var port = 1454
	var network_client = NetworkClient.new(address, port)
	network_client.data_received.connect(
		func(data):
			print("Client received data: "+str(data))
			network_client.send_data("Hello Server")
	)
	add_child(network_client)
	
	
	var network_server = NetworkServer.new(address, port)
	network_server.client_connected.connect(
		func(player_id):
			print("Server has connection for id: "+str(player_id))
			network_server.send_data(player_id, "Hello Client")
	)
	network_server.client_disconnected.connect(
		func(player_id):
			print("Server has disconnection for id: "+str(player_id))
	)
	network_server.data_received.connect(
		func(player_id, data):
			print("Server received data from ("+str(player_id)+"): "+str(data))
	)
	add_child(network_server)


