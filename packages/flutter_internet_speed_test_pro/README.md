A cloned version of the original flutter_internet_speed_test package with support for AGP 8+. The previous version has not been maintained for awhile


<div align="center">

# Flutter Internet Speed Test Pro

[![Flutter](https://img.shields.io/badge/_Flutter_-Plugin-grey.svg?&logo=Flutter&logoColor=white&labelColor=blue)](https://pub.dev/packages/flutter_internet_speed_test_pro)
[![Pub Version](https://img.shields.io/pub/v/flutter_internet_speed_test_pro?color=orange&label=version)](https://pub.dev/packages/flutter_internet_speed_test_pro)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
 
</div>
A Flutter plugin to test internet download and upload speed.

**This is a fork of the original [flutter_internet_speed_test](https://pub.dev/packages/flutter_internet_speed_test) package with support for Android Gradle Plugin (AGP) 8+ and other modern Flutter requirements.**

#### Servers used:

1. Fast.com by Netflix (default)

2. Speed Test by Ookla

## Get started

### Add dependency

```yaml
dependencies:
  flutter_internet_speed_test_pro: ^lastest_version
```

### Screenshots

![Screenshot_20221121-112052~2-1](https://user-images.githubusercontent.com/8435335/202976318-2fe97441-ee8f-4545-bf19-0245491c4c08.jpg)

### Example

```dart

    import 'package:flutter_internet_speed_test_pro/flutter_internet_speed_test_pro.dart';
    
    final speedTest = FlutterInternetSpeedTest();
    speedTest.startTesting(
        useFastApi: true/false //true(default)
        onStarted: () {
          // TODO
        },
        onCompleted: (TestResult download, TestResult upload) {
          // TODO
        },
        onProgress: (double percent, TestResult data) {
          // TODO
        },
        onError: (String errorMessage, String speedTestError) {
          // TODO
        },
        onDefaultServerSelectionInProgress: () {
          // TODO
          //Only when you use useFastApi parameter as true(default)
        },
        onDefaultServerSelectionDone: (Client? client) {
          // TODO
          //Only when you use useFastApi parameter as true(default)
        },
        onDownloadComplete: (TestResult data) {
          // TODO
        },
        onUploadComplete: (TestResult data) {
          // TODO
        },
        onCancel: () {
        // TODO Request cancelled callback
        },
    );

```

### Additional features

You can also configure your test server URL

```dart

  import 'package:flutter_internet_speed_test_pro/flutter_internet_speed_test_pro.dart';

  final speedTest = FlutterInternetSpeedTest();
  speedTest.startTesting(
      useFastApi: true/false //true(default)
      downloadTestServer: //Your download test server URL goes here,
      uploadTestServer: //Your upload test server URL goes here,
      fileSize: //File size to be tested
      onStarted: () {
        // TODO
      },
      onCompleted: (TestResult download, TestResult upload) {
        // TODO
      },
      onProgress: (double percent, TestResult data) {
        // TODO
      },
      onError: (String errorMessage, String speedTestError) {
        // TODO
      },
      onDefaultServerSelectionInProgress: () {
        // TODO
        //Only when you use useFastApi parameter as true(default)
      },
      onDefaultServerSelectionDone: (Client? client) {
        // TODO
        ///Only when you use useFastApi parameter as true(default)
      },
      onDownloadComplete: (TestResult data) {
        // TODO
      },
      onUploadComplete: (TestResult data) {
        // TODO
      },
      onCancel: () {
        // TODO Request cancelled callback
      },
  );

```

If you don't provide a customized server URL we'll be using this URL for downloading as per the
availability

1.https://fast.com/

2.http://speedtest.ftp.otenet.gr/files/test1Mb.db

If you don't provide a customized server URL we'll be using this URL for uploading as per the
availability

1.https://fast.com/

2.http://speedtest.ftp.otenet.gr/

### Platforms

The package is working on both platforms iOS & Android!
