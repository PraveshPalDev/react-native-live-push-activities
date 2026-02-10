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
  activityType: string;
  attributes: T;
  contentState: Record<string, any>;
  staleDate?: number;
  relevanceScore?: number;
}

export interface UpdateConfig {
  contentState: Record<string, any>;
  alertConfig?: {
    title?: string;
    body?: string;
    sound?: string;
  };
  staleDate?: number;
}

export interface EndConfig {
  finalContent?: Record<string, any>;
  dismissalPolicy?: 'immediate' | 'after-date' | 'default';
}

/**
 * Main Live Activities API
 */
export class LiveActivities {
  static async areActivitiesEnabled(): Promise<boolean> {
    return await LiveActivitiesModule.areActivitiesEnabled();
  }

  static async startActivity<T = any>(config: ActivityConfig<T>): Promise<string> {
    return await LiveActivitiesModule.startActivity(
      config.activityType,
      config.attributes,
      config.contentState,
      config.staleDate ?? null,
      config.relevanceScore ?? null
    );
  }

  static async updateActivity(
    activityId: string,
    config: UpdateConfig | Record<string, any>
  ): Promise<void> {
    const contentState = 'contentState' in config ? config.contentState : config;
    const alertConfig = 'alertConfig' in config ? config.alertConfig : null;
    const staleDate = 'staleDate' in config ? config.staleDate : null;

    await LiveActivitiesModule.updateActivity(
      activityId,
      contentState,
      alertConfig,
      staleDate
    );
  }

  static async endActivity(
    activityId: string,
    config?: EndConfig
  ): Promise<void> {
    await LiveActivitiesModule.endActivity(
      activityId,
      config?.finalContent ?? null,
      config?.dismissalPolicy || 'default'
    );
  }

  static async getActiveActivities(): Promise<string[]> {
    return await LiveActivitiesModule.getActiveActivities();
  }

  static async endAllActivities(): Promise<void> {
    await LiveActivitiesModule.endAllActivities();
  }

  static async getPushToken(activityId: string): Promise<string | null> {
    return await LiveActivitiesModule.getPushToken(activityId);
  }
}

export * from './templates';
export default LiveActivities;
