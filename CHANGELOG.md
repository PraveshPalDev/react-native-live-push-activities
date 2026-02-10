# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-02-10

### Added

#### Core Features

- ✨ Complete iOS Live Activities implementation for React Native
- 🎯 Support for both React Native CLI and Expo projects
- 📱 Lock Screen and Dynamic Island integration
- 🔄 Real-time updates via local API and APNs push notifications
- 📚 Full TypeScript support with type safety

#### Templates

- 🚗 Ride Tracking template (Uber/Lyft style)
- 📦 Delivery Tracking template (food/package delivery)
- ⚽ Sports Score template (live game scores)
- ⏱️ Timer template (workouts, cooking, etc.)

#### Developer Tools

- 🛠️ Automatic setup script (`npx react-native-live-activities-setup`)
- 🔧 Expo config plugin for seamless integration
- 📝 Comprehensive documentation (Setup, API, Examples, Troubleshooting)
- 🎨 SwiftUI widget templates for easy customization

#### API Methods

- `areActivitiesEnabled()` - Check if Live Activities are supported
- `startActivity()` - Start a new Live Activity
- `updateActivity()` - Update existing activity
- `endActivity()` - End an activity
- `getActiveActivities()` - Get all active activity IDs
- `endAllActivities()` - Batch end all activities
- `getPushToken()` - Get APNs push token for remote updates

#### Configuration

- Auto-configuration for Info.plist (NSSupportsLiveActivities)
- Deployment target validation and setup (iOS 16.1+)
- Widget Extension creation and configuration
- Activity Attributes generation

#### Documentation

- 📖 Complete README with quick start
- 📚 Detailed setup guide (automatic & manual)
- 📝 Full API documentation with examples
- 🎨 SwiftUI customization guide
- 🐛 Comprehensive troubleshooting guide
- 💡 Real-world examples (ride tracking, delivery, sports, etc.)
- 🤝 Contributing guidelines

#### Example App

- Complete demo app showing all features
- Interactive UI for testing all templates
- Error handling demonstrations
- Live preview of all activity types

### Developer Experience

- TypeScript interfaces for all APIs
- Detailed error codes and messages
- Platform-specific handling (iOS-only)
- Graceful degradation on unsupported platforms
- Comprehensive inline documentation

### Known Limitations

- iOS 16.1+ required (ActivityKit limitation)
- Physical device recommended for testing (simulator support limited)
- Dynamic Island features require iPhone 14 Pro or later

### Acknowledgments

Built with insights from real-world Live Activities implementation challenges, specifically addressing the common deployment target mismatch issue that prevents activities from appearing.

---

## Future Roadmap

### Planned for v1.1.0

- [ ] Additional pre-built templates (music player, charging status)
- [ ] React hooks for easier state management
- [ ] Expo managed workflow support improvements
- [ ] Additional SwiftUI examples

### Planned for v1.2.0

- [ ] Multiple activity instances tracking
- [ ] Activity history and analytics
- [ ] Background update scheduling
- [ ] Custom notification alert sounds

### Under Consideration

- Android support (once available in Android API)
- Web preview for development
- Activity animation transitions
- Custom Dynamic Island sizes

---

## Support

- 📖 [Documentation](./README.md)
- 🐛 [Issue Tracker](https://github.com/yourusername/react-native-live-activities/issues)
- 💬 [Discussions](https://github.com/yourusername/react-native-live-activities/discussions)
