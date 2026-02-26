package com.reactnativeliveactivities

import android.app.Notification
import android.app.Service
import android.content.Intent
import android.os.Binder
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationManagerCompat
import kotlinx.coroutines.*
import java.util.concurrent.ConcurrentHashMap

/**
 * Foreground service for managing delivery tracking notifications
 */
class DeliveryTrackingService : Service() {
    
    private val binder = LocalBinder()
    private val scope = CoroutineScope(Dispatchers.Default + SupervisorJob())
    private val notificationBuilder by lazy { NotificationBuilder(this) }
    
    // Store active deliveries
    private val activeDeliveries = ConcurrentHashMap<String, DeliveryInfo>()
    
    data class DeliveryInfo(
        val id: String,
        val type: String,
        val notificationId: Int,
        val data: Map<String, Any?>
    )
    
    inner class LocalBinder : Binder() {
        fun getService(): DeliveryTrackingService = this@DeliveryTrackingService
    }
    
    override fun onBind(intent: Intent?): IBinder = binder
    
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_START_DELIVERY -> handleStartDelivery(intent)
            ACTION_UPDATE_DELIVERY -> handleUpdateDelivery(intent)
            ACTION_END_DELIVERY -> handleEndDelivery(intent)
        }
        return START_STICKY
    }
    
    override fun onDestroy() {
        super.onDestroy()
        scope.cancel()
    }
    
    // MARK: - Public Methods
    
    /**
     * Start a new delivery tracking
     */
    fun startDelivery(
        activityId: String,
        activityType: String,
        attributes: Map<String, Any?>,
        contentState: Map<String, Any?>
    ): Int {
        val notificationId = NotificationBuilder.generateNotificationId()
        
        val deliveryInfo = DeliveryInfo(
            id = activityId,
            type = activityType,
            notificationId = notificationId,
            data = contentState
        )
        
        activeDeliveries[activityId] = deliveryInfo
        
        scope.launch {
            val notification = buildNotificationForType(activityType, contentState, notificationId)
            notification?.let {
                if (activeDeliveries.size == 1) {
                    // First delivery - start as foreground service
                    startForeground(notificationId, it)
                } else {
                    // Additional delivery - just notify
                    NotificationManagerCompat.from(this@DeliveryTrackingService)
                        .notify(notificationId, it)
                }
            }
        }
        
        return notificationId
    }
    
    /**
     * Update an existing delivery
     */
    fun updateDelivery(
        activityId: String,
        contentState: Map<String, Any?>
    ) {
        val deliveryInfo = activeDeliveries[activityId] ?: return
        
        val updatedInfo = deliveryInfo.copy(data = contentState)
        activeDeliveries[activityId] = updatedInfo
        
        scope.launch {
            val notification = buildNotificationForType(
                deliveryInfo.type,
                contentState,
                deliveryInfo.notificationId
            )
            
            notification?.let {
                NotificationManagerCompat.from(this@DeliveryTrackingService)
                    .notify(deliveryInfo.notificationId, it)
            }
        }
    }
    
    /**
     * End a delivery tracking
     */
    fun endDelivery(activityId: String, dismissalPolicy: String) {
        val deliveryInfo = activeDeliveries.remove(activityId) ?: return
        
        when (dismissalPolicy) {
            "immediate" -> {
                NotificationManagerCompat.from(this)
                    .cancel(deliveryInfo.notificationId)
            }
            else -> {
                // Show final notification briefly then dismiss
                scope.launch {
                    delay(5000) // Show for 5 seconds
                    NotificationManagerCompat.from(this@DeliveryTrackingService)
                        .cancel(deliveryInfo.notificationId)
                }
            }
        }
        
        // If no more deliveries, stop foreground
        if (activeDeliveries.isEmpty()) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                stopForeground(STOP_FOREGROUND_REMOVE)
            } else {
                @Suppress("DEPRECATION")
                stopForeground(true)
            }
        }
    }
    
    /**
     * Get all active delivery IDs
     */
    fun getActiveDeliveries(): List<String> {
        return activeDeliveries.keys.toList()
    }
    
    /**
     * End all deliveries
     */
    fun endAllDeliveries() {
        activeDeliveries.keys.toList().forEach { activityId ->
            endDelivery(activityId, "immediate")
        }
    }
    
    // MARK: - Private Methods
    
    private fun handleStartDelivery(intent: Intent) {
        val activityId = intent.getStringExtra(EXTRA_ACTIVITY_ID) ?: return
        val activityType = intent.getStringExtra(EXTRA_ACTIVITY_TYPE) ?: return
        @Suppress("UNCHECKED_CAST")
        val attributes = intent.getSerializableExtra(EXTRA_ATTRIBUTES) as? Map<String, Any?> ?: emptyMap()
        @Suppress("UNCHECKED_CAST")
        val contentState = intent.getSerializableExtra(EXTRA_CONTENT_STATE) as? Map<String, Any?> ?: emptyMap()
        
        startDelivery(activityId, activityType, attributes, contentState)
    }
    
    private fun handleUpdateDelivery(intent: Intent) {
        val activityId = intent.getStringExtra(EXTRA_ACTIVITY_ID) ?: return
        @Suppress("UNCHECKED_CAST")
        val contentState = intent.getSerializableExtra(EXTRA_CONTENT_STATE) as? Map<String, Any?> ?: emptyMap()
        
        updateDelivery(activityId, contentState)
    }
    
    private fun handleEndDelivery(intent: Intent) {
        val activityId = intent.getStringExtra(EXTRA_ACTIVITY_ID) ?: return
        val dismissalPolicy = intent.getStringExtra(EXTRA_DISMISSAL_POLICY) ?: "default"
        
        endDelivery(activityId, dismissalPolicy)
    }
    
    private suspend fun buildNotificationForType(
        type: String,
        data: Map<String, Any?>,
        notificationId: Int
    ): Notification? {
        return when (type) {
            "QuickCommerce", "QuickCommerceAttributes" -> {
                val delivery = parseQuickCommerce(data)
                notificationBuilder.buildQuickCommerceNotification(delivery, notificationId)
            }
            "FoodDelivery", "FoodDeliveryAttributes" -> {
                val delivery = parseFoodDelivery(data)
                notificationBuilder.buildFoodDeliveryNotification(delivery, notificationId)
            }
            "EcommerceDelivery", "EcommerceDeliveryAttributes" -> {
                val delivery = parseEcommerceDelivery(data)
                notificationBuilder.buildEcommerceNotification(delivery, notificationId)
            }
            else -> {
                val title = data["title"] as? String ?: "Delivery"
                val status = data["status"] as? String ?: "In Progress"
                val progress = (data["progress"] as? Double) ?: 0.0
                val deepLink = data["deepLink"] as? String
                
                notificationBuilder.buildGenericNotification(
                    title, status, progress, notificationId, deepLink
                )
            }
        }
    }
    
    // MARK: - Parsing Helpers
    
    private fun parseQuickCommerce(data: Map<String, Any?>): QuickCommerceDelivery {
        return QuickCommerceDelivery(
            orderId = data["orderId"] as? String ?: "",
            items = data["items"] as? String,
            status = data["status"] as? String ?: "confirmed",
            progress = (data["progress"] as? Double) ?: 0.0,
            estimatedMinutes = (data["estimatedMinutes"] as? Int) ?: 10,
            riderName = data["riderName"] as? String,
            riderPhone = data["riderPhone"] as? String,
            riderPhoto = data["riderPhoto"] as? String,
            currentLocation = data["currentLocation"] as? String,
            storeName = data["storeName"] as? String,
            deepLink = data["deepLink"] as? String
        )
    }
    
    private fun parseFoodDelivery(data: Map<String, Any?>): FoodDeliveryModel {
        return FoodDeliveryModel(
            orderId = data["orderId"] as? String ?: "",
            restaurantName = data["restaurantName"] as? String ?: "",
            restaurantLogo = data["restaurantLogo"] as? String,
            orderItems = data["orderItems"] as? String,
            status = data["status"] as? String ?: "confirmed",
            statusStage = (data["statusStage"] as? Int) ?: 0,
            estimatedMinutes = (data["estimatedMinutes"] as? Int) ?: 30,
            riderName = data["riderName"] as? String,
            riderPhone = data["riderPhone"] as? String,
            riderPhoto = data["riderPhoto"] as? String,
            currentLocation = data["currentLocation"] as? String,
            deliveryAddress = data["deliveryAddress"] as? String,
            deepLink = data["deepLink"] as? String
        )
    }
    
    private fun parseEcommerceDelivery(data: Map<String, Any?>): EcommerceDeliveryModel {
        return EcommerceDeliveryModel(
            orderId = data["orderId"] as? String ?: "",
            productName = data["productName"] as? String ?: "",
            productImage = data["productImage"] as? String,
            status = data["status"] as? String ?: "ordered",
            statusStage = (data["statusStage"] as? Int) ?: 0,
            courierPartner = data["courierPartner"] as? String,
            trackingNumber = data["trackingNumber"] as? String,
            currentHub = data["currentHub"] as? String,
            estimatedDeliveryDate = (data["estimatedDeliveryDate"] as? Long),
            deliveryAttempts = (data["deliveryAttempts"] as? Int) ?: 0,
            rescheduleAvailable = (data["rescheduleAvailable"] as? Boolean) ?: false,
            trackingUrl = data["trackingUrl"] as? String,
            deepLink = data["deepLink"] as? String
        )
    }
    
    companion object {
        const val ACTION_START_DELIVERY = "com.reactnativeliveactivities.START_DELIVERY"
        const val ACTION_UPDATE_DELIVERY = "com.reactnativeliveactivities.UPDATE_DELIVERY"
        const val ACTION_END_DELIVERY = "com.reactnativeliveactivities.END_DELIVERY"
        
        const val EXTRA_ACTIVITY_ID = "activityId"
        const val EXTRA_ACTIVITY_TYPE = "activityType"
        const val EXTRA_ATTRIBUTES = "attributes"
        const val EXTRA_CONTENT_STATE = "contentState"
        const val EXTRA_DISMISSAL_POLICY = "dismissalPolicy"
    }
}
