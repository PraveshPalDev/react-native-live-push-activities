# 🚀 Quick Start Guide

Get Live Activities working in your React Native app in 5 minutes!

## Prerequisites

- ✅ iOS 16.1+ device
- ✅ macOS with Xcode 14+
- ✅ React Native 0.60+ or Expo SDK 48+

## Installation

### React Native CLI

```bash
# 1. Install the package
npm install react-native-live-activities

# 2. Install iOS dependencies
cd ios && pod install && cd ..

# 3. Run automatic setup
npx react-native-live-activities-setup

# 4. Follow the Xcode prompts from the script
```

### Expo

```bash
# 1. Install the package
npx expo install react-native-live-activities

# 2. Add to app.json
```

Edit `app.json`:

```json
{
  "expo": {
    "plugins": ["react-native-live-activities"]
  }
}
```

```bash
# 3. Prebuild
npx expo prebuild

# 4. Run on device
npx expo run:ios
```

## Your First Live Activity (2 minutes)

### Step 1: Check if Available

```typescript
import LiveActivities from 'react-native-live-activities';

// Check if supported
const enabled = await LiveActivities.areActivitiesEnabled();
if (!enabled) {
  Alert.alert('Not Available', 'Requires iOS 16.1+');
  return;
}
```

### Step 2: Start an Activity

Use a pre-built template for instant results:

```typescript
import { Templates } from 'react-native-live-activities';

const activityId = await Templates.RideTracking.start(
  {
    driverName: 'John Doe',
    vehicleNumber: 'ABC-1234',
    pickup: 'Your Location',
    dropoff: 'Destination',
  },
  {
    status: 'on-the-way',
    estimatedArrival: Date.now() + 600000, // 10 minutes
  }
);
```

### Step 3: Lock Your Phone

Lock your device and you'll see the Live Activity on your Lock Screen! 🎉

### Step 4: Update the Activity

```typescript
await Templates.RideTracking.update(activityId, {
  status: 'arriving',
  estimatedArrival: Date.now() + 120000, // 2 minutes
});
```

### Step 5: End the Activity

```typescript
await Templates.RideTracking.complete(activityId);
```

## Complete Example Component

```typescript
import React, { useState } from 'react';
import { View, Button, Alert } from 'react-native';
import { Templates } from 'react-native-live-activities';

export default function App() {
  const [activityId, setActivityId] = useState<string | null>(null);

  const startActivity = async () => {
    try {
      const id = await Templates.RideTracking.start(
        {
          driverName: 'John Doe',
          vehicleNumber: 'ABC-1234',
          pickup: 'Times Square',
          dropoff: 'Central Park',
        },
        {
          status: 'on-the-way',
          estimatedArrival: Date.now() + 10 * 60 * 1000,
        }
      );
      setActivityId(id);
      Alert.alert('Success!', 'Lock your phone to see it');
    } catch (error) {
      Alert.alert('Error', error.message);
    }
  };

  const updateActivity = async () => {
    if (!activityId) return;
    await Templates.RideTracking.update(activityId, {
      status: 'arriving',
      estimatedArrival: Date.now() + 2 * 60 * 1000,
    });
    Alert.alert('Updated!');
  };

  const endActivity = async () => {
    if (!activityId) return;
    await Templates.RideTracking.complete(activityId);
    setActivityId(null);
    Alert.alert('Completed!');
  };

  return (
    <View style={{ padding: 20, gap: 10 }}>
      <Button title="Start Ride" onPress={startActivity} />
      {activityId && (
        <>
          <Button title="Update Status" onPress={updateActivity} />
          <Button title="End Ride" onPress={endActivity} />
        </>
      )}
    </View>
  );
}
```

## Troubleshooting

### Activity not showing?

1. **Check deployment targets** in Xcode:
   - Main app: iOS 16.1+
   - Widget Extension: iOS 16.1+ (must match main app!)

2. **Check Info.plist**:
   - Must have `NSSupportsLiveActivities = YES`

3. **Use physical device**:
   - Simulator support is limited

### Build errors?

```bash
# Clean and rebuild
cd ios
rm -rf Pods build
pod install
cd ..
yarn ios
```

## Pre-built Templates

We have 4 ready-to-use templates:

### 🚗 Ride Tracking

```typescript
Templates.RideTracking.start(attributes, state);
```

### 📦 Delivery Tracking

```typescript
Templates.DeliveryTracking.start(attributes, state);
```

### ⚽ Sports Score

```typescript
Templates.SportsScore.start(attributes, state);
```

### ⏱️ Timer

```typescript
Templates.Timer.start(attributes, durationSeconds);
```

## Customize the Widget

The widget UI is in Swift/SwiftUI. Edit:

```
ios/WidgetExtension/RideTrackingWidget.swift
```

Example:

```swift
struct RideTrackingLockScreenView: View {
    let context: ActivityViewContext<RideTrackingAttributes>

    var body: some View {
        VStack {
            Text(context.attributes.driverName)
                .font(.headline)
            Text(context.state.status)
                .font(.subheadline)
        }
        .padding()
    }
}
```

## Next Steps

- ✅ You have a working Live Activity!
- 📚 Read [Full Documentation](../README.md)
- 🎨 [Customize the UI](./SWIFTUI.md)
- 📖 See [More Examples](./EXAMPLES.md)
- 🔔 Setup [Push Notifications](./PUSH_NOTIFICATIONS.md)

## Common Next Actions

### Add Error Handling

```typescript
try {
  const id = await LiveActivities.startActivity({...});
} catch (error) {
  if (error.code === 'E_NOT_ENABLED') {
    // User disabled Live Activities
  } else if (error.code === 'E_NOT_SUPPORTED') {
    // iOS version too old
  }
}
```

### Store Activity ID

```typescript
import AsyncStorage from '@react-native-async-storage/async-storage';

const id = await LiveActivities.startActivity({...});
await AsyncStorage.setItem('currentActivity', id);

// Later
const storedId = await AsyncStorage.getItem('currentActivity');
if (storedId) {
  await LiveActivities.updateActivity(storedId, {...});
}
```

### Clean Up on Unmount

```typescript
useEffect(() => {
  return () => {
    if (activityId) {
      LiveActivities.endActivity(activityId);
    }
  };
}, [activityId]);
```

---

**🎉 Congratulations! You've implemented Live Activities!**

Need help? Check [Troubleshooting](./TROUBLESHOOTING.md) or [create an issue](https://github.com/yourusername/react-native-live-activities/issues).
