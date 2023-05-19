extends NetworkNode

var Server: TCPServer #Holding TCP Server Object
var client_datas = {}
var socketincrement = 1

signal Connect
signal Disconnect
signal ReceiveData

func _CreateServer():
	Server = TCPServer.new()
	var err = Server.listen(Port,Address)
	if err == OK:
		print("Server Started!")
		set_process(true)
	else:
		print("Failed to start server")
	return err

func _process(_delta):
	if Server!=null:
		if Server.is_connection_available():#Check if someone is trying to connect
			var client = Server.take_connection() #Accept Connection
			var connectedport = socketincrement #client.get_connected_port()
			socketincrement+=1
			client_datas[connectedport] = client_data.new()
			client_datas[connectedport].peer = PacketPeerStream.new()
			client_datas[connectedport].peer.set_stream_peer(client)
			client_datas[connectedport].connection = client
			print("A Client has Connected! "+str(connectedport))
			emit_signal("Connect",connectedport)
	for key in client_datas:
		var _client_data = client_datas[key]
		var _connection = _client_data.connection
		var _peer = _client_data.peer
		#Update connection status
		_connection.poll()
		#Check for disconecction
		if _connection.get_status() == _connection.STATUS_ERROR or _connection.get_status() == _connection.STATUS_NONE:
			print("A Client has disconected: "+str(key))
			client_datas.erase(key)
			emit_signal("Disconnect",key)
			continue #Skip this one and move to the next
		#Check for receiving data
		if _peer.get_available_packet_count() > 0:
			var data_received = _peer.get_var()
			print("Server: received data "+str(data_received))
			emit_signal("ReceiveData",key,data_received)
	
#	if Input.is_action_just_pressed("ui_up"): #Test packet
#		for key in client_datas:
#			SendData(client_datas[key].connection,"HELLO THEERE")

func SendData(connectionID,message):
	if client_datas.has(connectionID):
		client_datas[connectionID].peer.put_var(message)

