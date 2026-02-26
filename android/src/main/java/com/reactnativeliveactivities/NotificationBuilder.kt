package com.reactnativeliveactivities

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.Color
import android.os.Build
import android.widget.RemoteViews
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.graphics.drawable.IconCompat
import com.bumptech.glide.Glide
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

// Data models for delivery notifications
data class QuickCommerceDelivery(
    val orderId: String,
    val items: String? = null,
    val status: String,
    val progress: Double,
    val estimatedMinutes: Int,
    val riderName: String? = null,
    val riderPhone: String? = null,
    val riderPhoto: String? = null,
    val currentLocation: String? = null,
    val storeName: String? = null,
    val deepLink: String? = null
)

data class FoodDeliveryModel(
    val orderId: String,
    val restaurantName: String,
    val restaurantLogo: String? = null,
    val orderItems: String? = null,
    val status: String,
    val statusStage: Int,
    val estimatedMinutes: Int,
    val riderName: String? = null,
    val riderPhone: String? = null,
    val riderPhoto: String? = null,
    val currentLocation: String? = null,
    val deliveryAddress: String? = null,
    val deepLink: String? = null
)

data class EcommerceDeliveryModel(
    val orderId: String,
    val productName: String,
    val productImage: String? = null,
    val status: String,
    val statusStage: Int,
    val courierPartner: String? = null,
    val trackingNumber: String? = null,
    val currentHub: String? = null,
    val estimatedDeliveryDate: Long? = null,
    val deliveryAttempts: Int = 0,
    val rescheduleAvailable: Boolean = false,
    val trackingUrl: String? = null,
    val deepLink: String? = null
)

/**
 * Builder class for creating delivery tracking notifications
 */
class NotificationBuilder(private val context: Context) {
    
    companion object {
        const val CHANNEL_ID_DELIVERY = "delivery_tracking"
        const val CHANNEL_ID_QUICK_COMMERCE = "quick_commerce"
        const val CHANNEL_ID_FOOD_DELIVERY = "food_delivery"
        const val CHANNEL_ID_ECOMMERCE = "ecommerce_delivery"
        
        const val ACTION_UPDATE = "com.reactnativeliveactivities.UPDATE"
        const val ACTION_CANCEL = "com.reactnativeliveactivities.CANCEL"
        const val ACTION_TAP = "com.reactnativeliveactivities.TAP"
        
        private var notificationIdCounter = 1000
        
        fun generateNotificationId(): Int {
            return notificationIdCounter++
        }
    }
    
    private val notificationManager = NotificationManagerCompat.from(context)
    
    init {
        createNotificationChannels()
    }
    
    /**
     * Create notification channels for different delivery types
     */
    private fun createNotificationChannels() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channels = listOf(
                NotificationChannel(
                    CHANNEL_ID_DELIVERY,
                    "Delivery Tracking",
                    NotificationManager.IMPORTANCE_LOW
                ).apply {
                    description = "Track your deliveries in real-time"
                    setShowBadge(true)
                },
                NotificationChannel(
                    CHANNEL_ID_QUICK_COMMERCE,
                    "Quick Commerce",
                    NotificationManager.IMPORTANCE_HIGH
                ).apply {
                    description = "Quick delivery updates (Zepto-style)"
                    setShowBadge(true)
                    enableLights(true)
                    lightColor = Color.parseColor("#4CAF50")
                },
                NotificationChannel(
                    CHANNEL_ID_FOOD_DELIVERY,
                    "Food Delivery",
                    NotificationManager.IMPORTANCE_HIGH
                ).apply {
                    description = "Food delivery tracking (Swiggy/Zomato-style)"
                    setShowBadge(true)
                    enableLights(true)
                    lightColor = Color.parseColor("#FF9800")
                },
                NotificationChannel(
                    CHANNEL_ID_ECOMMERCE,
                    "E-commerce Delivery",
                    NotificationManager.IMPORTANCE_DEFAULT
                ).apply {
                    description = "Package tracking (Flipkart/Amazon-style)"
                    setShowBadge(true)
                }
            )
            
