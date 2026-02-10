# 🔧 Complete Setup Guide

This guide will walk you through setting up Live Activities in your React Native project.

## Prerequisites

- **iOS 16.1+** - Live Activities minimum requirement
- **Xcode 14+** - For building the Widget Extension
- **React Native 0.60+** - For autolinking support
- **macOS** - Required for iOS development

## Installation Methods

### Method 1: Automatic Setup (Recommended)

1. **Install the package**:

   ```bash
   npm install react-native-live-activities
   # or
   yarn add react-native-live-activities
   ```

2. **Run the setup script**:

   ```bash
   npx react-native-live-activities-setup
   ```

3. **Complete Xcode configuration** (follow the prompts from the script):
   - Open your `.xcworkspace` file in Xcode
   - Add Widget Extension target (File > New > Target > Widget Extension)
   - Set deployment target to iOS 16.1+
   - Add the generated files to your project

4. **Install pods**:
   ```bash
   cd ios && pod install && cd ..
   ```

### Method 2: Manual Setup

If you prefer manual configuration or the automatic script fails, follow these steps:

#### Step 1: Create Widget Extension

1. Open your project in Xcode
2. Go to **File > New > Target**
3. Select **Widget Extension**
4. Name it `LiveActivityWidget`
5. Deselect "Include Configuration Intent"
6. Click **Finish**

#### Step 2: Configure Deployment Targets

**CRITICAL**: This is the most common source of issues!

1. Select your project in the Project Navigator
2. For **both** the main app target and Widget Extension target:
   - Go to **Build Settings**
   - Find **iOS Deployment Target**
   - Set it to **iOS 16.1** or higher
   - **Ensure both targets have the EXACT same version**

#### Step 3: Update Info.plist

Add this to your main app's `Info.plist`:

```xml
<key>NSSupportsLiveActivities</key>
<true/>
```

#### Step 4: Create Activity Attributes

Create a new Swift file in your Widget Extension: `ActivityAttributes.swift`

```swift
import Foundation
import ActivityKit

struct RideTrackingAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var status: String
        var currentLocation: String?
        var estimatedArrival: Date
    }

    var driverName: String
    var vehicleNumber: String
    var pickup: String
    var dropoff: String
}
```

#### Step 5: Create Widget UI

In your Widget Extension's main file, create the widget:

```swift
import WidgetKit
import SwiftUI
import ActivityKit

@main
struct LiveActivityWidgets: WidgetBundle {
    var body: some Widget {
        RideTrackingLiveActivity()
    }
}

struct RideTrackingLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: RideTrackingAttributes.self) { context in
            // Lock Screen view
            RideTrackingLockScreenView(context: context)
        } dynamicIsland: { context in
            // Dynamic Island views
            DynamicIsland {
                // Expanded view
                DynamicIslandExpandedRegion(.leading) {
                    Text(context.attributes.driverName)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.state.estimatedArrival, style: .timer)
                }
            } compactLeading: {
                Image(systemName: "car.fill")
            } compactTrailing: {
                Text(context.state.estimatedArrival, style: .timer)
            } minimal: {
                Image(systemName: "car.fill")
            }
        }
    }
}
```

#### Step 6: Configure Bundle Identifiers

1. Main app: `com.yourcompany.yourapp`
2. Widget Extension: `com.yourcompany.yourapp.LiveActivityWidget`

The Widget Extension bundle ID must be a child of the main app.

#### Step 7: Add App Groups (Optional, for shared data)

1. In Xcode, select your main app target
2. Go to **Signing & Capabilities**
3. Click **+ Capability**
4. Add **App Groups**
5. Create a group: `group.com.yourcompany.yourapp`
6. Repeat for the Widget Extension target

#### Step 8: Install Pods

```bash
cd ios && pod install && cd ..
```

## Verification

Build and run your app:

```bash
npx react-native run-ios
```

Check for:

- ✅ No build errors
- ✅ App launches successfully
- ✅ Live Activities module is available

Test Live Activities:

```typescript
import { LiveActivities } from 'react-native-live-activities';

const checkStatus = async () => {
  const enabled = await LiveActivities.areActivitiesEnabled();
  console.log('Live Activities enabled:', enabled);
};
```

## Common Issues & Solutions

### Issue: "Live Activities not appearing"

**Solutions**:

1. Verify deployment targets match (both iOS 16.1+)
2. Check Info.plist has `NSSupportsLiveActivities = YES`
3. Test on a physical device (not simulator)
4. Check Xcode console for errors

### Issue: "Build failed with linker error"

**Solutions**:

1. Run `pod install` in ios directory
2. Clean build folder (Cmd+Shift+K in Xcode)
3. Delete `DerivedData` folder
4. Rebuild

### Issue: "Module not found"

**Solutions**:

1. Verify package is in package.json
2. Run `npm install` again
3. For iOS: `cd ios && pod install`
4. Restart Metro bundler

## Next Steps

- [API Documentation](./API.md) - Learn all available methods
- [SwiftUI Customization](./SWIFTUI.md) - Customize your widget appearance
- [Push Notifications](./PUSH_NOTIFICATIONS.md) - Send updates via APNs
- [Examples](./EXAMPLES.md) - Complete working examples

## Need Help?

- 📖 [Full Documentation](../README.md)
- 🐛 [Report Issues](https://github.com/yourusername/react-native-live-activities/issues)
- 💬 [Discussions](https://github.com/yourusername/react-native-live-activities/discussions)
