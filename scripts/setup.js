#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');
const readline = require('readline');

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

function ask(question) {
  return new Promise((resolve) => {
    rl.question(question, (answer) => {
      resolve(answer);
    });
  });
}

async function main() {
  console.log('\n🚀 React Native Live Activities Setup\n');
  console.log('This script will configure your iOS project for Live Activities.\n');

  // Find project root
  const projectRoot = process.cwd();
  const iosPath = path.join(projectRoot, 'ios');

  // Check if iOS directory exists
  if (!fs.existsSync(iosPath)) {
    console.error('❌ iOS directory not found!');
    console.log('Make sure you run this from your React Native project root.');
    process.exit(1);
  }

  // Find .xcodeproj
  const iosFiles = fs.readdirSync(iosPath);
  const xcodeproj = iosFiles.find(file => file.endsWith('.xcodeproj'));
  
  if (!xcodeproj) {
    console.error('❌ No Xcode project found in ios directory!');
    process.exit(1);
  }

  const projectName = xcodeproj.replace('.xcodeproj', '');
  console.log(`✅ Found project: ${projectName}\n`);

  // Ask for confirmation
  const proceed = await ask('Do you want to proceed with automatic setup? (y/n): ');
  
  if (proceed.toLowerCase() !== 'y') {
    console.log('\nSetup cancelled. See manual setup guide: https://github.com/yourusername/react-native-live-activities/blob/main/docs/CONFIGURATION.md');
    rl.close();
    process.exit(0);
  }

  console.log('\n📝 Starting setup...\n');

  // Step 1: Update Info.plist
  console.log('1️⃣  Updating Info.plist...');
  updateInfoPlist(path.join(iosPath, projectName, 'Info.plist'));
  console.log('   ✅ Info.plist updated\n');

  // Step 2: Create Widget Extension
  console.log('2️⃣  Creating Widget Extension...');
  const widgetPath = path.join(iosPath, 'WidgetExtension');
  createWidgetExtension(widgetPath, projectName);
  console.log('   ✅ Widget Extension created\n');

  // Step 3: Create ActivityAttributes
  console.log('3️⃣  Creating Activity Attributes...');
  createActivityAttributes(widgetPath);
  console.log('   ✅ Activity Attributes created\n');

  // Step 4: Create Widget Templates
  console.log('4️⃣  Creating Widget Templates...');
  createWidgetTemplates(widgetPath);
  console.log('   ✅ Widget Templates created\n');

  // Step 5: Instructions for Xcode
  console.log('✅ Setup complete!\n');
  console.log('📝 Next steps in Xcode:');
  console.log('   1. Open', `${projectName}.xcworkspace`);
  console.log('   2. Add the WidgetExtension folder to your project');
  console.log('   3. Create a new Widget Extension target:');
  console.log('      - File > New > Target > Widget Extension');
  console.log('      - Name it "LiveActivityWidget"');
  console.log('      - Set deployment target to iOS 16.1+');
  console.log('   4. Ensure main app deployment target is also iOS 16.1+');
  console.log('   5. Run pod install: cd ios && pod install');
  console.log('');
  console.log('📚 Full documentation: https://github.com/yourusername/react-native-live-activities');
  console.log('');

  rl.close();
}

function updateInfoPlist(plistPath) {
  if (!fs.existsSync(plistPath)) {
    console.warn('   ⚠️  Info.plist not found at:', plistPath);
    return;
  }

  let content = fs.readFileSync(plistPath, 'utf8');
  
  // Check if NSSupportsLiveActivities already exists
  if (content.includes('NSSupportsLiveActivities')) {
    console.log('   ℹ️  NSSupportsLiveActivities already configured');
    return;
  }

  // Add NSSupportsLiveActivities before </dict>
  const insertion = '\t<key>NSSupportsLiveActivities</key>\n\t<true/>\n';
  const lastDictIndex = content.lastIndexOf('</dict>');
  
  if (lastDictIndex > -1) {
    content = content.slice(0, lastDictIndex) + insertion + content.slice(lastDictIndex);
    fs.writeFileSync(plistPath, content);
  }
}

function createWidgetExtension(widgetPath, projectName) {
  if (!fs.existsSync(widgetPath)) {
    fs.mkdirSync(widgetPath, { recursive: true });
  }

  // Create Info.plist for Widget
  const widgetInfoPlist = `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
\t<key>CFBundleDevelopmentRegion</key>
\t<string>$(DEVELOPMENT_LANGUAGE)</string>
\t<key>CFBundleDisplayName</key>
\t<string>LiveActivityWidget</string>
\t<key>CFBundleExecutable</key>
\t<string>$(EXECUTABLE_NAME)</string>
\t<key>CFBundleIdentifier</key>
\t<string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
\t<key>CFBundleInfoDictionaryVersion</key>
\t<string>6.0</string>
\t<key>CFBundleName</key>
\t<string>$(PRODUCT_NAME)</string>
\t<key>CFBundlePackageType</key>
\t<string>$(PRODUCT_BUNDLE_PACKAGE_TYPE)</string>
\t<key>CFBundleShortVersionString</key>
\t<string>1.0</string>
\t<key>CFBundleVersion</key>
\t<string>1</string>
\t<key>NSExtension</key>
\t<dict>
\t\t<key>NSExtensionPointIdentifier</key>
\t\t<string>com.apple.widgetkit-extension</string>
\t</dict>
</dict>
</plist>`;

  fs.writeFileSync(path.join(widgetPath, 'Info.plist'), widgetInfoPlist);
}

