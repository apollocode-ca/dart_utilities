import 'package:alfred/alfred.dart';
// ignore: implementation_imports
import 'package:alfred/src/type_handlers/websocket_type_handler.dart';
import 'package:apollocode_dart_utilities/src/services/websocket.dart';

class WebsocketRouter {
  WebsocketRouter(NestedRoute app, { bool useAuth = true, Future<bool> Function(String token)? authValidationFunction }) {
    app.get('/', (req, res) {
      return WebSocketSession(
        onOpen: (ws) async {
          
          if (useAuth) {
            var authorization = req.uri.queryParameters['authorization'] ?? "";
            if (authValidationFunction == null) {
              throw Error();
            }

            var tokenIsValid = await authValidationFunction(authorization);

            if (!tokenIsValid) {
              print("A websocket connection failed: authentication failed.");
              ws.close(493, "Authentication failed.");
              return;
            }
          }
          
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
