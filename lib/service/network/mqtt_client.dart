import 'dart:io';

import 'package:flutter/services.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

Future<MqttServerClient> connect() async {
  MqttServerClient client = MqttServerClient.withPort(
      'hermezpay-mqtt.internaltestnet.hermez.io', 'hermez_flutter_app', 8883);

  /// Set logging on if needed, defaults to off
  client.logging(on: false);

  /// Set secure working
  client.secure = true;

  // Set the port
  //client.port =
  //    8883; // Secure port number for mosquitto, no client certificate required

  /// Security context

  ByteData data = await rootBundle.load('lib/secrets/hermezpay-mqtt.crt');
  final context = SecurityContext.defaultContext;
  context.setTrustedCertificatesBytes(data.buffer.asUint8List());
  //final currDir =
  //    '${path.separator}lib${path.separator}service${path.separator}network${path.separator}';
  //context
  //    .setTrustedCertificates(currDir + path.join('pem', 'hermezpay-mqtt.crt'));

  /// Set keep alive.
  client.keepAlivePeriod = 60;

  /// Add an auto reconnect callback.
  /// This is the 'pre' auto re connect callback, called before the sequence starts.
  //client.onAutoReconnect = onAutoReconnect;

  /// Add an auto reconnect callback.
  /// This is the 'post' auto re connect callback, called after the sequence
  /// has completed. Note that re subscriptions may be occurring when this callback
  /// is invoked. See [resubscribeOnAutoReconnect] above.
  //client.onAutoReconnected = onAutoReconnected;

  /// Add the successful connection callback
  client.onConnected = onConnected;

  /// Add the unsolicited disconnection callback
  client.onDisconnected = onDisconnected;
  client.onUnsubscribed = onUnsubscribed;

  /// Add a subscribed callback, there is also an unsubscribed callback if you need it.
  /// You can add these before connection or change them dynamically after connection if
  /// you wish. There is also an onSubscribeFail callback for failed subscriptions, these
  /// can fail either because you have tried to subscribe to an invalid topic or the broker
  /// rejects the subscribe request.
  client.onSubscribed = onSubscribed;
  client.onSubscribeFail = onSubscribeFail;

  /// Set a ping received callback if needed, called whenever a ping response(pong) is received
  /// from the broker.
  client.pongCallback = pong;

  /// Set an on bad certificate callback, note that the parameter is needed.
  client.onBadCertificate = (dynamic a) => true;

  final connMessage = MqttConnectMessage()
      .withClientIdentifier('hermez_flutter_app')
      .withWillTopic('willtopic')
      .withWillMessage('Will message')
      .startClean() // Non persistent session for testing
      .withWillQos(MqttQos.atLeastOnce);
  print('Mosquitto client connecting....');
  client.connectionMessage = connMessage;

  /// Set the ping response disconnect period, if a ping response is not received from the broker in this period
  /// the client will disconnect itself.
  /// Note you should somehow get your broker to stop sending ping responses without forcing a disconnect at the
  /// network level to run this example. On way to do this if you are using a wired network connection is to pull
  /// the wire, on some platforms no network events will be generated until the wire is re inserted.
  //client.disconnectOnNoResponsePeriod = 1;

  /// Set auto reconnect
  //client.autoReconnect = true;

  try {
    await client.connect();
  } catch (e) {
    print('MQTT Client Exception: $e');
    client.disconnect();
  }

  /// Check we are connected
  if (client.connectionStatus.state == MqttConnectionState.connected) {
    print('Mosquitto client connected');
  } else {
    /// Use status here rather than state if you also want the broker return code.
    print(
        'Mosquitto client connection failed - disconnecting, status is ${client.connectionStatus}');
    client.disconnect();
    //exit(-1);
  }

  client.updates.listen((List<MqttReceivedMessage<MqttMessage>> c) {
    final MqttPublishMessage message = c[0].payload;
    final payload =
        MqttPublishPayload.bytesToStringAsString(message.payload.message);

    print('Received message:$payload from topic: ${c[0].topic}>');
  });

  return client;
}

// connection succeeded
void onConnected() {
  print('Connected');
}

// unconnected
void onDisconnected() {
  print('Disconnected');
}

// subscribe to topic succeeded
void onSubscribed(String topic) {
  print('Subscribed topic: $topic');
}

// subscribe to topic failed
void onSubscribeFail(String topic) {
  print('Failed to subscribe $topic');
}

// unsubscribe succeeded
void onUnsubscribed(String topic) {
  print('Unsubscribed topic: $topic');
}

// PING response received
void pong() {
  print('Ping response client callback invoked');
}
