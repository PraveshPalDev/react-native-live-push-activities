# 🚀 React Native Push & Live Activities (Cross-Platform)

<div align="center">
  <h3>
    The ultimate library for iOS Dynamic Island, Lock Screen Activities & Android Compatibility
  </h3>
  <p>
    Seamlessly integrate iOS Live Activities with React Native. <br/>
    Includes complete <b>no-crash</b> support for Android & Expo (Development Builds).
  </p>
</div>

---

## 🔥 Features

- **iOS 16+ Support**: Full Dynamic Island & Lock Screen Live Activities.
- **Push Notification Support**: Get push tokens to update activities remotely.
- **Android Safe**: Methods are safe no-ops on Android to prevent crashes (write once, run everywhere).
- **TypeScript First**: Fully typed API.
- **Expo Compatible**: Works with Expo Development Builds (via Prebuild).
- **✨ Generic / Custom Activities**: Send ANY data structure without modifying native code!

---

## 📦 Installation

```bash
# npm
npm install react-native-live-push-activities

# yarn
yarn add react-native-live-push-activities
```

### iOS Setup (Mobile Linking)

```bash
cd ios && pod install
```

---

## 🍎 iOS Implementation Guide (Deep Dive)

### 1. Enable Capabilities

1. Open your project in Xcode (`.xcworkspace`).
2. Select your **Project Target** > **Signing & Capabilities**.
3. Add **Push Notifications** capability.
4. Add to `Info.plist`:
   ```xml
   <key>NSSupportsLiveActivities</key>
   <true/>
   ```

### 2. Create Widget Extension

1. **File > New > Target** > **Widget Extension**.
2. CHECK **"Include Live Activity"**.
3. Name it (e.g., `LiveActivityExtension`).

### 3. Setup Attributes (The "Bridge")

You must define the exact structs that the React Native library expects.
Create a file named `ActivityAttributes.swift` in your **Widget Extension** and paste this:

```swift
import ActivityKit
import SwiftUI

// 1. Pre-built Template: Ride Tracking
public struct RideTrackingAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var status: String
        var estimatedArrival: Date
        var driverName: String?
    }
    var vehicleModel: String
}

// 2. ✨ GENERIC / CUSTOM ACTIVITY (Recommended for flexibility)
// This allows you to send ANY JSON data from React Native!
public struct GenericActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var data: String // JSON string of your dynamic content
    }
    var fixedData: String // JSON string of your static content
}
```

### 4. Create the UI (Widget Bundle)

In `LiveActivityExtensionBundle.swift`:

```swift
import WidgetKit
import SwiftUI

@main
struct LiveActivityBundle: WidgetBundle {
    var body: some Widget {
        RideTrackingWidget()
        GenericActivityWidget()
    }
}

// Example UI for Generic Activity
struct GenericActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: GenericActivityAttributes.self) { context in
            // Parse JSON manually here if needed
            // let data = try? JSONDecoder().decode(MyData.self, from: context.state.data.data(using: .utf8)!)

            VStack {
                Text("Custom Activity")
                Text(context.state.data) // Displays raw JSON (parse this!)
            }
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.center) {
                    Text("Dynamic Island")
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T")
            } minimal: {
                Text("M")
            }
        }
    }
}
```

---

## 💻 API & Usage

### Method 1: Using Pre-built Templates

Best for improved type safety with standard use cases.

```typescript
import { Templates } from 'react-native-live-push-activities';

// Start
const activityId = await Templates.RideTracking.start(
  { vehicleModel: 'Tesla Y' },
  { status: 'Arriving', estimatedArrival: Date.now() + 60000 }
);

// Update
await Templates.RideTracking.update(activityId, {
  status: 'Arrived',
});
```

### Method 2: Custom / Generic Activity (Data-Driven)

Pass any object, and it will be serialized as JSON to the `GenericActivityAttributes` struct.

```typescript
import LiveActivities from 'react-native-live-push-activities';

// 1. Start Activity
const activityId = await LiveActivities.startActivity({
  activityType: 'GenericActivity', // Matches the Swift struct
  attributes: {
    customId: '123',
    type: 'flight_status',
  },
  contentState: {
    flight: 'AA123',
    status: 'Boarding',
    gate: 'A4',
  },
});

// 2. Update (Pass new state object)
await LiveActivities.updateActivity(activityId, {
  contentState: {
    flight: 'AA123',
    status: 'Departed',
    gate: 'A4',
  },
});
```

---

## 🤖 Android Usage

The library provides safe "No-Op" methods on Android. It won't crash, but it won't show anything.
To implement a similar UI on Android (sticky notification), use `@notifee/react-native`.

```typescript
import { Platform } from 'react-native';
import LiveActivities from 'react-native-live-push-activities';

if (Platform.OS === 'ios') {
  await LiveActivities.startActivity(...);
} else {
  // Use Notifee for Android
}
```

---

## 🖤 Usage with Expo (CNG)

1. `npx expo install react-native-live-push-activities`
2. Run `npx expo prebuild` to generate the ios/android folders.
3. Open `ios/YourApp.xcworkspace`.
4. Create the **Widget Extension** manually (Step 2 & 3 in Guide).
5. Run `npx expo run:ios`.

---

## ❓ Troubleshooting

**Token is nil?**

- Ensure you are testing on a **real device**. Simulators often don't receive push tokens.
- Ensure the app has Push Notification permission.

**Update not showing?**

- Verify the `activityId` exists.
- Ensure your Widget UI reads the correct fields from `context.state`.

---

## 📜 License

MIT
