const { withInfoPlist, withXcodeProject } = require('@expo/config-plugins');

/**
 * Expo Config Plugin for React Native Live Activities
 * Automatically configures iOS project for Live Activities
 */
function withLiveActivities(config, options = {}) {
  // Add NSSupportsLiveActivities to Info.plist
  config = withInfoPlist(config, (config) => {
    config.modResults.NSSupportsLiveActivities = true;
    return config;
  });

  // Configure Xcode project
  config = withXcodeProject(config, async (config) => {
    const xcodeProject = config.modResults;
    
    // Set deployment target to iOS 16.1
    const configurations = xcodeProject.pbxXCBuildConfigurationSection();
    const configurationKeys = Object.keys(configurations);
    
    configurationKeys.forEach((key) => {
      const buildSettings = configurations[key].buildSettings;
      if (buildSettings && !key.endsWith('_comment')) {
        buildSettings.IPHONEOS_DEPLOYMENT_TARGET = '16.1';
      }
    });

    return config;
  });

  return config;
}

module.exports = withLiveActivities;
