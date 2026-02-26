//
//  Attributes.swift
//  Live Activities Widget Extension
//
//  Copy this file into your Widget Extension target in Xcode.
//  These attribute definitions MUST match exactly what's in your app's native module.
//

import ActivityKit
import Foundation

// MARK: - Quick Commerce Attributes (Zepto-style)

public struct QuickCommerceAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public var status: String
        public var progress: Double // 0-100
        public var estimatedMinutes: Int
        public var riderName: String?
        public var riderPhone: String?
        public var riderPhoto: String?
        public var currentLocation: String?
        public var storeName: String?
        public var storeLogo: String?
    }
    
    public var orderId: String
    public var items: String?
    public var appIcon: String?
    public var deepLink: String?
}

// MARK: - Food Delivery Attributes (Swiggy/Zomato-style)

public struct FoodDeliveryAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public var status: String
        public var statusStage: Int // 0: Confirmed, 1: Preparing, 2: Picked Up, 3: On the Way, 4: Delivered
        public var estimatedMinutes: Int
        public var riderName: String?
        public var riderPhone: String?
        public var riderPhoto: String?
        public var currentLocation: String?
        public var preparationTime: Int?
        public var distanceRemaining: Double?
    }
    
    public var orderId: String
    public var restaurantName: String
    public var restaurantLogo: String?
    public var orderItems: String?
    public var deliveryAddress: String?
    public var appIcon: String?
    public var deepLink: String?
}

// MARK: - E-commerce Delivery Attributes (Flipkart/Amazon-style)

public struct EcommerceDeliveryAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public var status: String
        public var statusStage: Int // 0: Ordered, 1: Shipped, 2: In Transit, 3: Out for Delivery, 4: Delivered
        public var estimatedDeliveryDate: Date?
        public var courierPartner: String?
        public var trackingNumber: String?
        public var currentHub: String?
        public var deliveryAttempts: Int?
        public var rescheduleAvailable: Bool?
    }
    
    public var orderId: String
    public var productName: String
    public var productImage: String?
    public var productDescription: String?
    public var courierPartner: String?
    public var trackingUrl: String?
    public var appIcon: String?
    public var deepLink: String?
}

// MARK: - Generic Delivery Attributes (Fully Customizable)

public struct GenericDeliveryAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public var title: String
        public var subtitle: String?
        public var status: String
        public var progress: Double?
        public var primaryImage: String?
        public var secondaryImage: String?
        public var actionLabel: String?
        public var actionDeepLink: String?
        public var secondaryActionLabel: String?
        public var secondaryActionDeepLink: String?
        public var customData: String? // JSON string for additional data
    }
    
    public var id: String
    public var type: String // 'delivery', 'service', 'booking', etc.
    public var appIcon: String?
    public var deepLink: String?
}

// MARK: - Legacy Attributes (for backward compatibility)

public struct RideTrackingAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public var status: String
        public var currentLocation: String?
        public var estimatedArrival: Date
        public var distance: Double?
    }
    
    public var driverName: String
    public var vehicleNumber: String
    public var vehicleType: String?
    public var pickup: String
    public var dropoff: String
    public var driverPhoto: String?
}

public struct DeliveryTrackingAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public var status: String
        public var currentLocation: String?
        public var estimatedArrival: Date
        public var stopsRemaining: Int?
    }
    
    public var courierName: String
    public var orderNumber: String
    public var orderItems: String?
    public var deliveryAddress: String?
}

public struct SportsScoreAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public var homeScore: Int
        public var awayScore: Int
        public var period: String
        public var timeRemaining: String?
        public var lastPlay: String?
        public var isLive: Bool
    }
    
    public var homeTeam: String
    public var awayTeam: String
    public var homeTeamLogo: String?
    public var awayTeamLogo: String?
    public var league: String?
}

public struct TimerAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public var endTime: Date
        public var isPaused: Bool
        public var remainingSeconds: Double?
    }
    
    public var title: String
    public var description: String?
    public var icon: String?
}

public struct GenericActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public var data: String // JSON string
    }
    public var fixedData: String // JSON string
}
