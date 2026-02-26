import type {
  IOSPushPayload,
  AndroidPushPayload,
  QuickCommerceState,
  FoodDeliveryState,
  EcommerceDeliveryState,
  GenericDeliveryState,
} from '../types';

/**
 * Helper class for generating push notification payloads
 * for iOS Live Activities and Android notifications
 */
export class PushNotificationHelper {
  /**
   * Generate APNs push payload for iOS Live Activity update
   * 
   * @param activityId - The activity ID to update
   * @param pushToken - The push token for the activity
   * @param contentState - The new content state
   * @param alert - Optional alert configuration
   * 
   * @example
   * const payload = PushNotificationHelper.generateIOSPayload(
   *   'activity-123',
   *   'abc123token',
   *   { status: 'on_the_way', progress: 70 },
   *   { title: 'Update', body: 'Your order is on the way!' }
   * );
   * 
   * // Send to APNs using your preferred method
   */
  static generateIOSPayload(
    activityId: string,
    pushToken: string,
    contentState: Record<string, any>,
    alert?: { title?: string; body?: string; sound?: string }
  ): IOSPushPayload {
    return {
      timestamp: Date.now(),
      event: 'update',
      'content-state': contentState,
      alert: alert
        ? {
            'title': alert.title,
            'body': alert.body,
            'sound': alert.sound ?? 'default',
          }
        : undefined,
    };
  }

  /**
   * Generate APNs push payload for ending an iOS Live Activity
   */
  static generateIOSEndPayload(
    activityId: string,
    pushToken: string,
    finalContentState?: Record<string, any>,
    alert?: { title?: string; body?: string }
  ): IOSPushPayload {
    return {
      timestamp: Date.now(),
      event: 'end',
      'content-state': finalContentState ?? {},
      alert: alert
        ? {
            'title': alert.title,
            'body': alert.body,
            'sound': 'default',
          }
        : undefined,
    };
  }

  /**
   * Generate FCM payload for Android notification update
   * 
   * @param notificationId - The notification ID to update
   * @param type - The delivery type (QuickCommerce, FoodDelivery, etc.)
   * @param contentState - The new content state
   * 
   * @example
   * const payload = PushNotificationHelper.generateAndroidPayload(
   *   'notification-123',
   *   'QuickCommerce',
   *   { status: 'on_the_way', progress: 70 }
   * );
   */
  static generateAndroidPayload(
    notificationId: string,
    type: string,
    contentState: Record<string, any>
  ): AndroidPushPayload {
    return {
      data: {
        type,
        notificationId,
        status: contentState.status ?? 'unknown',
        progress: contentState.progress,
        ...contentState,
      },
      notification: {
        title: contentState.title,
        body: contentState.status,
        image: contentState.primaryImage ?? contentState.riderPhoto,
      },
      android: {
        channel_id: this.getChannelIdForType(type),
        priority: this.getPriorityForType(type),
        ttl: 0,
      },
    };
  }

  /**
   * Generate Quick Commerce update payload
   */
  static generateQuickCommerceUpdate(
    state: Partial<QuickCommerceState>,
    alert?: { title: string; body: string }
  ): { ios: IOSPushPayload; android: AndroidPushPayload } {
    return {
      ios: {
        timestamp: Date.now(),
        event: 'update',
        'content-state': state,
        alert: alert
          ? {
              'title': alert.title,
              'body': alert.body,
              'sound': 'default',
            }
          : undefined,
      },
      android: {
        data: {
          type: 'QuickCommerce',
          notificationId: '',
          status: state.status ?? 'unknown',
          progress: state.progress,
          estimatedMinutes: state.estimatedMinutes,
          riderName: state.riderName,
          currentLocation: state.currentLocation,
        },
        android: {
          channel_id: 'quick_commerce',
          priority: 'high',
          ttl: 0,
        },
      },
    };
  }

  /**
   * Generate Food Delivery update payload
   */
  static generateFoodDeliveryUpdate(
    state: Partial<FoodDeliveryState>,
    alert?: { title: string; body: string }
  ): { ios: IOSPushPayload; android: AndroidPushPayload } {
    return {
      ios: {
        timestamp: Date.now(),
        event: 'update',
        'content-state': state,
        alert: alert
          ? {
              'title': alert.title,
              'body': alert.body,
              'sound': 'default',
            }
          : undefined,
      },
      android: {
        data: {
          type: 'FoodDelivery',
          notificationId: '',
          status: state.status ?? 'unknown',
          statusStage: state.statusStage,
          estimatedMinutes: state.estimatedMinutes,
          riderName: state.riderName,
          currentLocation: state.currentLocation,
        },
        android: {
          channel_id: 'food_delivery',
          priority: 'high',
          ttl: 0,
        },
      },
    };
  }

