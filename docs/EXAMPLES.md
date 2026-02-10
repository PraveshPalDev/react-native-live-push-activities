# 📚 Complete Examples

This document provides complete, working examples for various use cases.

## Table of Contents

- [Ride Tracking](#ride-tracking)
- [Food Delivery](#food-delivery)
- [Sports Scores](#sports-scores)
- [Workout Timer](#workout-timer)
- [Package Delivery](#package-delivery)
- [Custom Activity](#custom-activity)

---

## Ride Tracking

Complete example for ride-sharing apps (Uber, Lyft style).

### JavaScript Implementation

```typescript
import React, { useState } from 'react';
import { Button, Alert } from 'react-native';
import { Templates } from 'react-native-live-activities';

export function RideTrackingExample() {
  const [activityId, setActivityId] = useState<string | null>(null);

  const startRide = async () => {
    try {
      const id = await Templates.RideTracking.start(
        {
          driverName: 'John Doe',
          vehicleNumber: 'ABC-1234',
          vehicleType: 'Toyota Camry',
          pickup: '123 Main St, New York, NY',
          dropoff: '456 Park Ave, New York, NY',
          driverPhoto: 'https://example.com/driver.jpg',
        },
        {
          status: 'waiting',
          currentLocation: 'Driver is preparing',
          estimatedArrival: Date.now() + 10 * 60 * 1000, // 10 min
          distance: 2.5, // km
        }
      );

      setActivityId(id);
      Alert.alert('Success', 'Ride tracking started!');
    } catch (error) {
      Alert.alert('Error', error.message);
    }
  };

  const updateToOnTheWay = async () => {
    if (!activityId) return;

    await Templates.RideTracking.update(activityId, {
      status: 'on-the-way',
      currentLocation: '1 block away',
      estimatedArrival: Date.now() + 2 * 60 * 1000,
      distance: 0.2,
    });
  };

  const completeRide = async () => {
    if (!activityId) return;
    await Templates.RideTracking.complete(activityId);
    setActivityId(null);
  };

  return (
    <>
      <Button title="Start Ride" onPress={startRide} />
      {activityId && (
        <>
          <Button title="Driver On The Way" onPress={updateToOnTheWay} />
          <Button title="Complete Ride" onPress={completeRide} />
        </>
      )}
    </>
  );
}
```

### SwiftUI Widget

```swift
import WidgetKit
import SwiftUI
import ActivityKit

struct RideTrackingLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: RideTrackingAttributes.self) { context in
            // Lock Screen View
            VStack(spacing: 16) {
                // Driver Info
                HStack {
                    AsyncImage(url: URL(string: context.attributes.driverPhoto ?? "")) { image in
                        image.resizable()
                    } placeholder: {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                    }
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 4) {
                        Text(context.attributes.driverName)
                            .font(.headline)
                        Text(context.attributes.vehicleType ?? "Vehicle")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(context.attributes.vehicleNumber)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    VStack(alignment: .trailing) {
                        Text("ETA")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text(context.state.estimatedArrival, style: .timer)
                            .font(.title2)
                            .fontWeight(.bold)
                            .monospacedDigit()
                    }
                }

                Divider()

                // Route
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Label("Pickup", systemImage: "location.circle.fill")
                            .font(.caption2)
                            .foregroundColor(.green)
                        Text(context.attributes.pickup)
                            .font(.caption)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Image(systemName: "arrow.right")
                        .foregroundColor(.secondary)

                    VStack(alignment: .trailing, spacing: 4) {
                        Label("Drop-off", systemImage: "mappin.circle.fill")
                            .font(.caption2)
                            .foregroundColor(.red)
                        Text(context.attributes.dropoff)
                            .font(.caption)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }

                // Status
                HStack {
                    Circle()
                        .fill(statusColor(context.state.status))
                        .frame(width: 8, height: 8)
                    Text(context.state.status.capitalized)
                        .font(.subheadline)
                    Spacer()
                    if let distance = context.state.distance {
                        Text("\\(String(format: "%.1f", distance)) km away")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
            .padding()
            .activityBackgroundTint(Color.black.opacity(0.8))

        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    HStack {
                        Image(systemName: "car.fill")
                            .foregroundColor(.blue)
                        VStack(alignment: .leading) {
                            Text(context.attributes.driverName)
                                .font(.caption)
                                .fontWeight(.semibold)
                            Text(context.attributes.vehicleNumber)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing) {
                        Text("ETA")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text(context.state.estimatedArrival, style: .timer)
                            .font(.title3)
                            .fontWeight(.bold)
                            .monospacedDigit()
                    }
                }

                DynamicIslandExpandedRegion(.bottom) {
                    VStack(spacing: 8) {
                        HStack {
                            Text(context.state.status.capitalized)
                                .font(.callout)
                            Spacer()
                            if let distance = context.state.distance {
                                Text("\\(String(format: "%.1f", distance)) km")
                                    .font(.callout)
                                    .foregroundColor(.secondary)
                            }
                        }

                        ProgressView(value: min(1, 10 - (context.state.distance ?? 0)) / 10)
                            .tint(.blue)
                    }
                }

            } compactLeading: {
                Image(systemName: "car.fill")
                    .foregroundColor(.blue)

            } compactTrailing: {
                Text(context.state.estimatedArrival, style: .timer)
                    .font(.caption2)
                    .monospacedDigit()

            } minimal: {
                Image(systemName: "car.fill")
                    .foregroundColor(.blue)
            }
        }
    }

    func statusColor(_ status: String) -> Color {
        switch status {
        case "waiting": return .orange
        case "on-the-way": return .blue
        case "arriving": return .green
        default: return .gray
        }
    }
}
```

---

## Food Delivery

Track food delivery with restaurant and courier info.

```typescript
import { Templates } from 'react-native-live-activities';

const startFoodDelivery = async () => {
  const activityId = await Templates.DeliveryTracking.start(
    {
      courierName: 'Jane Smith',
      orderNumber: '#12345',
      orderItems: '2x Pizza, 1x Coke, 1x Salad',
      deliveryAddress: '789 Oak St, Apt 4B',
    },
    {
      status: 'preparing',
      currentLocation: 'Restaurant: Pizza Palace',
      estimatedArrival: Date.now() + 30 * 60 * 1000,
      stopsRemaining: 2,
    }
  );

  // Simulate status updates
  setTimeout(() => {
    Templates.DeliveryTracking.update(activityId, {
      status: 'out-for-delivery',
      currentLocation: 'On the way',
      stopsRemaining: 1,
    });
  }, 10000);

  setTimeout(() => {
    Templates.DeliveryTracking.update(activityId, {
      status: 'nearby',
      currentLocation: 'Arriving in 2 minutes',
      stopsRemaining: 0,
    });
  }, 25000);

  return activityId;
};
```

---

## Sports Scores

Live sports score tracking.

```typescript
const startGameTracking = async () => {
  const activityId = await Templates.SportsScore.start(
    {
      homeTeam: 'Lakers',
      awayTeam: 'Warriors',
      homeTeamLogo: 'https://example.com/lakers.png',
      awayTeamLogo: 'https://example.com/warriors.png',
      league: 'NBA',
    },
    {
      homeScore: 98,
      awayScore: 95,
      period: 'Q4',
      timeRemaining: '2:30',
      lastPlay: 'Lakers - 3PT by LeBron James',
      isLive: true,
    }
  );

  // Simulate score updates every 10 seconds
  const interval = setInterval(async () => {
    const newHomeScore = Math.floor(Math.random() * 3);
    await Templates.SportsScore.update(activityId, {
      homeScore: context.homeScore + newHomeScore,
      lastPlay: newHomeScore > 0 ? 'Lakers - 2PT' : 'Warriors - Turnover',
    });
  }, 10000);

  // End game after 5 minutes
  setTimeout(async () => {
    clearInterval(interval);
    await Templates.SportsScore.endGame(activityId);
  }, 300000);
};
```

---

## Workout Timer

HIIT workout timer with countdown.

```typescript
const startWorkout = async () => {
  const workoutDuration = 30 * 60; // 30 minutes in seconds

  const activityId = await Templates.Timer.start(
    {
      title: 'HIIT Workout',
      description: '30 min high-intensity interval training',
      icon: 'figure.run',
    },
    workoutDuration
  );

  return activityId;
};

const pauseWorkout = async (activityId: string, remainingSeconds: number) => {
  await Templates.Timer.pause(activityId);
};

const resumeWorkout = async (activityId: string, remainingSeconds: number) => {
  await Templates.Timer.resume(activityId, remainingSeconds);
};
```

---

## Custom Activity

Create a completely custom Live Activity.

### 1. Define Your Attributes (Swift)

```swift
import ActivityKit

struct CustomAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var message: String
        var progress: Double
        var timestamp: Date
    }

    var title: String
    var icon: String
}
```

### 2. Create Widget (Swift)

```swift
struct CustomLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: CustomAttributes.self) { context in
            VStack {
                HStack {
                    Image(systemName: context.attributes.icon)
                    Text(context.attributes.title)
                        .font(.headline)
                }

                Text(context.state.message)
                    .font(.subheadline)

                ProgressView(value: context.state.progress)
            }
            .padding()

        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.center) {
                    Text(context.state.message)
                }
            } compactLeading: {
                Image(systemName: context.attributes.icon)
            } compactTrailing: {
                Text("\\(Int(context.state.progress * 100))%")
            } minimal: {
                Image(systemName: context.attributes.icon)
            }
        }
    }
}
```

### 3. Use from React Native

```typescript
import LiveActivities from 'react-native-live-activities';

const activityId = await LiveActivities.startActivity({
  activityType: 'Custom',
  attributes: {
    title: 'My Custom Activity',
    icon: 'star.fill',
  },
  contentState: {
    message: 'Processing...',
    progress: 0.5,
    timestamp: Date.now(),
  },
});

// Update
await LiveActivities.updateActivity(activityId, {
  contentState: {
    message: 'Almost done!',
    progress: 0.9,
    timestamp: Date.now(),
  },
});

// End
await LiveActivities.endActivity(activityId);
```

---

## Best Practices

### 1. Always Check Availability

```typescript
const enabled = await LiveActivities.areActivitiesEnabled();
if (!enabled) {
  // Show alternative UI
  return;
}
```

### 2. Store Activity IDs

```typescript
import AsyncStorage from '@react-native-async-storage/async-storage';

const activityId = await LiveActivities.startActivity({...});
await AsyncStorage.setItem('activeActivity', activityId);

// Later, retrieve and update
const storedId = await AsyncStorage.getItem('activeActivity');
if (storedId) {
  await LiveActivities.updateActivity(storedId, {...});
}
```

### 3. Clean Up on Unmount

```typescript
useEffect(() => {
  return () => {
    if (activityId) {
      LiveActivities.endActivity(activityId);
    }
  };
}, [activityId]);
```

### 4. Handle Errors Gracefully

```typescript
try {
  await LiveActivities.startActivity({...});
} catch (error) {
  if (error.code === 'E_NOT_ENABLED') {
    Alert.alert(
      'Live Activities Disabled',
      'Enable in Settings > FaceTime > Live Activities'
    );
  }
}
```

---

## Next Steps

- [API Documentation](./API.md)
- [SwiftUI Customization](./SWIFTUI.md)
- [Troubleshooting](./TROUBLESHOOTING.md)
