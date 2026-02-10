#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

console.log('🚀 React Native Live Activities - Post Install Setup\n');

// Check if this is iOS
const platform = process.platform;
if (platform !== 'darwin') {
  console.log('⚠️  Live Activities are only supported on iOS (macOS required for development)');
  console.log('ℹ️  Skipping iOS setup on', platform);
  process.exit(0);
}

// Find project root
const projectRoot = process.cwd();
const iosPath = path.join(projectRoot, 'ios');

// Check if ios directory exists
if (!fs.existsSync(iosPath)) {
  console.log('ℹ️  iOS directory not found. This might be an Expo project or the package is being installed in a library.');
  console.log('ℹ️  Please run "npx react-native-live-activities-setup" manually when ready.');
  process.exit(0);
}

console.log('✅ iOS project detected');
console.log('📋 To complete setup, run: npx react-native-live-activities-setup');
console.log('');
console.log('📚 Documentation: https://github.com/yourusername/react-native-live-activities#readme');
console.log('');
