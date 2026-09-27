import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_internet_speed_test_pro/src/models/server_selection_response.dart';
import 'package:flutter_internet_speed_test_pro/src/speed_test_utils.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:tuple_dart/tuple.dart';

import 'callbacks_enum.dart';
import 'flutter_internet_speed_test_platform_interface.dart';

/// An implementation of [FlutterInternetSpeedTestPlatform] that uses method channels.
class MethodChannelFlutterInternetSpeedTest
    extends FlutterInternetSpeedTestPlatform {
  /// The method channel used to interact with the native platform.
  final _channel = const MethodChannel('com.redx1t.plugin.fist/method');
  final _logger = Logger();

  Future<void> _methodCallHandler(MethodCall call) async {
    if (isLogEnabled) {
      _logger.d('arguments are ${call.arguments}');
//    _logger.d('arguments type is  ${call.arguments['type']}');
      _logger.d('callbacks are $callbacksById');
    }
    switch (call.method) {
      case 'callListener':
        if (call.arguments["id"] as int ==
            CallbacksEnum.startDownLoadTesting.index) {
          if (call.arguments['type'] == ListenerEnum.complete.index) {
            downloadSteps++;
            downloadRate +=
                int.parse((call.arguments['transferRate'] ~/ 1000).toString());
            if (isLogEnabled) {
              _logger.d('download steps is $downloadSteps}');
              _logger.d('download steps is $downloadRate}');
            }
            double average = (downloadRate ~/ downloadSteps).toDouble();
            SpeedUnit unit = SpeedUnit.kbps;
            average /= 1000;
            unit = SpeedUnit.mbps;
            callbacksById[call.arguments["id"]]!.item3(average, unit);
            downloadSteps = 0;
            downloadRate = 0;
            callbacksById.remove(call.arguments["id"]);
          } else if (call.arguments['type'] == ListenerEnum.error.index) {
            if (isLogEnabled) {
              _logger.d('onError : ${call.arguments["speedTestError"]}');
              _logger.d('onError : ${call.arguments["errorMessage"]}');
            }
            callbacksById[call.arguments["id"]]!.item1(
                call.arguments['errorMessage'],
                call.arguments['speedTestError']);
            downloadSteps = 0;
            downloadRate = 0;
            callbacksById.remove(call.arguments["id"]);
          } else if (call.arguments['type'] == ListenerEnum.progress.index) {
            double rate = (call.arguments['transferRate'] ~/ 1000).toDouble();
            if (isLogEnabled) {
              _logger.d('rate is $rate');
            }
            if (rate != 0) downloadSteps++;
            downloadRate += rate.toInt();
            SpeedUnit unit = SpeedUnit.kbps;
            rate /= 1000;
            unit = SpeedUnit.mbps;
            callbacksById[call.arguments["id"]]!
                .item2(call.arguments['percent'].toDouble(), rate, unit);
          } else if (call.arguments['type'] == ListenerEnum.cancel.index) {
            if (isLogEnabled) {
              _logger.d('onCancel : ${call.arguments["id"]}');
            }
            callbacksById[call.arguments["id"]]!.item4();
            downloadSteps = 0;
            downloadRate = 0;
            callbacksById.remove(call.arguments["id"]);
          }
        } else if (call.arguments["id"] as int ==
            CallbacksEnum.startUploadTesting.index) {
          if (call.arguments['type'] == ListenerEnum.complete.index) {
            if (isLogEnabled) {
              _logger.d('onComplete : ${call.arguments['transferRate']}');
            }

            uploadSteps++;
            uploadRate +=
                int.parse((call.arguments['transferRate'] ~/ 1000).toString());
            if (isLogEnabled) {
              _logger.d('download steps is $uploadSteps}');
              _logger.d('download steps is $uploadRate}');
            }
            double average = (uploadRate ~/ uploadSteps).toDouble();
            SpeedUnit unit = SpeedUnit.kbps;
            average /= 1000;
            unit = SpeedUnit.mbps;
            callbacksById[call.arguments["id"]]!.item3(average, unit);
            uploadSteps = 0;
            uploadRate = 0;
            callbacksById.remove(call.arguments["id"]);
          } else if (call.arguments['type'] == ListenerEnum.error.index) {
            if (isLogEnabled) {
              _logger.d('onError : ${call.arguments["speedTestError"]}');
              _logger.d('onError : ${call.arguments["errorMessage"]}');
            }
            callbacksById[call.arguments["id"]]!.item1(
                call.arguments['errorMessage'],
                call.arguments['speedTestError']);
          } else if (call.arguments['type'] == ListenerEnum.progress.index) {
            double rate = (call.arguments['transferRate'] ~/ 1000).toDouble();
            if (isLogEnabled) {
              _logger.d('rate is $rate');
            }
            if (rate != 0) uploadSteps++;
            uploadRate += rate.toInt();
            SpeedUnit unit = SpeedUnit.kbps;
            rate /= 1000.0;
            unit = SpeedUnit.mbps;
            callbacksById[call.arguments["id"]]!
                .item2(call.arguments['percent'].toDouble(), rate, unit);
          } else if (call.arguments['type'] == ListenerEnum.cancel.index) {
            if (isLogEnabled) {
              _logger.d('onCancel : ${call.arguments["id"]}');
            }
            callbacksById[call.arguments["id"]]!.item4();
            downloadSteps = 0;
            downloadRate = 0;
            callbacksById.remove(call.arguments["id"]);
          }
        }
//        callbacksById[call.arguments["id"]](call.arguments["args"]);
        break;
      default:
        if (isLogEnabled) {
          _logger.d(
              'TestFairy: Ignoring invoke from native. This normally shouldn\'t happen.');
        }
    }

    _channel.invokeMethod("cancelListening", call.arguments["id"]);
  }

  Future<CancelListening> _startListening(
      Tuple4<ErrorCallback, ProgressCallback, DoneCallback, CancelCallback>
          callback,
      CallbacksEnum callbacksEnum,
      String testServer,
      {Map<String, dynamic>? args,
      int fileSize = 10000000}) async {
    _channel.setMethodCallHandler(_methodCallHandler);
    int currentListenerId = callbacksEnum.index;
    if (isLogEnabled) {
      _logger.d('test $currentListenerId');
    }
    callbacksById[currentListenerId] = callback;
    await _channel.invokeMethod(
      "startListening",
      {
        'id': currentListenerId,
        'args': args,
        'testServer': testServer,
        'fileSize': fileSize,
      },
    );
    return () {
      _channel.invokeMethod("cancelListening", currentListenerId);
      callbacksById.remove(currentListenerId);
    };
  }

  Future<void> _toggleLog(bool value) async {
    await _channel.invokeMethod(
      "toggleLog",
      {
        'value': value,
      },
    );
  }

  @override

  /// Starts a download speed test using the method channel.
  ///
  /// This method initiates a download test by setting up the method call handler
  /// and invoking the native platform's download testing functionality.
  ///
  /// Parameters:
  /// - [onDone]: Callback when download test completes
  /// - [onProgress]: Callback for progress updates
  /// - [onError]: Callback for error handling
  /// - [onCancel]: Callback when test is cancelled
  /// - [fileSize]: Size of file to download for testing
  /// - [testServer]: URL of the test server
  ///
  /// Returns a [Future<CancelListening>] that provides a function to cancel the test.
  Future<CancelListening> startDownloadTesting(
      {required DoneCallback onDone,
      required ProgressCallback onProgress,
      required ErrorCallback onError,
      required CancelCallback onCancel,
      required fileSize,
      required String testServer}) async {
    return await _startListening(Tuple4(onError, onProgress, onDone, onCancel),
        CallbacksEnum.startDownLoadTesting, testServer,
        fileSize: fileSize);
  }

  @override

  /// Starts an upload speed test using the method channel.
  ///
  /// This method initiates an upload test by setting up the method call handler
  /// and invoking the native platform's upload testing functionality.
  ///
  /// Parameters:
  /// - [onDone]: Callback when upload test completes
  /// - [onProgress]: Callback for progress updates
  /// - [onError]: Callback for error handling
  /// - [onCancel]: Callback when test is cancelled
  /// - [fileSize]: Size of file to upload for testing
  /// - [testServer]: URL of the test server
  ///
  /// Returns a [Future<CancelListening>] that provides a function to cancel the test.
  Future<CancelListening> startUploadTesting(
      {required DoneCallback onDone,
      required ProgressCallback onProgress,
      required ErrorCallback onError,
      required CancelCallback onCancel,
      required int fileSize,
      required String testServer}) async {
    return await _startListening(Tuple4(onError, onProgress, onDone, onCancel),
        CallbacksEnum.startUploadTesting, testServer,
        fileSize: fileSize);
  }

  @override

  /// Toggles logging on or off for the method channel implementation.
  ///
  /// Parameters:
  /// - [value]: Whether to enable or disable logging
  Future<void> toggleLog({required bool value}) async {
    logEnabled = value;
    await _toggleLog(logEnabled);
  }

  @override

  /// Gets the default server for speed testing from Fast.com API.
  ///
  /// This method fetches server information from Fast.com's API to provide
  /// optimal test servers for speed testing.
  ///
  /// Returns a [Future<ServerSelectionResponse?>] containing server information,
  /// or `null` if the request fails or no servers are available.
  Future<ServerSelectionResponse?> getDefaultServer() async {
    try {
      if (await isInternetAvailable()) {
        const tag = 'token:"';
        var tokenUrl = Uri.parse('https://fast.com/app-a32983.js');
        var tokenResponse = await http.get(tokenUrl);
        if (tokenResponse.body.contains(tag)) {
          int start = tokenResponse.body.lastIndexOf(tag) + tag.length;
          String token = tokenResponse.body.substring(start, start + 32);
          var serverUrl = Uri.parse(
              'https://api.fast.com/netflix/speedtest/v2?https=true&token=$token&urlCount=5');
          var serverResponse = await http.get(serverUrl);
          var serverSelectionResponse = ServerSelectionResponse.fromJson(
              json.decode(serverResponse.body));
          if (serverSelectionResponse.targets?.isNotEmpty == true) {
            return serverSelectionResponse;
          }
        }
      }
    } catch (e) {
      if (logEnabled) {
        _logger.d(e);
      }
    }
    return null;
  }

  @override

  /// Cancels the currently running test using the method channel.
  ///
  /// This method invokes the native platform's cancel functionality to stop
  /// any ongoing download or upload tests.
  ///
  /// Returns a [Future<bool>] that completes with `true` if the test
  /// was successfully cancelled, `false` otherwise.
  Future<bool> cancelTest() async {
    var result = false;
    try {
      result = await _channel.invokeMethod("cancelTest", {
        'id1': CallbacksEnum.startDownLoadTesting.index,
        'id2': CallbacksEnum.startUploadTesting.index,
      });
    } on PlatformException {
      result = false;
    }
    return result;
  }
}
