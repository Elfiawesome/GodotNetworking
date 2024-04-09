extends Node
class_name NetworkClient

# Network
var client_data: ClientData
var connected = false

# Time out
var timeout:float = 3.0
var timeout_update_intervals_limit:float = 0.4
var timeout_update_intervals:float = 0.0

var address:String
var port:int

signal data_received(data)

func _init(conecting_address: String = "127.0.0.1", connecting_port:int = 3115):
	address = conecting_address
	port = connecting_port
	client_data = ClientData.new()
	client_data.connection = StreamPeerTCP.new()
	client_data.connection.connect_to_host(address, port)
	client_data.peer = PacketPeerStream.new()
	client_data.peer.set_stream_peer(client_data.connection)
	
	timeout = 5.0
	
	client_data.connection.poll()
	var status = client_data.connection.get_status()
	if status == StreamPeerTCP.STATUS_CONNECTED:
		_connection_successful()
	elif status == StreamPeerTCP.STATUS_CONNECTING:
		print("[CLIENT] Pending connection to "+address+":"+str(port))
	elif status == StreamPeerTCP.STATUS_NONE or status == StreamPeerTCP.STATUS_ERROR:
		_connection_failed()

func _process(delta):
	if client_data==null:
		return
	
	client_data.connection.poll()
	var status = client_data.connection.get_status()
	if !connected:
		if status == StreamPeerTCP.STATUS_CONNECTED:
			_connection_successful()
			return
		if timeout>0:
			timeout-=delta
			if timeout_update_intervals < timeout_update_intervals_limit:
				timeout_update_intervals += delta
			else:
				timeout_update_intervals = 0.0
				print("[CLIENT] Pending connection to "+address+":"+str(port) + " timeout in "+str(snapped(timeout, 0.01))+"s")
		else:
			print("[CLIENT] Timeout form server")
			_connection_failed()
	else:
		if status == StreamPeerTCP.STATUS_NONE or status == StreamPeerTCP.STATUS_ERROR:
			_connection_failed()
		
		while(client_data.peer.get_available_packet_count()>0):
			var data = client_data.peer.get_var()
			data_received.emit(data)

func _connection_successful():
	print("[CLIENT] Succesfully connected to "+address+":"+str(port))
	connected=true
func _connection_failed():
	print("[CLIENT] Couldn't connected to "+address+":"+str(port))
	connected=false
	client_data.queue_free()

func send_data(data):
	client_data.peer.put_var(data)
