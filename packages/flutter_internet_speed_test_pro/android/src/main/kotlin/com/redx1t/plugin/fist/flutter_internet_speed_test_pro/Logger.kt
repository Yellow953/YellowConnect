package com.redx1t.plugin.fist.flutter_internet_speed_test_pro

class Logger {
    var enabled = false

    fun print(message: String) {
        if (enabled)
            println(message)
    }
}