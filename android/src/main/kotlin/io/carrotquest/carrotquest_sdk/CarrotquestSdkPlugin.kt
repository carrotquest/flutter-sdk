package io.carrotquest.carrotquest_sdk

import android.app.Activity
import android.content.Context
import android.graphics.drawable.Drawable
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.annotation.NonNull
import io.carrotquest_sdk.android.Carrot
import io.carrotquest_sdk.android.Carrot.Callback
import io.carrotquest_sdk.android.models.EventParams
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import org.json.JSONObject
import java.lang.Exception

/** CarrotquestSdkPlugin */
class CarrotquestSdkPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private var context: Context? = null
    private var activity: Activity? = null

    private var appId: String? = null
    private var apiKey: String? = null

    private val mainHandler = Handler(Looper.getMainLooper())

    @Volatile private var isLoggingOut = false


    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "carrotquest_sdk")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {
        if (call.method == "setup") {
            if (Carrot.isInit()) {
                result.error("Plugin is already initialized.", null, null)
                return
            }

            setup(call, result)
            return
        }

        if(call.method == "auth") {
            auth(call, result)
            return
        }

        if(call.method == "logOut") {
            logOut(call, result)
            return
        }

        if (call.method == "sendToken") {
            sendToken(call, result)
            return
        }

        if (call.method == "sendFirebasePushNotification") {
            sendFirebasePushNotification(call, result)
            return
        }

        if (call.method == "openChat") {
            openChat(call, result)
            return
        }

        if(call.method == "setUserProperty") {
            setUserProperty(call, result)
            return
        }

        if(call.method == "trackEvent") {
            trackEvent(call, result)
            return
        }

        if(call.method == "getUnreadConversationsCount") {
            getUnreadConversationsCount(call, result)
            return
        }

        if (call.method == "getPlatformVersion") {
            result.success("Android ${android.os.Build.VERSION.RELEASE}")
            return
        }

        if(call.method == "pushNotificationsUnsubscribe") {
            pushNotificationsUnsubscribe(result)
            return
        }

        if(call.method == "pushCampaignsUnsubscribe") {
            pushCampaignsUnsubscribe(result)
            return
        }

        if (call.method == "isInit") {
            isInit(result);
            return;
        }

        if (call.method == "trackScreen") {
            trackScreen(call, result);
            return;
        }

        if (call.method == "trackUtm") {
            trackUtm(call, result);
            return;
        }

        result.notImplemented()
    }

    // override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    //   channel.setMethodCallHandler(null)
    // }

    private fun checkPluginInitiated(@NonNull result: MethodChannel.Result): Boolean {
        if (!Carrot.isInit()) {
            result.error(
                "The plugin hasn't been initialized yet. Do Carrot.io.carrotquest.carrotquest_sdk.setup(...) first .",
                null,
                null
            )
            return false
        }
        return true
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        context = null
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
    }

    //=====
    private fun setup(
        @NonNull call: MethodCall,
        @NonNull result: MethodChannel.Result,
    ) {
        apiKey = call.argument<String?>("api_key")
        if (apiKey == null) {
            result.error("An error has occurred, the apiKey is null.", null, null)
            return
        }

        val con = activity ?: context
        if (con != null) {
            try {
                Carrot.setup(con, apiKey!!, object : Carrot.Callback<Boolean> {
                    override fun onResponse(r: Boolean?) {
                        val res = r ?: false
                        if (res) {
                            configureAfterSetup(con)
                            result.success("true")
                        } else {
                            result.success("false")
                        }
                    }

                    override fun onFailure(t: Throwable?) {
                         result.success("false")
                    }
                })
                
                
            } catch(e: java.lang.Exception) {
                result.success("false")
            }
        } else {
            result.success("false")
        }
    }

    private fun configureAfterSetup(con: Context) {
        try {
            val iconId = con.resources.getIdentifier("ic_cqsdk_notification", "drawable", con.packageName)
            if (iconId == 0) {
                Carrot.setNotificationIcon(R.drawable.ic_cqsdk_def_notification)
            } else {
                Carrot.setNotificationIcon(iconId)
            }

            Carrot.setUnreadConversationsCallback(object : Callback<List<String>> {
                override fun onResponse(unreadConversationsIds: List<String>?) {
                    val count = unreadConversationsIds?.size ?: 0
                    mainHandler.post {
                        channel.invokeMethod("unreadConversationsCount", count)
                    }
                }

                override fun onFailure(t: Throwable?) {
                }
            })
        } catch (e: java.lang.Exception) {
            println("$e")
        }
    }

    private fun auth(@NonNull call: MethodCall,
        @NonNull result: MethodChannel.Result) {
        if (!checkPluginInitiated(result)) {
            return
        }

        val userId = call.argument<String?>("user_id")
        val userAuthKey = call.argument<String?>("user_auth_key")
        val userHash = call.argument<String?>("user_hash")
        if (userId == null || (userAuthKey == null && userHash == null)) {
            result.error("An error has occurred, the userId or userAuthKey/userHash is null.", null, null)
            return
        }


        if (userHash !== null) {
            Carrot.hashedAuth(userId, userHash, object : Callback<String> {
                override fun onResponse(resultAuth: String?) {
                    if(resultAuth != null) {
                        result.success(resultAuth)
                    } else {
                        result.error("Auth is failed", null, null)
                    }
                }

                override fun onFailure(t: Throwable?) {
                    result.error("Auth is failed: " + t.toString(), null, null)
                }
            })
            return
        }

         Carrot.auth(userId, userAuthKey, object : Callback<String> {
            override fun onResponse(resultAuth: String?) {
                if(resultAuth != null) {
                    result.success(resultAuth)
                } else {
                    result.error("Auth is failed", null, null)
                }
            }
            override fun onFailure(t: Throwable?) {
                result.error("Auth is failed: " + t.toString(), null, null)
            }
        })
    }

    private fun logOut(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {
        if (!checkPluginInitiated(result)) {
            return
        }

        if (apiKey == null) {
            result.error("An error has occurred, the apiKey is null.", null, null)
            return
        }

        if (isLoggingOut) {
            result.success(null)
            return
        }
        isLoggingOut = true

        Carrot.deInit(object : Callback<Boolean>{
            override fun onResponse(resDeInit: Boolean) {
                if(!resDeInit) {
                    isLoggingOut = false
                    result.error("deInit is failed", null, null)
                    return
                }

                val con = context
                if (con != null) {
                    Carrot.setup(con, apiKey!!, object : Callback<Boolean> {
                        override fun onResponse(resultSetup: Boolean?) {
                            isLoggingOut = false
                            try {
                                if(resultSetup == true) {
                                    configureAfterSetup(con)
                                    result.success(null)
                                } else {
                                    result.error("Setup is failed", null, null)
                                }
                            } catch (e: java.lang.Exception) {
                            }
                        }

                        override fun onFailure(t: Throwable?) {
                            isLoggingOut = false
                            result.error("Setup is failed: " + t.toString(), null, null)
                        }
                    })
                } else {
                    isLoggingOut = false
                    result.error("Context is null", null, null)
                }
            }

            override fun onFailure(t: Throwable) {
                isLoggingOut = false
                result.error(t.localizedMessage, null, null)
            }
        })
    }

    private fun sendToken(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {
        val token = call.argument<String?>("token")
        Carrot.sendPushToken(token)

        result.success(null)
    }

    private fun sendFirebasePushNotification(
        @NonNull call: MethodCall,
        @NonNull result: MethodChannel.Result
    ) {
        val data: Map<String, Any> =
            call.argument<Map<String, Any>>("data") ?: HashMap<String, Any>()

        val pushData = data.entries.associate { it.key to (it.value?.toString() ?: "") }
        Carrot.sendPushNotification(pushData, if(activity == null) context else activity)

        result.success(null)
    }


    private fun openChat(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {
        if (!checkPluginInitiated(result)) {
            return
        }
        try {
            if (activity != null) {
                Carrot.openChat(activity)
                result.success(null)
            } else {
                result.error("Activity in null", null, null)
            }
        } catch (e: Exception) {
            result.error(e.localizedMessage, null, null)
        }
    }

    private fun setUserProperty(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {
        if (!checkPluginInitiated(result)) {
            return
        }
        try {
            val key = call.argument<String?>("key")
            val value = call.argument<String?>("value")
            if(key == null || value == null) {
                result.error("Key or value is empty", null, null)
                return
            }

            Carrot.setUserProperty(key, value.toString())
            result.success(null)
        } catch (e: Exception) {
            result.error(e.localizedMessage, null, null)
        }
    }

    private fun trackEvent(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {
        if (!checkPluginInitiated(result)) {
            return
        }
        try {
            val event = call.argument<String?>("event")
            if(event == null) {
                result.error("Event is empty", null, null)
                return
            }

            val paramsStr = call.argument<String?>("params")
            if(paramsStr == null || paramsStr.isEmpty()) {
                Carrot.trackEvent(event)
                result.success(null)
            } else {
                val json = JSONObject(paramsStr)
                val builder = EventParams.builder()
                for (key in json.keys()) {
                    when (val value = json.get(key)) {
                        is Boolean -> builder.put(key, value)
                        is Int -> builder.put(key, value)
                        is Long -> builder.put(key, value)
                        is Double -> builder.put(key, value)
                        else -> builder.put(key, value.toString())
                    }
                }
                Carrot.trackEvent(event, builder.build())
                result.success(null)
            }

        } catch (e: Exception) {
            result.error(e.localizedMessage, null, null)
        }
    }

    private fun getUnreadConversationsCount(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {
        if (!checkPluginInitiated(result)) {
            return
        }
        try {
            val count =  Carrot.getUnreadConversations().size
            result.success(count)
        } catch (e: Exception) {
            result.success(0)
        }
    }

    private fun pushNotificationsUnsubscribe(@NonNull result: MethodChannel.Result) {
        try {
            Carrot.pushNotificationsUnsubscribe()
            result.success(null)
        } catch (e: Exception) {
            result.error(e.localizedMessage, null, null)
        }
    }

    private fun pushCampaignsUnsubscribe(@NonNull result: MethodChannel.Result) {
        try {
            Carrot.pushCampaignsUnsubscribe()
            result.success(null)
        } catch (e: Exception) {
            result.error(e.localizedMessage, null, null)
        }
    }

    private fun isInit(@NonNull result: MethodChannel.Result) {
        try {
            val isInit = Carrot.isInit()
            result.success(isInit)
        } catch (e: Exception) {
            result.error(e.localizedMessage, null, null)
        }
    }

    private fun trackScreen(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {
        if (!checkPluginInitiated(result)) {
            return
        }
        try {
            val screen = call.argument<String?>("screen")
            if(screen == null) {
                result.error("Screen is empty", null, null)
                return
            }

            Carrot.trackScreen(screen)
        } catch (e: Exception) {
            result.error(e.localizedMessage, null, null)
        }
    }

    // Note: unlike trackEvent/trackScreen, trackUtm is intentionally NOT gated
    // behind an initialization check. It is designed to be called when the app
    // is opened via a deeplink, which may happen before Carrot.setup() finishes;
    // the native SDK handles tracking the UTM tags once it is initialized.
    private fun trackUtm(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {
        try {
            val url = call.argument<String?>("url")
            if (url == null) {
                result.error("Url is empty", null, null)
                return
            }

            Carrot.trackUtm(url)
            result.success(null)
        } catch (e: Exception) {
            result.error(e.localizedMessage, null, null)
        }
    }
}