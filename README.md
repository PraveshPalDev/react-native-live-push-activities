# React Native Live Push Activities

A cross-platform library for iOS Live Activities (Dynamic Island & Lock Screen) with Android notification support.

## Features

- **iOS 16.1+ Live Activities** - Dynamic Island and Lock Screen widgets
- **Push Notification Updates** - Update activities remotely via APNs/FCM
- **Pre-built Templates** - Quick Commerce, Food Delivery, E-commerce, and more
- **Custom Activities** - Send any JSON data structure
- **Android Support** - Foreground service notifications with live updates
- **TypeScript First** - Fully typed API
- **Expo Compatible** - Works with Expo Development Builds

## Installation

```bash
npm install react-native-live-push-activities
# or
yarn add react-native-live-push-activities
```

### iOS Setup

```bash
cd ios && pod install
```

### Android Setup

No additional setup required. The library includes native Android implementation.

---

## Quick Start

### Check if Live Activities are enabled

```typescript
import LiveActivities from 'react-native-live-push-activities';

const isEnabled = await LiveActivities.areActivitiesEnabled();
```

### Basic Activity Lifecycle

```typescript
// Start an activity
const activityId = await LiveActivities.startActivity({
  activityType: 'QuickCommerce',
  attributes: { orderId: 'ORD-123' },
  contentState: { status: 'confirmed', progress: 0 },
});

// Update the activity
await LiveActivities.updateActivity(activityId, {
  contentState: { status: 'on_the_way', progress: 70 },
});

// End the activity
await LiveActivities.endActivity(activityId, {
  dismissalPolicy: 'immediate',
});
```

---

## Pre-built Templates

### Quick Commerce (Zepto-style)

10-minute delivery tracking with countdown timer.

```typescript
import { QuickCommerceDelivery } from 'react-native-live-push-activities';

// Start tracking
const activityId = await QuickCommerceDelivery.start(
  {
    orderId: 'ORD-12345',
    items: 'Groceries, Milk, Bread',
    deepLink: 'myapp://order/ORD-12345',
  },
  {
    status: 'confirmed',
    progress: 0,
    estimatedMinutes: 10,
  }
);

// Update with rider info
await QuickCommerceDelivery.update(activityId, {
  status: 'on_the_way',
  progress: 60,
  estimatedMinutes: 4,
  riderName: 'Rahul Kumar',
  riderPhone: '+91-9876543210',
  riderPhoto: 'https://example.com/rider.jpg',
  currentLocation: 'Near Main Market',
});

// Mark as delivered
await QuickCommerceDelivery.complete(activityId);

// Or cancel
await QuickCommerceDelivery.cancel(activityId);
```

### Food Delivery (Swiggy/Zomato-style)

Restaurant order tracking with multiple stages.

```typescript
import { FoodDelivery } from 'react-native-live-push-activities';

const activityId = await FoodDelivery.start(
  {
    orderId: 'FD-789',
    restaurantName: 'Pizza Palace',
    restaurantLogo: 'https://example.com/logo.png',
    orderItems: 'Margherita Pizza, Garlic Bread',
    deliveryAddress: '123 Main St',
    deepLink: 'myapp://order/FD-789',
  },
  {
    status: 'confirmed',
    statusStage: 0, // 0=Confirmed, 1=Preparing, 2=Picked Up, 3=On the Way, 4=Delivered
    estimatedMinutes: 30,
  }
);

// Update stage
await FoodDelivery.update(activityId, {
  status: 'on_the_way',
  statusStage: 3,
  estimatedMinutes: 10,
  riderName: 'Amit Singh',
  riderPhone: '+91-9988776655',
});
```

### E-commerce Delivery (Amazon/Flipkart-style)

Multi-day package tracking.

