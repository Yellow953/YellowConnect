package com.yellowtech.yellowconnect

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.RemoteViews

/**
 * Home screen widget with two buttons, Connect and Speed test. Each opens the
 * app with a `yellowconnect://widget/<path>` link that MainActivity hands to Dart.
 */
class QuickActionsWidget : AppWidgetProvider() {
    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) {
        val views = RemoteViews(context.packageName, R.layout.widget_quick_actions).apply {
            setOnClickPendingIntent(R.id.widget_connect, launch(context, "vpn-connect", 1))
            setOnClickPendingIntent(R.id.widget_speed_test, launch(context, "speed-test", 2))
        }
        manager.updateAppWidget(ids, views)
    }

    private fun launch(context: Context, path: String, requestCode: Int): PendingIntent {
        val intent = Intent(
            Intent.ACTION_VIEW,
            Uri.parse("${MainActivity.SCHEME}://widget/$path"),
            context,
            MainActivity::class.java,
        ).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
        return PendingIntent.getActivity(
            context,
            requestCode,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }
}
