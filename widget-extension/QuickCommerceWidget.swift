//
//  QuickCommerceWidget.swift
//  Live Activities Widget Extension
//
//  Copy this file into your Widget Extension target in Xcode.
//  Zepto-style Quick Commerce delivery tracking Live Activity.
//

import ActivityKit
import WidgetKit
import SwiftUI

// MARK: - Quick Commerce Live Activity

@available(iOS 16.2, *)
struct QuickCommerceLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: QuickCommerceAttributes.self) { context in
            // Lock Screen / Banner UI
            QuickCommerceLockScreenView(context: context)
        } dynamicIsland: { context in
            // Dynamic Island UI
            DynamicIsland {
                // Expanded View
                DynamicIslandExpandedRegion(.leading) {
                    HStack {
                        StatusIcon(status: context.state.status, size: 32)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(context.state.status.replacingOccurrences(of: "_", with: " ").capitalized)
                                .font(.caption)
                                .fontWeight(.semibold)
                            Text(formatEstimatedTime(context.state.estimatedMinutes))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing) {
                        Text("\(Int(context.state.progress))%")
                            .font(.headline)
                            .foregroundColor(.deliveryGreen)
                        Text(context.attributes.orderId)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(spacing: 8) {
                        // Progress Bar
                        ProgressBar(progress: context.state.progress, color: .deliveryGreen, height: 8)
                        
                        // Rider Info (if available)
                        if let riderName = context.state.riderName {
                            HStack {
                                RemoteImage(url: URL(string: context.state.riderPhoto ?? ""))
                                    .frame(width: 32, height: 32)
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
                // Compact Leading - Dynamic Island
                Image(systemName: "bag.fill")
                    .foregroundColor(.deliveryGreen)
            } compactTrailing: {
                // Compact Trailing - Dynamic Island
                Text("\(Int(context.state.progress))%")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.deliveryGreen)
            } minimal: {
                // Minimal - Dynamic Island
                StatusIcon(status: context.state.status, size: 24)
            }
        }
    }
}

// MARK: - Lock Screen View

@available(iOS 16.2, *)
struct QuickCommerceLockScreenView: View {
    let context: ActivityViewContext<QuickCommerceAttributes>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: "bag.fill")
                    .foregroundColor(.deliveryGreen)
                Text("Quick Delivery")
                    .font(.headline)
                Spacer()
                Text(context.attributes.orderId)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Status and Time
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(context.state.status.replacingOccurrences(of: "_", with: " ").capitalized)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    if let items = context.attributes.items {
                        Text(items)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(formatEstimatedTime(context.state.estimatedMinutes))
                        .font(.headline)
                        .foregroundColor(.deliveryOrange)
                    Text("ETA")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            // Progress Bar
            ProgressBar(progress: context.state.progress, color: .deliveryGreen, height: 8)
            
            // Rider Info
            if let riderName = context.state.riderName {
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
                    
                    // Action Buttons
                    HStack(spacing: 12) {
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
                                Image(systemName: "arrow.right.circle.fill")
                                    .foregroundColor(.deliveryBlue)
                            }
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
}

// MARK: - Preview

@available(iOS 16.2, *)
struct QuickCommerceLiveActivity_Previews: PreviewProvider {
    static let attributes = QuickCommerceAttributes(
        orderId: "ORD-12345",
        items: "Groceries, Fruits, Vegetables",
        appIcon: nil,
        deepLink: "myapp://order/ORD-12345"
    )
    
    static let contentState = QuickCommerceAttributes.ContentState(
        status: "on_the_way",
        progress: 65,
        estimatedMinutes: 4,
        riderName: "Rahul Kumar",
        riderPhone: "+919876543210",
        riderPhoto: nil,
        currentLocation: "Near MG Road Metro",
        storeName: "Zepto Store",
        storeLogo: nil
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
