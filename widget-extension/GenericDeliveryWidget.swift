//
//  GenericDeliveryWidget.swift
//  Live Activities Widget Extension
//
//  Copy this file into your Widget Extension target in Xcode.
//  Fully customizable Generic Delivery tracking Live Activity.
//

import ActivityKit
import WidgetKit
import SwiftUI

// MARK: - Generic Delivery Live Activity

@available(iOS 16.2, *)
struct GenericDeliveryLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: GenericDeliveryAttributes.self) { context in
            // Lock Screen / Banner UI
            GenericDeliveryLockScreenView(context: context)
        } dynamicIsland: { context in
            // Dynamic Island UI
            DynamicIsland {
                // Expanded View
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 8) {
                        if let imageUrl = context.state.primaryImage,
                           let url = URL(string: imageUrl) {
                            RemoteImage(url: url)
                                .frame(width: 40, height: 40)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        } else {
                            Image(systemName: iconForType(context.attributes.type))
                                .foregroundColor(colorForType(context.attributes.type))
                                .frame(width: 40, height: 40)
                                .background(Color.gray.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(context.state.title)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .lineLimit(1)
                            Text(context.state.status)
                                .font(.caption2)
                                .foregroundColor(statusColor(for: context.state.status))
                        }
                    }
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    if let progress = context.state.progress {
                        VStack(alignment: .trailing) {
                            Text("\(Int(progress))%")
                                .font(.headline)
                                .foregroundColor(colorForType(context.attributes.type))
                            Text("Complete")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(spacing: 10) {
                        // Progress Bar
                        if let progress = context.state.progress {
                            ProgressBar(progress: progress, color: colorForType(context.attributes.type), height: 8)
                        }
                        
                        // Subtitle
                        if let subtitle = context.state.subtitle {
                            Text(subtitle)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                        
                        // Action Buttons
                        HStack(spacing: 16) {
                            if let actionLabel = context.state.actionLabel,
                               let actionLink = context.state.actionDeepLink,
                               let url = URL(string: actionLink) {
                                Link(destination: url) {
                                    Label(actionLabel, systemImage: "arrow.right.circle.fill")
                                        .font(.caption)
                                        .foregroundColor(colorForType(context.attributes.type))
                                }
                            }
                            
                            if let secondaryLabel = context.state.secondaryActionLabel,
                               let secondaryLink = context.state.secondaryActionDeepLink,
                               let url = URL(string: secondaryLink) {
                                Link(destination: url) {
                                    Label(secondaryLabel, systemImage: "ellipsis.circle")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 8)
                }
            } compactLeading: {
                // Compact Leading
                Image(systemName: iconForType(context.attributes.type))
                    .foregroundColor(colorForType(context.attributes.type))
            } compactTrailing: {
                // Compact Trailing
                if let progress = context.state.progress {
                    Text("\(Int(progress))%")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(colorForType(context.attributes.type))
                } else {
                    Text(context.state.status)
                        .font(.caption2)
                        .foregroundColor(statusColor(for: context.state.status))
                }
            } minimal: {
                // Minimal
                Image(systemName: iconForType(context.attributes.type))
                    .foregroundColor(colorForType(context.attributes.type))
            }
        }
    }
    
    private func iconForType(_ type: String) -> String {
        switch type {
        case "delivery": return "box.fill"
        case "service": return "wrench.fill"
        case "booking": return "calendar.fill"
        case "ride": return "car.fill"
        default: return "star.fill"
        }
    }
    
    private func colorForType(_ type: String) -> Color {
        switch type {
        case "delivery": return .deliveryBlue
        case "service": return .deliveryOrange
        case "booking": return .deliveryGreen
        case "ride": return .purple
        default: return .deliveryGray
        }
    }
}

// MARK: - Lock Screen View

@available(iOS 16.2, *)
struct GenericDeliveryLockScreenView: View {
    let context: ActivityViewContext<GenericDeliveryAttributes>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                // Primary Image or Icon
                if let imageUrl = context.state.primaryImage,
                   let url = URL(string: imageUrl) {
                    RemoteImage(url: url)
                        .frame(width: 50, height: 50)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                } else {
                    Image(systemName: iconForType(context.attributes.type))
                        .font(.title)
                        .foregroundColor(colorForType(context.attributes.type))
                        .frame(width: 50, height: 50)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(context.state.title)
                        .font(.headline)
                        .lineLimit(1)
                    
                    Text(context.state.status)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(statusColor(for: context.state.status))
                    
                    if let subtitle = context.state.subtitle {
                        Text(subtitle)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                // Progress Circle
                if let progress = context.state.progress {
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.2), lineWidth: 4)
                        
                        Circle()
                            .trim(from: 0, to: min(progress, 100) / 100)
                            .stroke(colorForType(context.attributes.type), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                            .animation(.easeInOut(duration: 0.3), value: progress)
                        
                        Text("\(Int(progress))")
                            .font(.caption2)
                            .fontWeight(.bold)
                    }
                    .frame(width: 36, height: 36)
                }
            }
            
            // Progress Bar
            if let progress = context.state.progress {
                ProgressBar(progress: progress, color: colorForType(context.attributes.type), height: 6)
            }
            
            // Secondary Image (optional)
            if let secondaryImageUrl = context.state.secondaryImage,
               let secondaryUrl = URL(string: secondaryImageUrl) {
                HStack {
                    RemoteImage(url: secondaryUrl)
                        .frame(width: 60, height: 40)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    
                    Spacer()
                }
            }
            
            // Action Buttons
            HStack(spacing: 12) {
                if let actionLabel = context.state.actionLabel,
                   let actionLink = context.state.actionDeepLink,
                   let url = URL(string: actionLink) {
                    Link(destination: url) {
                        HStack {
                            Image(systemName: "arrow.right.circle.fill")
                            Text(actionLabel)
                                .fontWeight(.medium)
                        }
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(colorForType(context.attributes.type))
                        .clipShape(Capsule())
                    }
                }
                
                if let secondaryLabel = context.state.secondaryActionLabel,
                   let secondaryLink = context.state.secondaryActionDeepLink,
                   let url = URL(string: secondaryLink) {
                    Link(destination: url) {
                        HStack {
                            Image(systemName: "ellipsis.circle")
                            Text(secondaryLabel)
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Capsule())
                    }
                }
                
                Spacer()
            }
            
            // ID and Type
            HStack {
                Text(context.attributes.id)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(context.attributes.type.capitalized)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(Capsule())
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .activityBackgroundTintList([
            Color.clear
        ])
    }
    
    private func iconForType(_ type: String) -> String {
        switch type {
        case "delivery": return "box.fill"
        case "service": return "wrench.fill"
        case "booking": return "calendar.fill"
        case "ride": return "car.fill"
        default: return "star.fill"
        }
    }
    
    private func colorForType(_ type: String) -> Color {
        switch type {
        case "delivery": return .deliveryBlue
        case "service": return .deliveryOrange
        case "booking": return .deliveryGreen
        case "ride": return .purple
        default: return .deliveryGray
        }
    }
}

// MARK: - Preview

@available(iOS 16.2, *)
struct GenericDeliveryLiveActivity_Previews: PreviewProvider {
    static let attributes = GenericDeliveryAttributes(
        id: "SVC-12345",
        type: "service",
        appIcon: nil,
        deepLink: "myapp://service/SVC-12345"
    )
    
    static let contentState = GenericDeliveryAttributes.ContentState(
        title: "Home Cleaning",
        subtitle: "2 BHK Apartment - Deep Clean",
        status: "in_progress",
        progress: 60,
        primaryImage: nil,
        secondaryImage: nil,
        actionLabel: "Track",
        actionDeepLink: "myapp://track/SVC-12345",
        secondaryActionLabel: "Reschedule",
        secondaryActionDeepLink: "myapp://reschedule/SVC-12345",
        customData: nil
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
