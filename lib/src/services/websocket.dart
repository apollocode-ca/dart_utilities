import 'dart:io';

import 'package:apollocode_dart_utilities/src/models/ws_data.dart';
import 'package:apollocode_dart_utilities/src/models/ws_user.dart';
import 'package:eventify/eventify.dart';

class WebsocketService {
  static EventEmitter emitter = EventEmitter();
  static List<WsUser> users = [];

  static Future onMessage(ws, dynamic data) async {
    data = data as WSData;
    WebsocketService.emitter.emit(data.event, null, data.data);
  }
}
