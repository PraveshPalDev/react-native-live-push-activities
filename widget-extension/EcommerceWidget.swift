//
//  EcommerceWidget.swift
//  Live Activities Widget Extension
//
//  Copy this file into your Widget Extension target in Xcode.
//  Flipkart/Amazon-style E-commerce Delivery tracking Live Activity.
//

import ActivityKit
import WidgetKit
import SwiftUI

// MARK: - E-commerce Delivery Live Activity

@available(iOS 16.2, *)
struct EcommerceDeliveryLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: EcommerceDeliveryAttributes.self) { context in
            // Lock Screen / Banner UI
            EcommerceDeliveryLockScreenView(context: context)
        } dynamicIsland: { context in
            // Dynamic Island UI
            DynamicIsland {
                // Expanded View
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 8) {
                        RemoteImage(url: URL(string: context.attributes.productImage ?? ""))
                            .frame(width: 40, height: 40)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(context.attributes.productName)
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
                        if let date = context.state.estimatedDeliveryDate {
                            Text(formatDeliveryDate(date))
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        Text(context.attributes.orderId)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(spacing: 10) {
                        // Stage Progress
                        StageIndicator(currentStage: context.state.statusStage, totalStages: 5)
                        
                        // Current Hub
                        if let hub = context.state.currentHub {
                            HStack {
                                Image(systemName: "location.fill")
                                    .foregroundColor(.deliveryBlue)
                                    .font(.caption)
                                Text("Currently at: \(hub)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        // Tracking Info
                        HStack {
                            if let courier = context.state.courierPartner {
                                Label(courier, systemImage: "box.fill")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if let trackingNumber = context.state.trackingNumber {
                                Text("AWB: \(trackingNumber)")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        // Action Buttons
                        HStack(spacing: 16) {
                            if let trackingUrl = context.attributes.trackingUrl,
                               let url = URL(string: trackingUrl) {
                                Link(destination: url) {
                                    Label("Track", systemImage: "location.fill")
                                        .font(.caption)
                                        .foregroundColor(.deliveryBlue)
                                }
                            }
                            
                            if context.state.rescheduleAvailable == true {
                                if let deepLink = context.attributes.deepLink,
                                   let url = URL(string: deepLink + "/reschedule") {
                                    Link(destination: url) {
                                        Label("Reschedule", systemImage: "calendar")
                                            .font(.caption)
                                            .foregroundColor(.deliveryOrange)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 8)
                }
            } compactLeading: {
                // Compact Leading
                Image(systemName: "box.fill")
                    .foregroundColor(.deliveryBlue)
            } compactTrailing: {
                // Compact Trailing
                Text(stageEmoji(for: context.state.statusStage))
                    .font(.caption)
            } minimal: {
                // Minimal
                Image(systemName: "box.fill")
                    .foregroundColor(.deliveryBlue)
            }
        }
    }
    
    private func stageText(for stage: Int) -> String {
        switch stage {
        case 0: return "Order Placed"
        case 1: return "Shipped"
        case 2: return "In Transit"
        case 3: return "Out for Delivery"
        case 4: return "Delivered"
        default: return ""
        }
    }
    
    private func stageEmoji(for stage: Int) -> String {
        switch stage {
        case 0: return "📦"
        case 1: return "🚚"
        case 2: return "✈️"
        case 3: return "🏠"
        case 4: return "✅"
        default: return "📦"
        }
    }
}

// MARK: - Lock Screen View

@available(iOS 16.2, *)
struct EcommerceDeliveryLockScreenView: View {
    let context: ActivityViewContext<EcommerceDeliveryAttributes>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with Product
            HStack {
                RemoteImage(url: URL(string: context.attributes.productImage ?? ""))
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(context.attributes.productName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .lineLimit(2)
                    Text(context.attributes.orderId)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            // Delivery Timeline
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(stageText(for: context.state.statusStage))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(statusColor(for: context.state.status))
                    
                    Spacer()
                    
                    if let date = context.state.estimatedDeliveryDate {
                        Text("By \(formatDeliveryDate(date))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Timeline Progress
                HStack(spacing: 0) {
                    ForEach(0..<5, id: \.self) { stage in
                        HStack(spacing: 0) {
                            Circle()
                                .fill(stage <= context.state.statusStage ? Color.deliveryBlue : Color.gray.opacity(0.3))
                                .frame(width: 12, height: 12)
                                .overlay(
                                    Image(systemName: stage <= context.state.statusStage ? "checkmark" : "")
                                        .font(.system(size: 8, weight: .bold))
                                        .foregroundColor(.white)
                                )
                            
                            if stage < 4 {
                                Rectangle()
                                    .fill(stage < context.state.statusStage ? Color.deliveryBlue : Color.gray.opacity(0.3))
                                    .frame(height: 2)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                    }
                }
                
                // Stage Labels
                HStack {
                    Text("Ordered")
                        .font(.caption2)
                    Spacer()
                    Text("Shipped")
                        .font(.caption2)
                    Spacer()
                    Text("Transit")
                        .font(.caption2)
                    Spacer()
                    Text("Out")
                        .font(.caption2)
                    Spacer()
                    Text("Done")
                        .font(.caption2)
                }
                .foregroundColor(.secondary)
            }
            
            // Courier Info
            if let courier = context.state.courierPartner ?? context.attributes.courierPartner {
                Divider()
                
                HStack {
                    Image(systemName: "box.fill")
                        .foregroundColor(.deliveryBlue)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(courier)
                            .font(.caption)
                            .fontWeight(.medium)
                        if let trackingNumber = context.state.trackingNumber {
                            Text("AWB: \(trackingNumber)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    if let trackingUrl = context.attributes.trackingUrl,
                       let url = URL(string: trackingUrl) {
                        Link(destination: url) {
                            Text("Track")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.deliveryBlue)
                        }
                    }
                }
            }
            
            // Current Location
            if let hub = context.state.currentHub {
                HStack {
                    Image(systemName: "location.fill")
                        .foregroundColor(.deliveryGray)
                        .font(.caption)
                    Text("Currently at: \(hub)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Delivery Attempts / Reschedule
            if context.state.status == "delivery_attempted" {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.deliveryOrange)
                    
                    Text("Delivery attempted \(context.state.deliveryAttempts ?? 1) time(s)")
                        .font(.caption)
                        .foregroundColor(.deliveryOrange)
                    
                    Spacer()
                    
                    if context.state.rescheduleAvailable == true,
                       let deepLink = context.attributes.deepLink,
                       let url = URL(string: deepLink + "/reschedule") {
                        Link(destination: url) {
                            Text("Reschedule")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.deliveryOrange)
                        }
                    }
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
        case 0: return "Order Placed"
        case 1: return "Shipped"
        case 2: return "In Transit"
        case 3: return "Out for Delivery"
        case 4: return "Delivered!"
        default: return ""
        }
    }
}

// MARK: - Preview

@available(iOS 16.2, *)
struct EcommerceDeliveryLiveActivity_Previews: PreviewProvider {
    static let attributes = EcommerceDeliveryAttributes(
        orderId: "EC-12345",
        productName: "iPhone 15 Pro Max 256GB",
        productImage: nil,
        productDescription: "Natural Titanium",
        courierPartner: "BlueDart",
        trackingUrl: "https://bluedart.com/track/123",
        appIcon: nil,
        deepLink: "myapp://order/EC-12345"
    )
    
    static let contentState = EcommerceDeliveryAttributes.ContentState(
        status: "in_transit",
        statusStage: 2,
        estimatedDeliveryDate: Date().addingTimeInterval(2 * 24 * 60 * 60),
        courierPartner: "BlueDart",
        trackingNumber: "BD123456789",
        currentHub: "Mumbai Distribution Center",
        deliveryAttempts: nil,
        rescheduleAvailable: true
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
