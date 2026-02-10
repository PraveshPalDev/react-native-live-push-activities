# 🚀 React Native Live Activities

[![npm version](https://badge.fury.io/js/react-native-live-activities.svg)](https://badge.fury.io/js/react-native-live-activities)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**Easy-to-use iOS Live Activities implementation for React Native CLI and Expo with real-time push notifications.**

Show real-time updates directly on the Lock Screen and Dynamic Island with minimal configuration!

<div align="center">
  <img src="./docs/assets/demo.gif" alt="Live Activities Demo" width="300"/>
</div>

## ✨ Features

- 🎯 **Easy Integration** - Just a few lines of code to get started
- 🔄 **Real-time Updates** - Push updates via APNs or locally
- 📱 **Dynamic Island** - Beautiful animations in the Dynamic Island
- 🔒 **Lock Screen** - Persistent widgets on Lock Screen
- ⚙️ **Auto Configuration** - Automatic setup for both React Native CLI and Expo
- 📚 **TypeScript Support** - Full type safety
- 🎨 **Fully Customizable** - Design your own Live Activity UI
- 🚗 **Pre-built Templates** - Ride tracking, delivery, sports scores, and more

## 📋 Requirements

- iOS 16.1+ (Live Activities minimum requirement)
- React Native 0.60+
- For Expo: SDK 48+

## 📦 Installation

### React Native CLI

```bash
npm install react-native-live-activities
# or
yarn add react-native-live-activities
```

### Expo

```bash
npx expo install react-native-live-activities
```

## 🔧 Configuration

### Automatic Configuration (Recommended)

Run the configuration script:

```bash
npx react-native-live-activities-setup
```

This will:

- ✅ Create Widget Extension target
- ✅ Configure Info.plist
- ✅ Set deployment targets
- ✅ Add necessary capabilities
- ✅ Generate template files

### Manual Configuration

If you prefer manual setup, follow our [detailed configuration guide](./docs/CONFIGURATION.md).

## 🚀 Quick Start

### 1. Define Your Live Activity Attributes

```tsx
import { LiveActivities } from 'react-native-live-activities';

// Define your activity attributes
interface RideActivityAttributes {
  driverName: string;
  vehicleNumber: string;
  estimatedArrival: number;
}

// Start a Live Activity
const startRideActivity = async () => {
  try {
    const activityId =
      await LiveActivities.startActivity<RideActivityAttributes>({
        activityType: 'RideTracking',
        attributes: {
          driverName: 'John Doe',
          vehicleNumber: 'ABC-1234',
          estimatedArrival: Date.now() + 600000, // 10 minutes
        },
        contentState: {
          status: 'On the way',
          currentLocation: 'Downtown',
        },
      });

    console.log('Live Activity started:', activityId);
  } catch (error) {
    console.error('Failed to start activity:', error);
  }
};
```

### 2. Update in Real-time

```tsx
// Update activity with new data
await LiveActivities.updateActivity(activityId, {
  status: 'Arriving soon',
  currentLocation: 'Near your location',
  estimatedArrival: Date.now() + 120000, // 2 minutes
});
```

### 3. End the Activity

```tsx
// End the activity
await LiveActivities.endActivity(activityId, {
  finalStatus: 'Ride completed',
});
```

## 🎨 Customizing the Widget UI (SwiftUI)

The package automatically generates a widget extension. Customize the UI in:

```
ios/WidgetExtension/RideActivityWidget.swift
```

Example SwiftUI code:

```swift
struct RideActivityView: View {
    let context: ActivityViewContext<RideActivityAttributes>

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("\\(context.attributes.driverName)")
                    .font(.headline)
                Text(context.state.status)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing) {
                Text("ETA")
                    .font(.caption)
                Text(timeRemaining)
                    .font(.title2)
                    .bold()
            }
        }
        .padding()
    }
}
```

## 📱 Push Notifications for Updates

Send real-time updates via APNs:

```json
{
  "aps": {
    "timestamp": 1234567890,
    "event": "update",
    "content-state": {
      "status": "Arriving soon",
      "currentLocation": "1 block away",
      "estimatedArrival": 1234567900
    }
  }
}
```

## 🎯 Pre-built Templates

We provide ready-to-use templates:

### Ride Tracking

```tsx
import { Templates } from 'react-native-live-activities';

await Templates.RideTracking.start({
  driverName: 'John Doe',
  vehicleNumber: 'ABC-1234',
  pickup: 'Times Square',
  dropoff: 'Central Park',
  eta: 10,
});
```

### Delivery Tracking

```tsx
await Templates.DeliveryTracking.start({
  courierName: 'Jane Smith',
  orderNumber: '#12345',
  currentStatus: 'Out for delivery',
  eta: 15,
});
```

### Sports Score

```tsx
await Templates.SportsScore.start({
  homeTeam: 'Lakers',
  awayTeam: 'Warriors',
  homeScore: 98,
  awayScore: 95,
  quarter: 4,
});
```

## 📖 API Reference

### LiveActivities

#### `startActivity<T>(config: ActivityConfig<T>): Promise<string>`

Start a new Live Activity

#### `updateActivity(id: string, contentState: any): Promise<void>`

Update an existing Live Activity

#### `endActivity(id: string, finalContent?: any): Promise<void>`

End a Live Activity

#### `getActiveActivities(): Promise<string[]>`

Get all active activity IDs

#### `areActivitiesEnabled(): Promise<boolean>`

Check if Live Activities are enabled

## 🛠️ Troubleshooting

### Live Activity not appearing?

1. **Check deployment target**: Ensure both your app and widget extension have iOS 16.1+ as minimum deployment target
2. **Verify Info.plist**: Make sure `NSSupportsLiveActivities` is set to `YES`
3. **Check device**: Live Activities only work on physical devices with iOS 16.1+
4. **Review logs**: Check Xcode console for any error messages

### Common Issues

| Issue                            | Solution                                       |
| -------------------------------- | ---------------------------------------------- |
| Activity starts but doesn't show | Verify deployment targets match (app & widget) |
| Build fails                      | Run `pod install` after installation           |
| Updates not reflecting           | Ensure `activityId` is correct                 |

See our [troubleshooting guide](./docs/TROUBLESHOOTING.md) for more details.

## 📚 Documentation

- [Complete Setup Guide](./docs/SETUP.md)
- [Configuration Reference](./docs/CONFIGURATION.md)
- [API Documentation](./docs/API.md)
- [SwiftUI Customization](./docs/SWIFTUI.md)
- [Push Notifications](./docs/PUSH_NOTIFICATIONS.md)
- [Examples](./docs/EXAMPLES.md)

## 🎬 Example App

Clone and run the example app:

```bash
git clone https://github.com/yourusername/react-native-live-activities
cd react-native-live-activities/example
yarn install
cd ios && pod install && cd ..
yarn ios
```

## 🤝 Contributing

Contributions are welcome! Please read our [contributing guidelines](./CONTRIBUTING.md).

## 📄 License

MIT © [Your Name]

## 🙏 Acknowledgments

Built with insights from implementing real-world Live Activities. Special thanks to the React Native community!

---

**Made with ❤️ for the React Native community**

If this package helped you, please ⭐️ the repo!
