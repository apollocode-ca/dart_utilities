import 'package:alfred/alfred.dart';
// ignore: implementation_imports
import 'package:alfred/src/type_handlers/websocket_type_handler.dart';
import 'package:apollocode_dart_utilities/src/services/websocket.dart';

class WebsocketRouter {
  WebsocketRouter(NestedRoute app) {
    app.get('/ws', (req, res) {
      return WebSocketSession(
        onOpen: (ws) {
          WebsocketService.users.add(ws);
          print("USER JOINED");
          WebsocketService.users
              .where((user) => user != ws)
              .forEach((user) => user.send('A new user joined the chat.'));
        },
        onClose: (ws) {
          WebsocketService.users.remove(ws);
          print("USER LEFT");
          WebsocketService.users.forEach((user) => user.send('A user has left.'));
        },
        onMessage: WebsocketService.onMessage
      );
    });
  }
}