  /**
   * Generate E-commerce Delivery update payload
   */
  static generateEcommerceUpdate(
    state: Partial<EcommerceDeliveryState>,
    alert?: { title: string; body: string }
  ): { ios: IOSPushPayload; android: AndroidPushPayload } {
    return {
      ios: {
        timestamp: Date.now(),
        event: 'update',
        'content-state': state,
        alert: alert
          ? {
              'title': alert.title,
              'body': alert.body,
              'sound': 'default',
            }
          : undefined,
      },
      android: {
        data: {
          type: 'EcommerceDelivery',
          notificationId: '',
          status: state.status ?? 'unknown',
          statusStage: state.statusStage,
          courierPartner: state.courierPartner,
          currentHub: state.currentHub,
          trackingNumber: state.trackingNumber,
        },
        android: {
          channel_id: 'ecommerce_delivery',
          priority: 'default',
          ttl: 0,
        },
      },
    };
  }

  /**
   * Generate Generic Delivery update payload
   */
  static generateGenericDeliveryUpdate(
    state: Partial<GenericDeliveryState>,
    alert?: { title: string; body: string }
  ): { ios: IOSPushPayload; android: AndroidPushPayload } {
    return {
      ios: {
        timestamp: Date.now(),
        event: 'update',
        'content-state': state,
        alert: alert
          ? {
              'title': alert.title,
              'body': alert.body,
              'sound': 'default',
            }
          : undefined,
      },
      android: {
        data: {
          type: 'GenericDelivery',
          notificationId: '',
          status: state.status ?? 'unknown',
          title: state.title,
          progress: state.progress,
        },
        notification: {
          title: state.title,
          body: state.subtitle,
          image: state.primaryImage,
        },
        android: {
          channel_id: 'delivery_tracking',
          priority: 'default',
          ttl: 0,
        },
      },
    };
  }

  // Private helpers

  private static getChannelIdForType(type: string): string {
    switch (type) {
      case 'QuickCommerce':
      case 'QuickCommerceAttributes':
        return 'quick_commerce';
      case 'FoodDelivery':
      case 'FoodDeliveryAttributes':
        return 'food_delivery';
      case 'EcommerceDelivery':
      case 'EcommerceDeliveryAttributes':
        return 'ecommerce_delivery';
      default:
        return 'delivery_tracking';
    }
  }

  private static getPriorityForType(type: string): 'high' | 'default' | 'low' {
    switch (type) {
      case 'QuickCommerce':
      case 'FoodDelivery':
        return 'high';
      case 'EcommerceDelivery':
        return 'default';
      default:
        return 'default';
    }
  }
}

/**
 * Server-side helper for sending push notifications
 * 
 * @example
 * // Node.js server example
 * const { PushServerHelper } = require('react-native-live-push-activities/server');
 * 
 * await PushServerHelper.sendIOSUpdate(
 *   'activity-123',
 *   'push-token-abc',
 *   { status: 'delivered', progress: 100 },
 *   {
 *     apnsHost: 'api.push.apple.com',
 *     teamId: 'YOUR_TEAM_ID',
 *     keyId: 'YOUR_KEY_ID',
 *     privateKey: 'YOUR_P8_KEY_CONTENT',
 *   }
 * );
 */
export class PushServerHelper {
  /**
   * Send iOS Live Activity update via APNs
   * Note: This should be called from your server, not from the React Native app
   */
  static async sendIOSUpdate(
    activityId: string,
    pushToken: string,
    contentState: Record<string, any>,
    config: {
      apnsHost: string;
      teamId: string;
      keyId: string;
      privateKey: string;
      bundleId: string;
    },
    alert?: { title: string; body: string }
  ): Promise<void> {
    const payload = PushNotificationHelper.generateIOSPayload(
      activityId,
      pushToken,
      contentState,
      alert
    );

    // Implementation note: Use a library like 'apns2' or 'node-apn' in your server
    // to send the push notification to Apple's servers
    console.log('APNs payload to send:', JSON.stringify(payload, null, 2));
    console.log('Config:', { ...config, privateKey: '[REDACTED]' });
    
    // In a real server implementation, you would:
    // 1. Create a JWT token using your Apple Developer credentials
    // 2. Make a POST request to https://api.push.apple.com/3/device/{pushToken}
    // 3. Include the payload in the request body
    // 4. Handle the response
  }

  /**
   * Send Android notification update via FCM
   * Note: This should be called from your server, not from the React Native app
   */
  static async sendAndroidUpdate(
    notificationId: string,
    fcmToken: string,
    type: string,
    contentState: Record<string, any>,
    config: {
      serverKey: string;
    }
  ): Promise<void> {
    const payload = PushNotificationHelper.generateAndroidPayload(
      notificationId,
      type,
      contentState
    );

    // Implementation note: Use Firebase Admin SDK or FCM HTTP API
    console.log('FCM payload to send:', JSON.stringify(payload, null, 2));
    console.log('FCM Token:', fcmToken);
    
    // In a real server implementation, you would:
    // 1. Use Firebase Admin SDK or FCM HTTP API
    // 2. Send the payload to the FCM token
    // 3. Handle the response
  }
}
