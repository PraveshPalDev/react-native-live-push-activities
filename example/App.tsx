import React, { useState, useEffect } from 'react';
import {
  SafeAreaView,
  ScrollView,
  StyleSheet,
  Text,
  View,
  TouchableOpacity,
  Alert,
  Platform,
  TextInput,
} from 'react-native';
import LiveActivities, { Templates } from 'react-native-live-activities';

export default function App() {
  const [isEnabled, setIsEnabled] = useState(false);
  const [currentActivityId, setCurrentActivityId] = useState<string | null>(null);
  const [driverName, setDriverName] = useState('John Doe');
  const [vehicleNumber, setVehicleNumber] = useState('ABC-1234');
  const [eta, setEta] = useState(10); // minutes

  useEffect(() => {
    checkStatus();
  }, []);

  const checkStatus = async () => {
    const enabled = await LiveActivities.areActivitiesEnabled();
    setIsEnabled(enabled);
  };

  const startRideActivity = async () => {
    try {
      const activityId = await Templates.RideTracking.start(
        {
          driverName,
          vehicleNumber,
          vehicleType: 'Sedan',
          pickup: 'Times Square, New York',
          dropoff: 'Central Park, New York',
        },
        {
          status: 'waiting',
          currentLocation: 'Downtown',
          estimatedArrival: Date.now() + eta * 60 * 1000,
        }
      );

      setCurrentActivityId(activityId);
      Alert.alert('Success', 'Live Activity started! Check your Lock Screen.');
    } catch (error: any) {
      Alert.alert('Error', error.message);
    }
  };

  const updateToOnTheWay = async () => {
    if (!currentActivityId) return;

    try {
      await Templates.RideTracking.update(currentActivityId, {
        status: 'on-the-way',
        currentLocation: 'Heading to pickup location',
        estimatedArrival: Date.now() + (eta - 2) * 60 * 1000,
      });
      Alert.alert('Updated', 'Driver is on the way!');
    } catch (error: any) {
      Alert.alert('Error', error.message);
    }
  };

  const updateToArriving = async () => {
    if (!currentActivityId) return;

    try {
      await Templates.RideTracking.update(currentActivityId, {
        status: 'arriving',
        currentLocation: 'Near your location',
        estimatedArrival: Date.now() + 2 * 60 * 1000,
      });
      Alert.alert('Updated', 'Driver is arriving!');
    } catch (error: any) {
      Alert.alert('Error', error.message);
    }
  };

  const completeRide = async () => {
    if (!currentActivityId) return;

    try {
      await Templates.RideTracking.complete(currentActivityId);
      setCurrentActivityId(null);
      Alert.alert('Complete', 'Ride completed!');
    } catch (error: any) {
      Alert.alert('Error', error.message);
    }
  };

  const startDeliveryActivity = async () => {
    try {
      const activityId = await Templates.DeliveryTracking.start(
        {
          courierName: 'Jane Smith',
          orderNumber: '#12345',
          orderItems: 'Pizza, Coke',
        },
        {
          status: 'preparing',
          estimatedArrival: Date.now() + 30 * 60 * 1000,
        }
      );

      Alert.alert('Success', 'Delivery tracking started!');
      
      // Auto-update after 5 seconds
      setTimeout(async () => {
        await Templates.DeliveryTracking.update(activityId, {
          status: 'out-for-delivery',
          stopsRemaining: 3,
        });
      }, 5000);
    } catch (error: any) {
      Alert.alert('Error', error.message);
    }
  };

  const startSportsActivity = async () => {
    try {
      const activityId = await Templates.SportsScore.start(
        {
          homeTeam: 'Lakers',
          awayTeam: 'Warriors',
          league: 'NBA',
        },
        {
          homeScore: 98,
          awayScore: 95,
          period: 'Q4',
          timeRemaining: '2:30',
          isLive: true,
        }
      );

      Alert.alert('Success', 'Sports score started!');
      
      // Simulate score update
      setTimeout(async () => {
        await Templates.SportsScore.update(activityId, {
          homeScore: 100,
          awayScore: 95,
          timeRemaining: '1:45',
        });
      }, 5000);
    } catch (error: any) {
      Alert.alert('Error', error.message);
    }
  };

  if (Platform.OS !== 'ios') {
    return (
      <SafeAreaView style={styles.container}>
        <Text style={styles.title}>
          Live Activities are only available on iOS 16.1+
        </Text>
      </SafeAreaView>
    );
  }

  if (!isEnabled) {
    return (
      <SafeAreaView style={styles.container}>
        <Text style={styles.title}>Live Activities Not Available</Text>
        <Text style={styles.subtitle}>
          - Requires iOS 16.1 or higher{'\n'}
          - May be disabled in Settings{'\n'}
          - Requires physical device (not simulator)
        </Text>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView contentContainerStyle={styles.scrollContent}>
        <Text style={styles.title}>🚀 Live Activities Demo</Text>
        <Text style={styles.subtitle}>
          Start activities and check your Lock Screen!
        </Text>

        {/* Ride Tracking Section */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>🚗 Ride Tracking</Text>
          
          <TextInput
            style={styles.input}
            placeholder="Driver Name"
            value={driverName}
            onChangeText={setDriverName}
          />
          
          <TextInput
            style={styles.input}
            placeholder="Vehicle Number"
            value={vehicleNumber}
            onChangeText={setVehicleNumber}
          />
          
          <TextInput
            style={styles.input}
            placeholder="ETA (minutes)"
            value={String(eta)}
            onChangeText={(text) => setEta(Number(text) || 10)}
            keyboardType="number-pad"
          />

          <TouchableOpacity
            style={[styles.button, styles.primaryButton]}
            onPress={startRideActivity}
            disabled={!!currentActivityId}
          >
            <Text style={styles.buttonText}>Start Ride Activity</Text>
          </TouchableOpacity>

          {currentActivityId && (
            <>
              <TouchableOpacity
                style={[styles.button, styles.secondaryButton]}
                onPress={updateToOnTheWay}
              >
                <Text style={styles.buttonText}>Update: On the Way</Text>
              </TouchableOpacity>

              <TouchableOpacity
                style={[styles.button, styles.secondaryButton]}
                onPress={updateToArriving}
              >
                <Text style={styles.buttonText}>Update: Arriving</Text>
              </TouchableOpacity>

              <TouchableOpacity
                style={[styles.button, styles.dangerButton]}
                onPress={completeRide}
              >
                <Text style={styles.buttonText}>Complete Ride</Text>
              </TouchableOpacity>
            </>
          )}
        </View>

        {/* Other Templates */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>📦 Other Templates</Text>

          <TouchableOpacity
            style={[styles.button, styles.primaryButton]}
            onPress={startDeliveryActivity}
          >
            <Text style={styles.buttonText}>Start Delivery Tracking</Text>
          </TouchableOpacity>

          <TouchableOpacity
            style={[styles.button, styles.primaryButton]}
            onPress={startSportsActivity}
          >
            <Text style={styles.buttonText}>Start Sports Score</Text>
          </TouchableOpacity>
        </View>

        <View style={styles.footer}>
          <Text style={styles.footerText}>
            Status: {isEnabled ? '✅ Enabled' : '❌ Disabled'}
          </Text>
          {currentActivityId && (
            <Text style={styles.footerText}>
              Active: {currentActivityId.substring(0, 8)}...
            </Text>
          )}
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  scrollContent: {
    padding: 20,
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 8,
    textAlign: 'center',
  },
  subtitle: {
    fontSize: 16,
    color: '#666',
    marginBottom: 24,
    textAlign: 'center',
  },
  section: {
    backgroundColor: 'white',
    borderRadius: 12,
    padding: 16,
    marginBottom: 16,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  sectionTitle: {
    fontSize: 20,
    fontWeight: '600',
    color: '#333',
    marginBottom: 16,
  },
  input: {
    backgroundColor: '#f9f9f9',
    borderRadius: 8,
    padding: 12,
    marginBottom: 12,
    fontSize: 16,
    borderWidth: 1,
    borderColor: '#e0e0e0',
  },
  button: {
    borderRadius: 8,
    padding: 14,
    alignItems: 'center',
    marginTop: 8,
  },
  primaryButton: {
    backgroundColor: '#007AFF',
  },
  secondaryButton: {
    backgroundColor: '#34C759',
  },
  dangerButton: {
    backgroundColor: '#FF3B30',
  },
  buttonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: '600',
  },
  footer: {
    marginTop: 24,
    padding: 16,
    alignItems: 'center',
  },
  footerText: {
    fontSize: 14,
    color: '#666',
    marginBottom: 4,
  },
});
