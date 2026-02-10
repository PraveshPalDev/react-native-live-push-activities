import { NativeModules, Platform } from 'react-native';

const LINKING_ERROR =
  `The package 'react-native-live-activities' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({
    ios: "- Run 'pod install' in the ios directory\n",
    default: '',
  }) +
  '- Rebuild the app after installing the package\n' +
  '- You are running on iOS 16.1 or higher\n';

const LiveActivitiesModule = NativeModules.LiveActivities
  ? NativeModules.LiveActivities
  : new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR);
        },
      }
    );

export interface ActivityConfig<T = any> {
  /**
   * Unique identifier for the activity type (must match your ActivityAttributes)
   */
  activityType: string;

  /**
   * Static attributes that won't change during the activity lifecycle
   */
  attributes: T;

  /**
   * Dynamic content that can be updated
   */
  contentState: Record<string, any>;

  /**
   * Stale date for the activity (optional)
   */
  staleDate?: number;

  /**
   * Relevance score (0-100) for sorting multiple activities
   */
  relevanceScore?: number;
}

export interface UpdateConfig {
  /**
   * Updated content state
   */
  contentState: Record<string, any>;

  /**
   * Alert configuration for the update
   */
  alertConfig?: {
    title?: string;
    body?: string;
    sound?: string;
  };

  /**
   * Updated stale date
   */
  staleDate?: number;
}

export interface EndConfig {
  /**
   * Final content state to display
   */
  finalContent?: Record<string, any>;

  /**
   * Dismissal policy
   */
  dismissalPolicy?: 'immediate' | 'after-date' | 'default';
}

/**
 * Main Live Activities API
 */
export class LiveActivities {
  /**
   * Check if Live Activities are supported and enabled on the device
   */
  static async areActivitiesEnabled(): Promise<boolean> {
    if (Platform.OS !== 'ios') {
      return false;
    }

    try {
      return await LiveActivitiesModule.areActivitiesEnabled();
    } catch (error) {
      console.error('Error checking Live Activities status:', error);
      return false;
    }
  }

  /**
   * Start a new Live Activity
   * @param config Activity configuration
   * @returns Activity ID
   */
  static async startActivity<T = any>(
    config: ActivityConfig<T>
  ): Promise<string> {
    if (Platform.OS !== 'ios') {
      throw new Error('Live Activities are only supported on iOS');
    }

    try {
      const activityId = await LiveActivitiesModule.startActivity(
        config.activityType,
        config.attributes,
        config.contentState,
        config.staleDate,
        config.relevanceScore
      );
      return activityId;
    } catch (error) {
      console.error('Error starting Live Activity:', error);
      throw error;
    }
  }

  /**
   * Update an existing Live Activity
   * @param activityId Activity ID returned from startActivity
   * @param config Update configuration
   */
  static async updateActivity(
    activityId: string,
    config: UpdateConfig | Record<string, any>
  ): Promise<void> {
    if (Platform.OS !== 'ios') {
      throw new Error('Live Activities are only supported on iOS');
    }

    try {
      // Support both new config format and legacy direct contentState
      const contentState =
        'contentState' in config ? config.contentState : config;
      const alertConfig =
        'alertConfig' in config ? config.alertConfig : undefined;
      const staleDate = 'staleDate' in config ? config.staleDate : undefined;

      await LiveActivitiesModule.updateActivity(
        activityId,
        contentState,
        alertConfig,
        staleDate
      );
    } catch (error) {
      console.error('Error updating Live Activity:', error);
      throw error;
    }
  }

  /**
   * End a Live Activity
   * @param activityId Activity ID
   * @param config End configuration
   */
  static async endActivity(
    activityId: string,
    config?: EndConfig
  ): Promise<void> {
    if (Platform.OS !== 'ios') {
      throw new Error('Live Activities are only supported on iOS');
    }

    try {
      await LiveActivitiesModule.endActivity(
        activityId,
        config?.finalContent,
        config?.dismissalPolicy || 'default'
      );
    } catch (error) {
      console.error('Error ending Live Activity:', error);
      throw error;
    }
  }

  /**
   * Get all active Live Activity IDs
   */
  static async getActiveActivities(): Promise<string[]> {
    if (Platform.OS !== 'ios') {
      return [];
    }

    try {
      return await LiveActivitiesModule.getActiveActivities();
    } catch (error) {
      console.error('Error getting active activities:', error);
      return [];
    }
  }

  /**
   * End all active Live Activities
   */
  static async endAllActivities(): Promise<void> {
    if (Platform.OS !== 'ios') {
      return;
    }

    try {
      await LiveActivitiesModule.endAllActivities();
    } catch (error) {
      console.error('Error ending all activities:', error);
      throw error;
    }
  }

  /**
   * Get the push token for a specific activity (for APNs updates)
   */
  static async getPushToken(activityId: string): Promise<string | null> {
    if (Platform.OS !== 'ios') {
      return null;
    }

    try {
      return await LiveActivitiesModule.getPushToken(activityId);
    } catch (error) {
      console.error('Error getting push token:', error);
      return null;
    }
  }
}

// Export pre-built templates
export * from './templates';

export default LiveActivities;
