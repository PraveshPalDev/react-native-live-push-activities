# 🎬 Example App

This example app demonstrates all features of `react-native-live-activities`.

## Features Demonstrated

- ✅ Starting Live Activities
- ✅ Updating activities in real-time
- ✅ Ending activities
- ✅ Using pre-built templates
- ✅ Custom UI inputs
- ✅ Error handling

## Running the Example

### Prerequisites

- macOS with Xcode 14+
- iOS device with iOS 16.1+ (Live Activities don't work well in simulator)
- Node.js 14+

### Setup

1. **Install dependencies**:

   ```bash
   yarn install
   ```

2. **Install pods**:

   ```bash
   cd ios && pod install && cd ..
   ```

3. **Run on iOS**:
   ```bash
   yarn ios
   ```

## Testing Live Activities

### Ride Tracking

1. **Start Activity**: Enter driver details and tap "Start Ride Activity"
2. **Check Lock Screen**: Lock your device to see the Live Activity
3. **Update Status**: Tap "Update: On the Way" to update the activity
4. **Check Dynamic Island**: On iPhone 14 Pro+, see the compact view
5. **Complete**: Tap "Complete Ride" to end the activity

### Delivery Tracking

1. Tap "Start Delivery Tracking"
2. The activity will auto-update after 5 seconds
3. Watch the status change on your Lock Screen

### Sports Score

1. Tap "Start Sports Score"
2. The score will update after 5 seconds
3. See real-time score updates

## Project Structure

```
example/
├── App.tsx              # Main example app
├── ios/
│   ├── Example/         # Main app
│   └── WidgetExtension/ # Widget Extension (created during setup)
├── package.json
└── README.md
```

## Troubleshooting

### Activity Not Appearing?

1. **Check device**: Must be iOS 16.1+ physical device
2. **Check deployment target**: Both app and widget must be iOS 16.1+
3. **Check Info.plist**: NSSupportsLiveActivities must be YES
4. **Check Xcode console**: Look for error messages

### Build Errors?

1. Clean build: `cd ios && rm -rf build && cd ..`
2. Reinstall pods: `cd ios && pod deintegrate && pod install && cd ..`
3. Clear Metro cache: `yarn start --reset-cache`

## Code Examples

### Basic Usage

```typescript
import LiveActivities from 'react-native-live-activities';

// Start activity
const activityId = await LiveActivities.startActivity({
  activityType: 'RideTracking',
  attributes: {
    driverName: 'John Doe',
    vehicleNumber: 'ABC-1234',
  },
  contentState: {
    status: 'waiting',
    estimatedArrival: Date.now() + 600000,
  },
});

// Update activity
await LiveActivities.updateActivity(activityId, {
  contentState: {
    status: 'on-the-way',
  },
});

// End activity
await LiveActivities.endActivity(activityId);
```

### Using Templates

```typescript
import { Templates } from 'react-native-live-activities';

const activityId = await Templates.RideTracking.start(
  { driverName: 'John', vehicleNumber: 'ABC' },
  { status: 'waiting', estimatedArrival: Date.now() + 600000 }
);

await Templates.RideTracking.update(activityId, {
  status: 'arriving',
});

await Templates.RideTracking.complete(activityId);
```

## Screenshots

<div align="center">
  <img src="../docs/assets/demo-app.png" alt="Demo App" width="250"/>
  <img src="../docs/assets/lockscreen.png" alt="Lock Screen" width="250"/>
  <img src="../docs/assets/dynamic-island.png" alt="Dynamic Island" width="250"/>
</div>

## Learn More

- [Full Documentation](../README.md)
- [API Reference](../docs/API.md)
- [Setup Guide](../docs/SETUP.md)
- [SwiftUI Customization](../docs/SWIFTUI.md)
