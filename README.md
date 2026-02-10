# 🚀 React Native Live Activities

A **simplified, battle-tested** library to implement iOS Live Activities (Dynamic Island & Lock Screen) in React Native.

- ✅ **iOS**: Full Native implementation with 4 pre-built templates.
- ✅ **Android**: Safe stub implementation (prevents crashes, allows shared code).
- ✅ **Zero Config** for Android.
- ✅ **TypeScript** support out of the box.

---

## 📦 Installation

```bash
npm install react-native-live-activities
cd ios && pod install
```

---

## 🍎 iOS Configuration (Required)

Live Activities require a **Widget Extension** in your iOS app. Follow these steps carefully.

### 1. Update `Info.plist`

Open your `ios/YourApp/Info.plist` and add:

```xml
<key>NSSupportsLiveActivities</key>
<true/>
```

### 2. Create a Widget Extension

1. Open your project in Xcode (`.xcworkspace`).
2. Go to **File > New > Target**.
3. Search for **Widget Extension**.
4. Name it (e.g., `LiveActivityExtension`).
5. **Ensure "Include Live Activity" is CHECKED.**

### 3. Setup Attributes (Crucial!)

Your Widget Extension needs to know the data structure sent by React Native.
**Create a new Swift file** in your **Widget Extension** folder named `ActivityAttributes.swift` and paste this code:

```swift
import ActivityKit
import Foundation

// ⚠️ COPY THIS EXACTLY to your Widget Extension
// These match the structures in the React Native library

public struct RideTrackingAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var status: String
        var currentLocation: String?
        var estimatedArrival: Date
        var distance: Double?
    }
    var driverName: String
    var vehicleNumber: String
    var vehicleType: String?
    var pickup: String
    var dropoff: String
    var driverPhoto: String?
}

public struct DeliveryTrackingAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var status: String
        var currentLocation: String?
        var estimatedArrival: Date
        var stopsRemaining: Int?
    }
    var courierName: String
    var orderNumber: String
    var orderItems: String?
    var deliveryAddress: String?
}

public struct SportsScoreAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var homeScore: Int
        var awayScore: Int
        var period: String
        var timeRemaining: String?
        var lastPlay: String?
        var isLive: Bool
    }
    var homeTeam: String
    var awayTeam: String
    var homeTeamLogo: String?
    var awayTeamLogo: String?
    var league: String?
}

public struct TimerAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var endTime: Date
        var isPaused: Bool
        var remainingSeconds: Double?
    }
    var title: String
    var description: String?
    var icon: String?
}
```

### 4. Create the UI

Open your `LiveActivityExtensionBundle.swift` (or the main file of your extension) and ensure you handle these activities. Here is a **complete example** of a generic widget that supports all 4 templates:

```swift
import WidgetKit
import SwiftUI

@main
struct LiveActivityBundle: WidgetBundle {
    var body: some Widget {
        RideTrackingWidget()
        // Add others if needed: DeliveryWidget(), SportsWidget(), TimerWidget()
    }
}

struct RideTrackingWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: RideTrackingAttributes.self) { context in
            // 📱 Lock Screen UI
            VStack {
                Text("Ride: \(context.attributes.driverName)")
                Text("Status: \(context.state.status)")
            }
            .activityBackgroundTint(Color.black)
            .activitySystemActionForegroundColor(Color.white)

        } dynamicIsland: { context in
            // 🏝️ Dynamic Island UI
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Text("🚕")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.state.status)
                }
                DynamicIslandExpandedRegion(.center) {
                    Text(context.attributes.driverName)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Arrival: \(context.state.estimatedArrival, style: .time)")
                }
            } compactLeading: {
                Text("🚕")
            } compactTrailing: {
                Text(context.state.status)
            } minimal: {
                Text("🚕")
            }
        }
    }
}
```

---

## 🤖 Android Usage (Platform Safe)

On Android, all methods are **safe no-ops**. They resolve immediately without error.
This allows you to write one shared codebase:

```javascript
// This code is safe to run on Android!
// It will just return a dummy ID and do nothing.
await LiveActivities.RideTracking.start(...)
```

---

## 📖 Usage Examples

### 1. Ride Tracking (Uber/Lyft style)

```typescript
import { Templates } from 'react-native-live-activities';

// Start Activity
const activityId = await Templates.RideTracking.start(
  {
    driverName: 'John Doe',
    vehicleNumber: 'ABC-123',
    pickup: 'Central Station',
    dropoff: 'Airport',
  },
  {
    status: 'on-the-way',
    estimatedArrival: Date.now() + 15 * 60 * 1000, // 15 mins
    distance: 3.5,
  }
);

// Update Status
await Templates.RideTracking.update(activityId, {
  status: 'arriving',
  distance: 0.5,
});

// End (Ride Complete)
await Templates.RideTracking.complete(activityId);
```

### 2. Delivery (Food/Package)

```typescript
import { Templates } from 'react-native-live-activities';

const id = await Templates.DeliveryTracking.start(
  { courierName: 'Mike', orderNumber: '#8821' },
  { status: 'preparing', estimatedArrival: Date.now() + 3000000 }
);
```

### 3. Timer (Countdown)

```typescript
import { Templates } from 'react-native-live-activities';

const id = await Templates.Timer.start(
  { title: 'Workout' },
  60 // duration in seconds
);

// Pause
await Templates.Timer.pause(id);

// Resume (with new remaining time)
await Templates.Timer.resume(id, 30);
```

---

## ❓ Troubleshooting

**"The package ... doesn't seem to be linked"**

- Rebuild your app: `npx react-native run-ios`
- Ensure you ran `pod install` in `ios/`.

**Activity doesn't appear on simulator?**

- Live Activities often require a **real device** for push updates, though local activities _should_ work on Simulator (iOS 16.2+).
- Ensure `NSSupportsLiveActivities` is in `Info.plist`.

**"Invalid Activity Type" Error**

- Ensure your Widget Extension defines the **exact same** struct key names as the library uses (see Step 3 above).
