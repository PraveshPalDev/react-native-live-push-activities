//
//  Extensions.swift
//  Live Activities Widget Extension
//
//  Copy this file into your Widget Extension target in Xcode.
//  Contains helper extensions for SwiftUI views.
//

import SwiftUI
import ActivityKit

// MARK: - Color Extensions

extension Color {
    static let deliveryGreen = Color(red: 0.2, green: 0.78, blue: 0.35)
    static let deliveryOrange = Color(red: 1.0, green: 0.58, blue: 0.0)
    static let deliveryRed = Color(red: 1.0, green: 0.27, blue: 0.23)
    static let deliveryBlue = Color(red: 0.0, green: 0.48, blue: 1.0)
    static let deliveryGray = Color(red: 0.56, green: 0.56, blue: 0.58)
}

// MARK: - Status Color Helper

func statusColor(for status: String) -> Color {
    switch status.lowercased() {
    case "delivered", "completed":
        return .deliveryGreen
    case "on_the_way", "on-the-way", "in_progress", "in-progress", "arriving":
        return .deliveryBlue
    case "preparing", "confirmed", "ordered", "shipped", "in_transit", "out_for_delivery":
        return .deliveryOrange
    case "cancelled", "failed", "returned":
        return .deliveryRed
    default:
        return .deliveryGray
    }
}

// MARK: - Progress Bar View

struct ProgressBar: View {
    var progress: Double
    var color: Color = .deliveryGreen
    var height: CGFloat = 6
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: height)
                
                Capsule()
                    .fill(color)
                    .frame(width: min(progress, 100) / 100 * geometry.size.width, height: height)
                    .animation(.easeInOut(duration: 0.3), value: progress)
            }
        }
        .frame(height: height)
    }
}

// MARK: - Status Icon View

struct StatusIcon: View {
    var status: String
    var size: CGFloat = 24
    
    var body: some View {
        ZStack {
            Circle()
                .fill(statusColor(for: status).opacity(0.2))
                .frame(width: size, height: size)
            
            Image(systemName: statusIconName(for: status))
                .font(.system(size: size * 0.5, weight: .semibold))
                .foregroundColor(statusColor(for: status))
        }
    }
    
    func statusIconName(for status: String) -> String {
        switch status.lowercased() {
        case "delivered", "completed":
            return "checkmark"
        case "on_the_way", "on-the-way", "in_transit", "in-transit":
            return "bicycle"
        case "arriving", "out_for_delivery", "out-for-delivery":
            return "location.fill"
        case "preparing", "confirmed":
            return "clock.fill"
        case "cancelled", "failed":
            return "xmark"
        case "picked_up", "picked-up":
            return "bag.fill"
        case "ordered", "shipped":
            return "box.fill"
        default:
            return "questionmark"
        }
    }
}

// MARK: - Stage Indicator View

struct StageIndicator: View {
    var currentStage: Int
    var totalStages: Int = 5
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<totalStages, id: \.self) { stage in
                Circle()
                    .fill(stage <= currentStage ? Color.deliveryGreen : Color.gray.opacity(0.3))
                    .frame(width: 8, height: 8)
            }
        }
    }
}

// MARK: - Countdown Timer View

struct CountdownTimer: View {
    var estimatedMinutes: Int
    @State private var remainingSeconds: Int
    
    init(estimatedMinutes: Int) {
        self.estimatedMinutes = estimatedMinutes
        self._remainingSeconds = State(initialValue: estimatedMinutes * 60)
    }
    
    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: "clock.fill")
                .font(.caption2)
            Text(formatTime(remainingSeconds))
                .font(.caption)
                .fontWeight(.semibold)
                .monospacedDigit()
        }
        .foregroundColor(.deliveryOrange)
        .onAppear {
            startTimer()
        }
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%d:%02d", mins, secs)
    }
    
    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if remainingSeconds > 0 {
                remainingSeconds -= 1
            } else {
                timer.invalidate()
            }
        }
    }
}

// MARK: - Async Image Loader

struct RemoteImage: View {
    var url: URL?
    var placeholder: String = "photo.fill"
    
    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            case .failure:
                Image(systemName: placeholder)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.gray)
            @unknown default:
                Image(systemName: placeholder)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.gray)
            }
        }
    }
}

// MARK: - Time Formatting Helpers

func formatEstimatedTime(_ minutes: Int) -> String {
    if minutes <= 0 {
        return "Arriving"
    } else if minutes == 1 {
        return "1 min"
    } else if minutes < 60 {
        return "\(minutes) mins"
    } else {
        let hours = minutes / 60
        let mins = minutes % 60
        if mins == 0 {
            return "\(hours) hr"
        }
        return "\(hours) hr \(mins) min"
    }
}

func formatDeliveryDate(_ date: Date?) -> String {
    guard let date = date else { return "" }
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter.string(from: date)
}

// MARK: - Deep Link Handler

func openDeepLink(_ urlString: String?) {
    guard let urlString = urlString,
          let url = URL(string: urlString) else { return }
    // In widget, use Link for navigation
    // This is handled by Link views in the widget
}
