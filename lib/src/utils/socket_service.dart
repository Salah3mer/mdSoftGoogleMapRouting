import 'package:flutter/material.dart';
import 'package:mdsoft_google_map_routing/src/utils/constants.dart'
    as google_map_routing;
import 'package:socket_io_client/socket_io_client.dart' as socket_io;

class SocketService {
  late socket_io.Socket socket;

  void initializeSocket({String? socketBaseUrl}) {
    debugPrint(
        'Initializing socket...  ${socketBaseUrl ?? google_map_routing.GoogleMapConfig.socketBaseUrl}');
    // Configure the socket with the server URL
    socket = socket_io.io(
      socketBaseUrl ?? google_map_routing.GoogleMapConfig.socketBaseUrl,
      <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': true,
        'reconnect': true,
        'reconnectDelay': 1000,
      },
    );

    // Connect to the server
    socket.connect();

    // Handle connection events
    socket.on('connect', (_) {
      debugPrint('Connected to the server');
    });

    socket.on('disconnect', (_) {
      debugPrint('Disconnected from the server');
    });

    socket.on('error', (data) {
      debugPrint('Socket error: $data errorrrrrrrrrr');
    });
  }

  // Function to send data
  void sendMessage(String event, dynamic data) {
    socket.emit(event, data);
  }

  // Function to listen for events
  void onMessage(String event, Function(dynamic) callback) {
    socket.on(event, callback);
  }

  // Function to listen for events
  void clearSocket() {
    socket.clearListeners();
    socket.close();
  }

  void updateSocket() {
    clearSocket();
  }
}
