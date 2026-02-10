# 📚 API Documentation

Complete reference for all available methods and types.

## Table of Contents

- [LiveActivities Class](#liveactivities-class)
- [Types](#types)
- [Templates](#templates)
- [Error Handling](#error-handling)

## LiveActivities Class

### `areActivitiesEnabled()`

Check if Live Activities are supported and enabled on the device.

**Returns**: `Promise<boolean>`

**Example**:

```typescript
const enabled = await LiveActivities.areActivitiesEnabled();
if (enabled) {
  // Start activities
} else {
  // Show fallback UI
}
```

---

### `startActivity<T>(config: ActivityConfig<T>)`

Start a new Live Activity.

**Parameters**:

- `config.activityType` (string): Identifier matching your ActivityAttributes
- `config.attributes` (T): Static data that won't change
- `config.contentState` (object): Dynamic data that can be updated
- `config.staleDate` (number, optional): Unix timestamp when activity becomes stale
- `config.relevanceScore` (number, optional): 0-100, affects ordering

**Returns**: `Promise<string>` - Activity ID

**Example**:

```typescript
const activityId = await LiveActivities.startActivity({
  activityType: 'RideTracking',
  attributes: {
    driverName: 'John Doe',
    vehicleNumber: 'ABC-1234',
    pickup: 'Times Square',
    dropoff: 'Central Park',
  },
  contentState: {
    status: 'on-the-way',
    estimatedArrival: Date.now() + 600000, // 10 min
  },
  staleDate: Date.now() + 3600000, // 1 hour
  relevanceScore: 80,
});
```

---

### `updateActivity(activityId: string, config: UpdateConfig)`

Update an existing Live Activity.

**Parameters**:

- `activityId` (string): ID returned from startActivity
- `config.contentState` (object): Updated dynamic data
- `config.alertConfig` (object, optional): Alert configuration
  - `title` (string, optional): Alert title
  - `body` (string, optional): Alert body
  - `sound` (string, optional): Alert sound
- `config.staleDate` (number, optional): Updated stale date

**Returns**: `Promise<void>`

**Example**:

```typescript
await LiveActivities.updateActivity(activityId, {
  contentState: {
    status: 'arriving',
    estimatedArrival: Date.now() + 120000, // 2 min
  },
  alertConfig: {
    title: 'Driver Nearby',
    body: 'Your driver is arriving in 2 minutes',
    sound: 'default',
  },
});
```

---

### `endActivity(activityId: string, config?: EndConfig)`

End a Live Activity.

**Parameters**:

- `activityId` (string): Activity ID
- `config.finalContent` (object, optional): Final state to display
- `config.dismissalPolicy` ('immediate' | 'after-date' | 'default', optional): When to dismiss

**Returns**: `Promise<void>`

**Example**:

```typescript
await LiveActivities.endActivity(activityId, {
  finalContent: {
    status: 'completed',
    message: 'Ride completed successfully!',
  },
  dismissalPolicy: 'after-date', // Stay for a while
});
```

---

### `getActiveActivities()`

Get all active Live Activity IDs.

**Returns**: `Promise<string[]>`

**Example**:

```typescript
const activeIds = await LiveActivities.getActiveActivities();
console.log(`${activeIds.length} active activities`);
```

---

### `endAllActivities()`

End all active Live Activities.

**Returns**: `Promise<void>`

**Example**:

```typescript
await LiveActivities.endAllActivities();
```

---

### `getPushToken(activityId: string)`

Get the APNs push token for a specific activity (for remote updates).

**Returns**: `Promise<string | null>`

**Example**:

```typescript
const token = await LiveActivities.getPushToken(activityId);
if (token) {
  // Send to your server for push notifications
  await sendToServer({ activityId, pushToken: token });
}
```

## Types

### ActivityConfig<T>

```typescript
interface ActivityConfig<T = any> {
  activityType: string;
  attributes: T;
  contentState: Record<string, any>;
  staleDate?: number;
  relevanceScore?: number;
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

## Templates

Pre-built templates for common use cases.

### RideTracking

```typescript
import { Templates } from 'react-native-live-activities';

// Start
const activityId = await Templates.RideTracking.start(
  {
    driverName: 'John Doe',
    vehicleNumber: 'ABC-1234',
    pickup: 'Times Square',
    dropoff: 'Central Park',
  },
  {
    status: 'on-the-way',
    estimatedArrival: Date.now() + 600000,
  }
);

// Update
await Templates.RideTracking.update(activityId, {
  status: 'arriving',
  estimatedArrival: Date.now() + 120000,
});

// Complete
await Templates.RideTracking.complete(activityId);
```

### DeliveryTracking

```typescript
const activityId = await Templates.DeliveryTracking.start(
  {
    courierName: 'Jane Smith',
    orderNumber: '#12345',
  },
  {
    status: 'out-for-delivery',
    estimatedArrival: Date.now() + 900000,
  }
);

await Templates.DeliveryTracking.update(activityId, {
  status: 'nearby',
  stopsRemaining: 2,
});

await Templates.DeliveryTracking.complete(activityId, true);
```

### SportsScore

```typescript
const activityId = await Templates.SportsScore.start(
  {
    homeTeam: 'Lakers',
    awayTeam: 'Warriors',
  },
  {
    homeScore: 98,
    awayScore: 95,
    period: 'Q4',
    timeRemaining: '2:30',
    isLive: true,
  }
);

await Templates.SportsScore.update(activityId, {
  homeScore: 100,
  awayScore: 95,
});

await Templates.SportsScore.endGame(activityId);
```

### Timer

```typescript
const activityId = await Templates.Timer.start(
  {
    title: 'Workout Timer',
    description: 'HIIT Session',
  },
  1800 // 30 minutes in seconds
);

await Templates.Timer.pause(activityId);
await Templates.Timer.resume(activityId, 900); // 15 min remaining
await Templates.Timer.complete(activityId);
```

## Error Handling

All methods can throw errors. Always use try-catch:

```typescript
try {
  const activityId = await LiveActivities.startActivity({...});
} catch (error) {
  console.error('Failed to start activity:', error);

  if (error.code === 'E_NOT_SUPPORTED') {
    // iOS version too old
  } else if (error.code === 'E_NOT_ENABLED') {
    // User disabled Live Activities
  } else {
    // Other error
  }
}
```

### Error Codes

| Code              | Description                      |
| ----------------- | -------------------------------- |
| `E_NOT_SUPPORTED` | iOS version < 16.1               |
| `E_NOT_ENABLED`   | Live Activities disabled by user |
| `E_INVALID_TYPE`  | Unknown activity type            |
| `E_START_FAILED`  | Failed to start activity         |
| `E_UPDATE_FAILED` | Failed to update activity        |
| `E_END_FAILED`    | Failed to end activity           |
| `E_NOT_FOUND`     | Activity ID not found            |

## Best Practices

### 1. Check Availability First

```typescript
const enabled = await LiveActivities.areActivitiesEnabled();
if (!enabled) {
  // Show alternative UI
  return;
}
```

### 2. Store Activity IDs

```typescript
// Use AsyncStorage or state management
import AsyncStorage from '@react-native-async-storage/async-storage';

const activityId = await LiveActivities.startActivity({...});
await AsyncStorage.setItem('currentRideActivity', activityId);
```

### 3. Handle Cleanup

```typescript
useEffect(() => {
  return () => {
    // End activity when component unmounts
    if (activityId) {
      LiveActivities.endActivity(activityId);
    }
  };
}, [activityId]);
```

### 4. Rate Limiting

Don't update too frequently:

```typescript
// Throttle updates to every 5 seconds
const throttledUpdate = useCallback(
  throttle(async (data) => {
    await LiveActivities.updateActivity(activityId, { contentState: data });
  }, 5000),
  [activityId]
);
```

## Platform-Specific Notes

- **iOS Only**: All methods gracefully handle Android (return false/empty/throw on Android)
- **Physical Device**: Some features may not work in simulator
- **Permissions**: Live Activities don't require user permission, but can be disabled in Settings

## Next Steps

- [SwiftUI Customization](./SWIFTUI.md) - Design your widget UI
- [Push Notifications](./PUSH_NOTIFICATIONS.md) - Remote updates via APNs
- [Examples](./EXAMPLES.md) - Complete working examples
