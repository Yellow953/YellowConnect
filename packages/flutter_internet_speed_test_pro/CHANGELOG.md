# Changelog

## 1.5.1

* **Dependency Updates**: Updated all dependencies to latest versions
  * `connectivity_plus`: 5.0.2 → 6.1.4 (with API compatibility fixes)
  * `flutter_lints`: 3.0.1 → 6.0.0
  * Updated transitive dependencies for better compatibility
* **Static Analysis**: Fixed all static analysis issues
  * Removed unnecessary imports in example app
  * Updated deprecated method call handlers in tests
  * Fixed super parameter usage
  * Resolved formatting issues
* **Documentation**: Significantly improved API documentation coverage
  * Added comprehensive dartdoc comments to all public API classes
  * Documented all enums, typedefs, and methods
  * Added detailed parameter descriptions and return value documentation
  * Improved library-level documentation
* **Code Quality**: Enhanced overall code quality and maintainability

## 1.5.0 (Fork Version)

* **Fork Information**: This is a fork of the original flutter_internet_speed_test package with support for Android Gradle Plugin (AGP) 8+ and modern Flutter requirements
* Updated dependencies for compatibility with newer Flutter versions
* Bug fixes: https://github.com/redx1t/flutter_internet_speed_test_pro/issues/3
* Code refactor and modernization

## Original Package History

## 0.0.1

* TODO: Describe initial release.

## 1.0.0

* First release to pub.dev

## 1.0.1

* Code refactor

## 1.0.2

* Added internet connectivity check
* Added method to check isTestInProgress
* Made FlutterInternetSpeedTest singleton to run single test at a time
* No tuple dependency

## 1.0.3

* iOS bug fixes

## 1.0.4

* Added debug enable/disable option
* Added duration in callback on completion
* updated plist

## 1.1.0

* Added fast.com and speedtest support
* Added multiple useful callbacks

## 1.2.0

* Bug fixes related to upload test
* Optimized response

## 1.3.0

* Added cancel method and callback to cancel the ongoing test
* Bug fixes: https://github.com/shaz-tech/flutter_internet_speed_test/issues/3
* Updated dependencies

## 1.4.0

* Bug fixes: https://github.com/shaz-tech/flutter_internet_speed_test/issues/4
* Code refactor

## 1.5.0

* Updated dependencies
* Bug fixes: https://github.com/shaz-tech/flutter_internet_speed_test/issues/6, https://github.com/shaz-tech/flutter_internet_speed_test/issues/10