            val systemManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            channels.forEach { systemManager.createNotificationChannel(it) }
        }
    }
    
    /**
     * Build notification for Quick Commerce delivery (Zepto-style)
     */
    suspend fun buildQuickCommerceNotification(
        delivery: QuickCommerceDelivery,
        notificationId: Int
    ): Notification {
        val channelId = CHANNEL_ID_QUICK_COMMERCE
        
        // Create custom layout
        val contentView = RemoteViews(context.packageName, R.layout.notification_quick_commerce)
        
        // Set basic info
        contentView.setTextViewText(R.id.tvOrderId, delivery.orderId)
        contentView.setTextViewText(R.id.tvStatus, formatStatus(delivery.status))
        contentView.setTextViewText(R.id.tvEta, "${delivery.estimatedMinutes} min")
        contentView.setTextViewText(R.id.tvProgress, "${delivery.progress.toInt()}%")
        
        // Set progress bar
        contentView.setProgressBar(R.id.progressBar, 100, delivery.progress.toInt(), false)
        
        // Set rider info if available
        delivery.riderName?.let { name ->
            contentView.setTextViewText(R.id.tvRiderName, name)
            contentView.setViewVisibility(R.id.riderInfo, android.view.View.VISIBLE)
        }
        
        delivery.currentLocation?.let { location ->
            contentView.setTextViewText(R.id.tvLocation, location)
        }
        
        // Load images asynchronously
        delivery.riderPhoto?.let { photoUrl ->
            loadImageIntoRemoteViews(contentView, R.id.ivRiderPhoto, photoUrl)
        }
        
        // Create intent for tap action
        val tapIntent = delivery.deepLink?.let { deepLink ->
            Intent(Intent.ACTION_VIEW, android.net.Uri.parse(deepLink))
        } ?: Intent(context, context.javaClass)
        
        val tapPendingIntent = PendingIntent.getActivity(
            context,
            notificationId,
            tapIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        return NotificationCompat.Builder(context, channelId)
            .setSmallIcon(android.R.drawable.ic_menu_send)
            .setCustomContentView(contentView)
            .setCustomBigContentView(contentView)
            .setContentIntent(tapPendingIntent)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setCategory(NotificationCompat.CATEGORY_PROGRESS)
            .setForegroundServiceBehavior(NotificationCompat.FOREGROUND_SERVICE_IMMEDIATE)
            .build()
    }
    
    /**
     * Build notification for Food Delivery (Swiggy/Zomato-style)
     */
    suspend fun buildFoodDeliveryNotification(
        delivery: FoodDeliveryModel,
        notificationId: Int
    ): Notification {
        val channelId = CHANNEL_ID_FOOD_DELIVERY
        
        val contentView = RemoteViews(context.packageName, R.layout.notification_food_delivery)
        
        // Set restaurant info
        contentView.setTextViewText(R.id.tvRestaurantName, delivery.restaurantName)
        contentView.setTextViewText(R.id.tvOrderId, delivery.orderId)
        contentView.setTextViewText(R.id.tvStatus, formatStatus(delivery.status))
        contentView.setTextViewText(R.id.tvEta, "${delivery.estimatedMinutes} min")
        
        // Set stage indicators
        setStageIndicators(contentView, delivery.statusStage)
        
        // Set order items
        delivery.orderItems?.let { items ->
            contentView.setTextViewText(R.id.tvOrderItems, items)
        }
        
        // Set rider info
        if (delivery.statusStage >= 2) {
            delivery.riderName?.let { name ->
                contentView.setTextViewText(R.id.tvRiderName, name)
                contentView.setViewVisibility(R.id.riderInfo, android.view.View.VISIBLE)
            }
            
            delivery.currentLocation?.let { location ->
                contentView.setTextViewText(R.id.tvLocation, location)
            }
            
            delivery.riderPhoto?.let { photoUrl ->
                loadImageIntoRemoteViews(contentView, R.id.ivRiderPhoto, photoUrl)
            }
        }
        
        // Load restaurant logo
        delivery.restaurantLogo?.let { logoUrl ->
            loadImageIntoRemoteViews(contentView, R.id.ivRestaurantLogo, logoUrl)
        }
        
        val tapIntent = delivery.deepLink?.let { deepLink ->
            Intent(Intent.ACTION_VIEW, android.net.Uri.parse(deepLink))
        } ?: Intent(context, context.javaClass)
        
        val tapPendingIntent = PendingIntent.getActivity(
            context,
            notificationId,
            tapIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        return NotificationCompat.Builder(context, channelId)
            .setSmallIcon(android.R.drawable.ic_menu_send)
            .setCustomContentView(contentView)
            .setCustomBigContentView(contentView)
            .setContentIntent(tapPendingIntent)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setCategory(NotificationCompat.CATEGORY_PROGRESS)
            .build()
    }
    
    /**
     * Build notification for E-commerce Delivery (Flipkart/Amazon-style)
     */
    suspend fun buildEcommerceNotification(
        delivery: EcommerceDeliveryModel,
        notificationId: Int
    ): Notification {
        val channelId = CHANNEL_ID_ECOMMERCE
        
        val contentView = RemoteViews(context.packageName, R.layout.notification_ecommerce)
        
        // Set product info
        contentView.setTextViewText(R.id.tvProductName, delivery.productName)
        contentView.setTextViewText(R.id.tvOrderId, delivery.orderId)
        contentView.setTextViewText(R.id.tvStatus, formatStatus(delivery.status))
        
        // Set stage indicators
        setEcommerceStageIndicators(contentView, delivery.statusStage)
        
        // Set courier info
        delivery.courierPartner?.let { courier ->
            contentView.setTextViewText(R.id.tvCourier, courier)
        }
        
        delivery.trackingNumber?.let { tracking ->
            contentView.setTextViewText(R.id.tvTrackingNumber, "AWB: $tracking")
        }
        
        delivery.currentHub?.let { hub ->
            contentView.setTextViewText(R.id.tvCurrentHub, "At: $hub")
        }
        
        // Set delivery date
        delivery.estimatedDeliveryDate?.let { date ->
            val sdf = SimpleDateFormat("MMM dd", Locale.getDefault())
            contentView.setTextViewText(R.id.tvEstimatedDate, "By ${sdf.format(Date(date))}")
        }
        
        // Load product image
        delivery.productImage?.let { imageUrl ->
            loadImageIntoRemoteViews(contentView, R.id.ivProductImage, imageUrl)
        }
        
        val tapIntent = delivery.deepLink?.let { deepLink ->
            Intent(Intent.ACTION_VIEW, android.net.Uri.parse(deepLink))
        } ?: Intent(context, context.javaClass)
        
        val tapPendingIntent = PendingIntent.getActivity(
            context,
            notificationId,
            tapIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        return NotificationCompat.Builder(context, channelId)
            .setSmallIcon(android.R.drawable.ic_menu_send)
            .setCustomContentView(contentView)
            .setCustomBigContentView(contentView)
            .setContentIntent(tapPendingIntent)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            .setCategory(NotificationCompat.CATEGORY_PROGRESS)
            .build()
    }
    
    /**
     * Build generic notification
     */
    fun buildGenericNotification(
        title: String,
        status: String,
        progress: Double,
        notificationId: Int,
        deepLink: String?
    ): Notification {
        val channelId = CHANNEL_ID_DELIVERY
        
        val tapIntent = deepLink?.let {
            Intent(Intent.ACTION_VIEW, android.net.Uri.parse(it))
        } ?: Intent(context, context.javaClass)
        
        val tapPendingIntent = PendingIntent.getActivity(
            context,
            notificationId,
            tapIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        return NotificationCompat.Builder(context, channelId)
            .setContentTitle(title)
            .setContentText(formatStatus(status))
            .setSmallIcon(android.R.drawable.ic_menu_send)
            .setContentIntent(tapPendingIntent)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setProgress(100, progress.toInt(), false)
            .setCategory(NotificationCompat.CATEGORY_PROGRESS)
            .build()
    }
    
    // Helper methods
    
    private fun formatStatus(status: String): String {
        return status.replace("_", " ").split(" ").joinToString(" ") { word ->
            word.lowercase().replaceFirstChar { it.uppercase() }
        }
    }
    
    private fun setStageIndicators(contentView: RemoteViews, stage: Int) {
        val stageViews = listOf(
            R.id.stage0,
            R.id.stage1,
            R.id.stage2,
            R.id.stage3,
            R.id.stage4
        )
        
        stageViews.forEachIndexed { index, viewId ->
            val color = if (index <= stage) "#4CAF50" else "#CCCCCC"
            contentView.setInt(viewId, "setBackgroundColor", Color.parseColor(color))
        }
    }
    
    private fun setEcommerceStageIndicators(contentView: RemoteViews, stage: Int) {
        val stageViews = listOf(
            R.id.ecomStage0,
            R.id.ecomStage1,
            R.id.ecomStage2,
            R.id.ecomStage3,
            R.id.ecomStage4
        )
        
        stageViews.forEachIndexed { index, viewId ->
            val color = if (index <= stage) "#2196F3" else "#CCCCCC"
            contentView.setInt(viewId, "setBackgroundColor", Color.parseColor(color))
        }
    }
    
    private suspend fun loadImageIntoRemoteViews(
        contentView: RemoteViews,
        viewId: Int,
        imageUrl: String
    ) {
        try {
            withContext(Dispatchers.IO) {
                val bitmap = Glide.with(context)
                    .asBitmap()
                    .load(imageUrl)
                    .submit(100, 100)
                    .get()
                
                contentView.setImageViewBitmap(viewId, bitmap)
            }
        } catch (e: Exception) {
            // Use placeholder on error
        }
    }
}
