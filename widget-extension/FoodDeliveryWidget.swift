//
//  FoodDeliveryWidget.swift
//  Live Activities Widget Extension
//
//  Copy this file into your Widget Extension target in Xcode.
//  Swiggy/Zomato-style Food Delivery tracking Live Activity.
//

import ActivityKit
import WidgetKit
import SwiftUI

// MARK: - Food Delivery Live Activity

@available(iOS 16.2, *)
struct FoodDeliveryLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: FoodDeliveryAttributes.self) { context in
            // Lock Screen / Banner UI
            FoodDeliveryLockScreenView(context: context)
        } dynamicIsland: { context in
            // Dynamic Island UI
            DynamicIsland {
                // Expanded View
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 8) {
                        RemoteImage(url: URL(string: context.attributes.restaurantLogo ?? ""))
                            .frame(width: 40, height: 40)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(context.attributes.restaurantName)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .lineLimit(1)
                            Text(stageText(for: context.state.statusStage))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing) {
                        Text(formatEstimatedTime(context.state.estimatedMinutes))
                            .font(.headline)
                            .foregroundColor(.deliveryOrange)
                        Text("ETA")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(spacing: 10) {
                        // Stage Indicator
                        StageIndicator(currentStage: context.state.statusStage, totalStages: 5)
                        
                        // Order Items
                        if let items = context.attributes.orderItems {
                            Text(items)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                        
                        // Rider Info
                        if context.state.statusStage >= 2, let riderName = context.state.riderName {
                            HStack {
                                RemoteImage(url: URL(string: context.state.riderPhoto ?? ""))
                                    .frame(width: 28, height: 28)
                                    .clipShape(Circle())
                                
                                VStack(alignment: .leading) {
                                    Text(riderName)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                    if let location = context.state.currentLocation {
                                        Text(location)
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Spacer()
                                
                                if let phone = context.state.riderPhone,
                                   let url = URL(string: "tel://\(phone)") {
                                    Link(destination: url) {
                                        Image(systemName: "phone.fill")
                                            .foregroundColor(.deliveryGreen)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 8)
                }
            } compactLeading: {
                // Compact Leading
                Image(systemName: "fork.knife")
                    .foregroundColor(.deliveryOrange)
            } compactTrailing: {
                // Compact Trailing
                Text(formatEstimatedTime(context.state.estimatedMinutes))
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.deliveryOrange)
            } minimal: {
                // Minimal
                Image(systemName: "fork.knife")
                    .foregroundColor(.deliveryOrange)
            }
        }
    }
    
    private func stageText(for stage: Int) -> String {
        switch stage {
        case 0: return "Order Confirmed"
        case 1: return "Preparing your food"
        case 2: return "Picked up by rider"
        case 3: return "On the way"
        case 4: return "Delivered"
        default: return ""
        }
    }
}

// MARK: - Lock Screen View

@available(iOS 16.2, *)
struct FoodDeliveryLockScreenView: View {
    let context: ActivityViewContext<FoodDeliveryAttributes>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with Restaurant
            HStack {
                RemoteImage(url: URL(string: context.attributes.restaurantLogo ?? ""))
                    .frame(width: 44, height: 44)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(context.attributes.restaurantName)
                        .font(.headline)
                        .lineLimit(1)
                    Text(context.attributes.orderId)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(formatEstimatedTime(context.state.estimatedMinutes))
                        .font(.headline)
                        .foregroundColor(.deliveryOrange)
                    Text("ETA")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            // Stage Progress
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(stageText(for: context.state.statusStage))
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                }
                
                StageIndicator(currentStage: context.state.statusStage, totalStages: 5)
            }
            
            // Order Items
            if let items = context.attributes.orderItems {
                Text(items)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            // Rider Info (shown after pickup)
            if context.state.statusStage >= 2, let riderName = context.state.riderName {
                Divider()
                
                HStack {
                    RemoteImage(url: URL(string: context.state.riderPhoto ?? ""))
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(riderName)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        if let location = context.state.currentLocation {
                            Text(location)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 16) {
                        if let phone = context.state.riderPhone,
                           let url = URL(string: "tel://\(phone)") {
                            Link(destination: url) {
                                Image(systemName: "phone.fill")
                                    .foregroundColor(.deliveryGreen)
                            }
                        }
                        
                        if let deepLink = context.attributes.deepLink,
                           let url = URL(string: deepLink) {
                            Link(destination: url) {
                                Image(systemName: "map.fill")
                                    .foregroundColor(.deliveryBlue)
                            }
                        }
                    }
                }
            }
            
            // Delivery Address
            if let address = context.attributes.deliveryAddress {
                HStack {
                    Image(systemName: "location.fill")
                        .foregroundColor(.deliveryGray)
                        .font(.caption)
                    Text(address)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .activityBackgroundTintList([
            Color.clear
        ])
    }
    
    private func stageText(for stage: Int) -> String {
        switch stage {
        case 0: return "Order Confirmed"
        case 1: return "Preparing your food"
        case 2: return "Picked up by rider"
        case 3: return "On the way"
        case 4: return "Delivered!"
        default: return ""
        }
    }
}

// MARK: - Preview

@available(iOS 16.2, *)
struct FoodDeliveryLiveActivity_Previews: PreviewProvider {
    static let attributes = FoodDeliveryAttributes(
        orderId: "FD-12345",
        restaurantName: "Pizza Hut",
        restaurantLogo: nil,
        orderItems: "Margherita Pizza, Garlic Bread, Coke",
        deliveryAddress: "123 Main Street, Apartment 4B",
        appIcon: nil,
        deepLink: "myapp://order/FD-12345"
    )
    
    static let contentState = FoodDeliveryAttributes.ContentState(
        status: "on_the_way",
        statusStage: 3,
        estimatedMinutes: 12,
        riderName: "Amit Singh",
        riderPhone: "+919876543210",
        riderPhoto: nil,
        currentLocation: "Near Central Market",
        preparationTime: 15,
        distanceRemaining: 2.5
    )
    
    static var previews: some View {
        Group {
            attributes
                .previewContext(contentState, viewKind: .dynamicIsland(.compact))
                .previewDisplayName("Compact")
            
            attributes
                .previewContext(contentState, viewKind: .dynamicIsland(.expanded))
                .previewDisplayName("Expanded")
            
            attributes
                .previewContext(contentState, viewKind: .content)
                .previewDisplayName("Lock Screen")
        }
    }
}