```typescript
import { EcommerceDelivery } from 'react-native-live-push-activities';

const activityId = await EcommerceDelivery.start(
  {
    orderId: 'EC-456',
    productName: 'Wireless Headphones',
    productImage: 'https://example.com/product.jpg',
    courierPartner: 'BlueDart',
    trackingUrl: 'https://track.example.com/EC-456',
  },
  {
    status: 'shipped',
    statusStage: 1, // 0=Ordered, 1=Shipped, 2=In Transit, 3=Out for Delivery, 4=Delivered
    estimatedDeliveryDate: Date.now() + 3 * 24 * 60 * 60 * 1000, // 3 days
    trackingNumber: 'BD123456789',
    currentHub: 'Mumbai Distribution Center',
  }
);
```

### Other Templates

```typescript
import { Templates } from 'react-native-live-push-activities';

// Ride Tracking (Uber/Ola-style)
const rideId = await Templates.RideTracking.start(
  {
    driverName: 'John Doe',
    vehicleNumber: 'MH 01 AB 1234',
    vehicleType: 'Sedan',
    pickup: 'Location A',
    dropoff: 'Location B',
  },
  {
    status: 'on-the-way',
    estimatedArrival: Date.now() + 300000, // 5 minutes
  }
);

// Sports Score
const matchId = await Templates.SportsScore.start(
  {
    homeTeam: 'India',
    awayTeam: 'Australia',
    league: 'World Cup',
  },
  {
    homeScore: 245,
    awayScore: 189,
    period: '2nd Innings',
    isLive: true,
  }
);

// Timer
const timerId = await Templates.Timer.start(
  { title: 'Oven Timer', description: 'Baking cookies' },
  600 // 10 minutes in seconds
);
```

---

## Custom Activities

For complete flexibility, create your own activity type:

```typescript
import LiveActivities from 'react-native-live-push-activities';

// Define your custom attributes
interface FlightAttributes {
  flightNumber: string;
  airline: string;
  departure: string;
  arrival: string;
}

// Start custom activity
const activityId = await LiveActivities.startActivity<FlightAttributes>({
  activityType: 'FlightStatus',
  attributes: {
    flightNumber: 'AI-123',
    airline: 'Air India',
    departure: 'DEL',
    arrival: 'BOM',
  },
  contentState: {
    status: 'boarding',
    gate: 'A12',
    scheduledTime: Date.now() + 1800000,
  },
});
```

---

## Push Notification Updates

Update activities from your server using push notifications.

### Generate Payloads

```typescript
import { PushNotificationHelper } from 'react-native-live-push-activities';

// iOS APNs payload
const iosPayload = PushNotificationHelper.generateIOSPayload(
  'activity-123',
  'push-token-abc',
  { status: 'delivered', progress: 100 },
  { title: 'Order Delivered!', body: 'Your order has arrived.' }
);

// Android FCM payload
const androidPayload = PushNotificationHelper.generateAndroidPayload(
  'notification-123',
  'QuickCommerce',
  { status: 'on_the_way', progress: 70 }
);

// Template-specific payloads
const quickCommercePayload = PushNotificationHelper.generateQuickCommerceUpdate(
  { status: 'on_the_way', progress: 70, estimatedMinutes: 4 },
  { title: 'On the way!', body: 'Your order will arrive soon.' }
);
```

### Get Push Token

```typescript
const pushToken = await LiveActivities.getPushToken(activityId);
// Send this token to your server for push updates
```

---

## API Reference

### LiveActivities Class

| Method | Description | Returns |
|--------|-------------|---------|
| `areActivitiesEnabled()` | Check if Live Activities are available | `Promise<boolean>` |
| `startActivity(config)` | Start a new activity | `Promise<string>` |
| `updateActivity(id, config)` | Update an existing activity | `Promise<void>` |
| `endActivity(id, config?)` | End an activity | `Promise<void>` |
| `getActiveActivities()` | Get all active activity IDs | `Promise<string[]>` |
| `endAllActivities()` | End all active activities | `Promise<void>` |
| `getPushToken(id)` | Get push token for server updates | `Promise<string \| null>` |

### ActivityConfig

