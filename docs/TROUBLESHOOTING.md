# 🛠️ Troubleshooting Guide

Solutions to common issues when implementing Live Activities.

## Table of Contents

- [Live Activity Not Appearing](#live-activity-not-appearing)
- [Build Errors](#build-errors)
- [Runtime Errors](#runtime-errors)
- [Update Issues](#update-issues)
- [Push Notification Issues](#push-notification-issues)

## Live Activity Not Appearing

### Issue: Activity starts successfully but doesn't show on UI

This is the **most common issue** and was mentioned in your original post!

#### Root Cause

**Deployment target mismatch** between main app and widget extension.

#### Solution

1. **Open Xcode**
2. **Select your project** in navigator
3. **For BOTH targets** (main app AND widget extension):
   - Click on **Build Settings**
   - Search for "deployment target"
   - Set **iOS Deployment Target** to **16.1** or higher
   - **CRITICAL**: Both must have the EXACT same version

```
Main App Target: iOS 16.1
Widget Extension: iOS 16.1  ✅ MUST MATCH
```

#### Verification Steps

After fixing deployment targets:

1. Clean build folder: **Product > Clean Build Folder** (⌘⇧K)
2. Delete derived data: **~/Library/Developer/Xcode/DerivedData**
3. Run `cd ios && pod install`
4. Rebuild and run

---

### Issue: No error in logs but activity invisible

#### Possible Causes

1. **Info.plist not configured**
   - Check main app's Info.plist
   - Must have `NSSupportsLiveActivities = YES`
2. **Testing on Simulator**
   - Live Activities have limited support in simulator
   - **Always test on physical device with iOS 16.1+**

3. **Widget Extension not added to project**
   - Verify Widget Extension exists in Xcode
   - Check it's included in build target

4. **Bundle Identifier mismatch**
   - Main app: `com.company.app`
   - Widget: `com.company.app.WidgetExtension`
   - Widget MUST be a child of main app

---

## Build Errors

### Error: "Cannot find module 'react-native-live-activities'"

#### Solutions

1. **Reinstall package**:

   ```bash
   npm install react-native-live-activities
   # or
   yarn add react-native-live-activities
   ```

2. **Install pods**:

   ```bash
   cd ios && pod install && cd ..
   ```

3. **Clear cache**:
   ```bash
   npm start -- --reset-cache
   ```

---

### Error: "Undefined symbol: _OBJC_CLASS_$\_LiveActivities"

#### Solutions

1. **Add Swift bridging header** (if you have Objective-C code):
   - Create `YourProject-Bridging-Header.h`
   - Add to Build Settings > Swift Compiler > Objective-C Bridging Header

2. **Check pod installation**:

   ```bash
   cd ios
   pod deintegrate
   pod install
   cd ..
   ```

3. **Verify file is in compile sources**:
   - In Xcode: Target > Build Phases > Compile Sources
   - Ensure `LiveActivities.swift` is listed

---

### Error: "ActivityKit module not found"

#### Solution

ActivityKit requires iOS 16.1+. Check:

1. **Deployment target** is 16.1+
2. **No @available checks blocking import**
3. **Correct import statement**:
   ```swift
   import ActivityKit
   ```

---

## Runtime Errors

### Error: "E_NOT_SUPPORTED"

```
Live Activities require iOS 16.1 or higher
```

#### Solutions

1. **Check iOS version**:

   ```typescript
   if (Platform.Version < '16.1') {
     // Show fallback UI
   }
   ```

2. **Always check before starting**:
   ```typescript
   const enabled = await LiveActivities.areActivitiesEnabled();
   if (!enabled) {
     Alert.alert('Not Supported', 'Requires iOS 16.1+');
     return;
   }
   ```

---

### Error: "E_NOT_ENABLED"

```
Live Activities are not enabled
```

#### Causes

1. User disabled in Settings > FaceTime > Live Activities
2. Low Power Mode is on
3. Focus mode restrictions

#### Solutions

```typescript
const enabled = await LiveActivities.areActivitiesEnabled();
if (!enabled) {
  Alert.alert(
    'Live Activities Disabled',
    'Please enable in Settings > FaceTime > Live Activities'
  );
}
```

---

### Error: "E_START_FAILED"

#### Common Causes

1. **Too many active activities** (iOS has a limit)
2. **Invalid attribute types**
3. **Memory constraints**

#### Solutions

```typescript
try {
  const activityId = await LiveActivities.startActivity({...});
} catch (error) {
  if (error.code === 'E_START_FAILED') {
    // End old activities first
    await LiveActivities.endAllActivities();
    // Retry
    const activityId = await LiveActivities.startActivity({...});
  }
}
```

---

## Update Issues

### Issue: Updates not reflecting in Live Activity

#### Possible Causes

1. **Wrong activity ID**
2. **Activity already ended**
3. **Invalid update data**

#### Solutions

1. **Store activity ID properly**:

   ```typescript
   // Use state or AsyncStorage
   const [activityId, setActivityId] = useState<string | null>(null);

   const id = await LiveActivities.startActivity({...});
   setActivityId(id);

   // Later
   if (activityId) {
     await LiveActivities.updateActivity(activityId, {...});
   }
   ```

2. **Check activity still exists**:

   ```typescript
   const active = await LiveActivities.getActiveActivities();
   if (active.includes(activityId)) {
     await LiveActivities.updateActivity(activityId, {...});
   }
   ```

3. **Rate limiting**:
   - Don't update too frequently (max ~1/second)
   - iOS may throttle excessive updates

---

### Issue: Update causes crash

#### Solutions

1. **Validate data before updating**:

   ```typescript
   const contentState = {
     status: status || 'unknown',
     estimatedArrival: estimatedArrival || Date.now(),
   };

   await LiveActivities.updateActivity(id, { contentState });
   ```

2. **Handle dates correctly**:
   ```typescript
   // Use Unix timestamp (milliseconds)
   estimatedArrival: Date.now() + 600000, // 10 min
   ```

---

## Push Notification Issues

### Issue: Push updates not working

#### Prerequisites

1. **APNs certificate configured**
2. **Push notifications capability enabled**
3. **Push token obtained**

#### Solutions

1. **Get push token**:

   ```typescript
   const token = await LiveActivities.getPushToken(activityId);
   // Send to your server
   ```

2. **Correct APNs payload**:

   ```json
   {
     "aps": {
       "timestamp": 1234567890,
       "event": "update",
       "content-state": {
         "status": "arriving",
         "estimatedArrival": 1234567900
       }
     }
   }
   ```

3. **Use correct APNs endpoint**:
   - Development: `api.development.push.apple.com`
   - Production: `api.push.apple.com`

---

## Configuration Checklist

Use this checklist to verify your setup:

### Main App

- [ ] iOS Deployment Target: 16.1+
- [ ] Info.plist has `NSSupportsLiveActivities = YES`
- [ ] `react-native-live-activities` in package.json
- [ ] Pods installed (`pod install`)
- [ ] Bundle ID: `com.company.app`

### Widget Extension

- [ ] iOS Deployment Target: 16.1+ (SAME as main app)
- [ ] Bundle ID: `com.company.app.WidgetExtension`
- [ ] Target added to project
- [ ] ActivityAttributes.swift exists
- [ ] Widget files included in target

### Testing

- [ ] Physical device with iOS 16.1+
- [ ] Live Activities enabled in Settings
- [ ] Not in Low Power Mode
- [ ] Activity starts without errors

---

## Debug Logging

Enable detailed logging:

```typescript
// Add at app startup
if (__DEV__) {
  const originalLog = console.log;
  console.log = (...args) => {
    if (args[0]?.includes?.('LiveActivity')) {
      originalLog('[LA]', ...args);
    }
    originalLog(...args);
  };
}
```

Check Xcode console for Swift errors:

1. Open Xcode
2. Run app from Xcode (not CLI)
3. Watch Console tab for errors
4. Filter by "Activity" or "Widget"

---

## Still Having Issues?

1. **Check Examples**: Review the [example app](../example)
2. **Search Issues**: [GitHub Issues](https://github.com/yourusername/react-native-live-activities/issues)
3. **Create Issue**: Include:
   - iOS version
   - React Native version
   - Error messages
   - Deployment targets
   - Info.plist contents

---

## Success Checklist

✅ Deployment targets match (16.1+)  
✅ NSSupportsLiveActivities in Info.plist  
✅ Testing on physical device  
✅ Widget Extension in project  
✅ No build errors  
✅ areActivitiesEnabled() returns true  
✅ Activity starts without error  
✅ Activity visible on Lock Screen

If all checked, your setup is correct! 🎉
