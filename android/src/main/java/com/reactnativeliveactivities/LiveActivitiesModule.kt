package com.reactnativeliveactivities

import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationManagerCompat
import com.facebook.react.bridge.*
import com.facebook.react.module.annotations.ReactModule

@ReactModule(name = LiveActivitiesModule.NAME)
class LiveActivitiesModule(reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {
    
    companion object {
        const val NAME = "LiveActivities"
    }
    
    private val notificationBuilder by lazy { NotificationBuilder(reactApplicationContext) }
    private val activeActivities = mutableMapOf<String, Int>()
    private var serviceBound = false
    
    override fun getName(): String = NAME
    
    @ReactMethod
    fun areActivitiesEnabled(promise: Promise) {
        // On Android, check if notifications are enabled
        val isEnabled = NotificationManagerCompat.from(reactApplicationContext).areNotificationsEnabled()
        promise.resolve(isEnabled)
    }
    
    @ReactMethod
    fun startActivity(
        activityType: String,
        attributes: ReadableMap,
        contentState: ReadableMap,
        staleDate: Double?,
        relevanceScore: Double?,
        promise: Promise
    ) {
        try {
            val activityId = "android-activity-${System.currentTimeMillis()}"
            val notificationId = NotificationBuilder.generateNotificationId()
            
            // Store activity
            activeActivities[activityId] = notificationId
            
            // Convert maps to mutable maps
            val attributesMap = attributes.toHashMap()
            val contentStateMap = contentState.toHashMap()
            
            // Add deep link from attributes to content state for notification
            attributesMap["deepLink"]?.let { contentStateMap["deepLink"] = it }
            
            // Start the delivery tracking service
            val serviceIntent = Intent(reactApplicationContext, DeliveryTrackingService::class.java).apply {
                action = DeliveryTrackingService.ACTION_START_DELIVERY
                putExtra(DeliveryTrackingService.EXTRA_ACTIVITY_ID, activityId)
                putExtra(DeliveryTrackingService.EXTRA_ACTIVITY_TYPE, activityType)
                putExtra(DeliveryTrackingService.EXTRA_ATTRIBUTES, HashMap(attributesMap))
                putExtra(DeliveryTrackingService.EXTRA_CONTENT_STATE, HashMap(contentStateMap))
            }
            
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                reactApplicationContext.startForegroundService(serviceIntent)
            } else {
                reactApplicationContext.startService(serviceIntent)
            }
            
            promise.resolve(activityId)
        } catch (e: Exception) {
            promise.reject("E_START_FAILED", e.message, e)
        }
    }
    
    @ReactMethod
    fun updateActivity(
        activityId: String,
        contentState: ReadableMap,
        alertConfig: ReadableMap?,
        staleDate: Double?,
        promise: Promise
    ) {
        try {
            val notificationId = activeActivities[activityId]
            if (notificationId == null) {
                promise.resolve(null)
                return
            }
            
            val contentStateMap = contentState.toHashMap()
            
            // Send update to service
            val serviceIntent = Intent(reactApplicationContext, DeliveryTrackingService::class.java).apply {
                action = DeliveryTrackingService.ACTION_UPDATE_DELIVERY
                putExtra(DeliveryTrackingService.EXTRA_ACTIVITY_ID, activityId)
                putExtra(DeliveryTrackingService.EXTRA_CONTENT_STATE, HashMap(contentStateMap))
            }
            
            reactApplicationContext.startService(serviceIntent)
            
            promise.resolve(null)
        } catch (e: Exception) {
            promise.reject("E_UPDATE_FAILED", e.message, e)
        }
    }
    
    @ReactMethod
    fun endActivity(
        activityId: String,
        finalContent: ReadableMap?,
        dismissalPolicy: String,
        promise: Promise
    ) {
        try {
            val notificationId = activeActivities.remove(activityId)
            if (notificationId == null) {
                promise.resolve(null)
                return
            }
            
            // Send end to service
            val serviceIntent = Intent(reactApplicationContext, DeliveryTrackingService::class.java).apply {
                action = DeliveryTrackingService.ACTION_END_DELIVERY
                putExtra(DeliveryTrackingService.EXTRA_ACTIVITY_ID, activityId)
                putExtra(DeliveryTrackingService.EXTRA_DISMISSAL_POLICY, dismissalPolicy)
            }
            
            reactApplicationContext.startService(serviceIntent)
            
            promise.resolve(null)
        } catch (e: Exception) {
            promise.reject("E_END_FAILED", e.message, e)
        }
    }
    
    @ReactMethod
    fun getActiveActivities(promise: Promise) {
        val activities = Arguments.createArray()
        activeActivities.keys.forEach { activities.pushString(it) }
        promise.resolve(activities)
    }
    
    @ReactMethod
    fun endAllActivities(promise: Promise) {
        try {
            val serviceIntent = Intent(reactApplicationContext, DeliveryTrackingService::class.java)
            reactApplicationContext.stopService(serviceIntent)
            activeActivities.clear()
            promise.resolve(null)
        } catch (e: Exception) {
            promise.reject("E_END_ALL_FAILED", e.message, e)
        }
    }
    
    @ReactMethod
    fun getPushToken(activityId: String, promise: Promise) {
        // Android uses FCM tokens, not activity-specific tokens
        // Return null as token management is handled separately
        promise.resolve(null)
    }
}