```typescript
interface ActivityConfig<T> {
  activityType: string;           // Template type identifier
  attributes: T;                  // Static attributes (set once)
  contentState: Record<string, any>; // Dynamic content (updatable)
  staleDate?: number;             // When activity becomes stale
  relevanceScore?: number;        // 0-1 score for ranking
}
```

### UpdateConfig

```typescript
interface UpdateConfig {
  contentState: Record<string, any>;
  alertConfig?: {
    title?: string;
    body?: string;
    sound?: string;
  };
  staleDate?: number;
}
```

### EndConfig

```typescript
interface EndConfig {
  finalContent?: Record<string, any>;
  dismissalPolicy?: 'immediate' | 'after-date' | 'default';
}
```

---

## iOS Native Setup

### 1. Enable Capabilities

In Xcode, add to your `Info.plist`:

```xml
<key>NSSupportsLiveActivities</key>
<true/>
```

### 2. Create Widget Extension

1. **File > New > Target** > **Widget Extension**
2. Enable **"Include Live Activity"**
3. Name it (e.g., `DeliveryWidget`)

### 3. Define Activity Attributes

Create `ActivityAttributes.swift` in your Widget Extension:

```swift
import ActivityKit
import SwiftUI

public struct QuickCommerceAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var status: String
        var progress: Double
        var estimatedMinutes: Int
        var riderName: String?
        var riderPhone: String?
        var riderPhoto: String?
        var currentLocation: String?
    }
    var orderId: String
    var items: String?
    var deepLink: String?
}
```

### 4. Create Activity UI

```swift
@main
struct DeliveryWidgetBundle: WidgetBundle {
    var body: some Widget {
        QuickCommerceWidget()
    }
}

struct QuickCommerceWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: QuickCommerceAttributes.self) { context in
            VStack {
                Text("Order \(context.attributes.orderId)")
                Text(context.state.status)
                ProgressView(value: context.state.progress)
            }
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.center) {
                    Text("\(context.state.estimatedMinutes) min")
                }
            } compactLeading: {
                Text("📦")
            } compactTrailing: {
                Text("\(Int(context.state.progress))%")
            } minimal: {
                Text("📦")
            }
        }
    }
}
```

---

## Android Implementation

The library provides a foreground service with notification updates on Android.

### Features

- Persistent notification tracking
- Progress bar updates
- Rider/delivery information
- Deep link support
- Multiple concurrent deliveries

### Notification Layouts

Custom layouts are provided for each template:
- `notification_quick_commerce.xml`
- `notification_food_delivery.xml`
- `notification_ecommerce.xml`

---

## Expo Usage

1. Install the package:
   ```bash
   npx expo install react-native-live-push-activities
   ```

2. Generate native projects:
   ```bash
   npx expo prebuild
   ```

3. Open `ios/YourApp.xcworkspace` and set up the Widget Extension

4. Run the app:
   ```bash
   npx expo run:ios
   ```

---

## Troubleshooting

### CocoaPods Installation Issues

**Error: "required a higher minimum deployment target"**

Update your `ios/Podfile`:

```ruby
platform :ios, '13.0'

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
    end
  end
end
```

> **Note**: Live Activities require iOS 16.1+, but the package installs on iOS 13.0+.

### Push Token is nil

- Test on a **real device** (simulators don't receive push tokens)
- Ensure Push Notification capability is enabled
- Request notification permissions before starting activity

### Updates Not Showing

- Verify the `activityId` exists using `getActiveActivities()`
- Check that Widget UI reads correct fields from `context.state`
- Ensure `activityType` matches your Swift struct name

### Android Notifications Not Updating

- Check notification permissions are granted
- Verify the foreground service is running
- Check logcat for any errors in `DeliveryTrackingService`

---

## Contributing

1. Check for existing issues or open a new one
2. Fork the repository and create your branch from `main`
3. Link your Pull Request to an issue
4. Wait for review

See [Contributing Guide](.github/CONTRIBUTING.md) for details.

---

## License

MIT