function createActivityAttributes(widgetPath) {
  const attributesContent = `import Foundation
import ActivityKit

// MARK: - Ride Tracking Activity

struct RideTrackingAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var status: String
        var currentLocation: String?
        var estimatedArrival: Date
        var distance: Double?
    }
    
    var driverName: String
    var vehicleNumber: String
    var vehicleType: String?
    var pickup: String
    var dropoff: String
    var driverPhoto: String?
}

// MARK: - Delivery Tracking Activity

struct DeliveryTrackingAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var status: String
        var currentLocation: String?
        var estimatedArrival: Date
        var stopsRemaining: Int?
    }
    
    var courierName: String
    var orderNumber: String
    var orderItems: String?
    var deliveryAddress: String?
}

// MARK: - Sports Score Activity

struct SportsScoreAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var homeScore: Int
        var awayScore: Int
        var period: String
        var timeRemaining: String?
        var lastPlay: String?
        var isLive: Bool
    }
    
    var homeTeam: String
    var awayTeam: String
    var homeTeamLogo: String?
    var awayTeamLogo: String?
    var league: String?
}

// MARK: - Timer Activity

struct TimerAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var endTime: Date
        var isPaused: Bool
        var remainingSeconds: Int?
    }
    
    var title: String
    var description: String?
    var icon: String?
}
`;

  fs.writeFileSync(path.join(widgetPath, 'ActivityAttributes.swift'), attributesContent);
}

function createWidgetTemplates(widgetPath) {
  const rideTrackingWidget = `import WidgetKit
import SwiftUI
import ActivityKit

@main
struct LiveActivityWidgets: WidgetBundle {
    var body: some Widget {
        RideTrackingLiveActivity()
    }
}

// MARK: - Ride Tracking Live Activity

struct RideTrackingLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: RideTrackingAttributes.self) { context in
            // Lock Screen view
            RideTrackingLockScreenView(context: context)
                .activityBackgroundTint(Color.black.opacity(0.8))
                .activitySystemActionForegroundColor(Color.white)
            
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded region
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
                
                DynamicIslandExpandedRegion(.center) {
                    Text(context.state.status)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Label("Pickup", systemImage: "location.circle.fill")
                                .font(.caption2)
                            Text(context.attributes.pickup)
                                .font(.caption)
                                .lineLimit(1)
                        }
                        Spacer()
                        Image(systemName: "arrow.right")
                            .foregroundColor(.secondary)
                        Spacer()
                        VStack(alignment: .trailing, spacing: 4) {
                            Label("Drop-off", systemImage: "mappin.circle.fill")
                                .font(.caption2)
                            Text(context.attributes.dropoff)
                                .font(.caption)
                                .lineLimit(1)
                        }
                    }
                    .padding(.horizontal)
                }
                
            } compactLeading: {
                Image(systemName: "car.fill")
                    .foregroundColor(.blue)
                
            } compactTrailing: {
                Text(context.state.estimatedArrival, style: .timer)
                    .font(.caption2)
                    .monospacedDigit()
                    .frame(width: 40)
                
            } minimal: {
                Image(systemName: "car.fill")
                    .foregroundColor(.blue)
            }
        }
    }
}

// MARK: - Lock Screen View

struct RideTrackingLockScreenView: View {
    let context: ActivityViewContext<RideTrackingAttributes>
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(context.attributes.driverName)
                        .font(.headline)
                        .fontWeight(.semibold)
                    Text(context.attributes.vehicleNumber)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("ETA")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(context.state.estimatedArrival, style: .timer)
                        .font(.title2)
                        .fontWeight(.bold)
                        .monospacedDigit()
                }
            }
            
            Divider()
            
            HStack {
                Label(context.attributes.pickup, systemImage: "location.circle.fill")
                    .font(.caption)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Image(systemName: "arrow.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
                
                Label(context.attributes.dropoff, systemImage: "mappin.circle.fill")
                    .font(.caption)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            
            Text(context.state.status)
                .font(.callout)
                .foregroundColor(.blue)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
        }
        .padding()
    }
}
`;

  fs.writeFileSync(path.join(widgetPath, 'RideTrackingWidget.swift'), rideTrackingWidget);
}

main().catch(console.error);
