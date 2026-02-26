import { LiveActivities } from '../index';
import type {
  GenericDeliveryAttributes,
  GenericDeliveryState,
} from '../types';

/**
 * Generic Delivery Template (Fully Customizable)
 * 
 * Features:
 * - Fully customizable fields
 * - Custom status stages
 * - Custom icons/images
 * - Custom action buttons
 * - Support for custom data via JSON
 * 
 * @example
 * // Custom service booking
 * const activityId = await CustomDelivery.start(
 *   {
 *     id: 'SVC-12345',
 *     type: 'service',
 *   },
 *   {
 *     title: 'Home Cleaning',
 *     subtitle: '2 BHK Apartment',
 *     status: 'scheduled',
 *     progress: 0,
 *     primaryImage: 'https://example.com/cleaning.png',
 *     actionLabel: 'Reschedule',
 *     actionDeepLink: 'myapp://reschedule/SVC-12345',
 *   }
 * );
 * 
 * // Update progress
 * await CustomDelivery.update(activityId, {
 *   status: 'in_progress',
 *   progress: 50,
 * });
 * 
 * // Complete with custom data
 * await CustomDelivery.complete(activityId, {
 *   title: 'Service Completed',
 *   status: 'completed',
 *   progress: 100,
 * });
 */
export class CustomDelivery {
  /**
   * Start a new custom delivery tracking activity
   */
  static async start(
    attributes: GenericDeliveryAttributes,
    state: GenericDeliveryState
  ): Promise<string> {
    return LiveActivities.startActivity<GenericDeliveryAttributes>({
      activityType: 'GenericDelivery',
      attributes,
      contentState: state,
    });
  }

  /**
   * Update an existing custom delivery activity
   */
  static async update(
    activityId: string,
    state: Partial<GenericDeliveryState>
  ): Promise<void> {
    return LiveActivities.updateActivity(activityId, { contentState: state });
  }

  /**
   * Complete the activity with optional final content
   */
  static async complete(
    activityId: string,
    finalContent?: Partial<GenericDeliveryState>
  ): Promise<void> {
    return LiveActivities.endActivity(activityId, {
      finalContent,
      dismissalPolicy: 'after-date',
    });
  }

  /**
   * Cancel the activity
   */
  static async cancel(
    activityId: string,
    reason?: string
  ): Promise<void> {
    return LiveActivities.endActivity(activityId, {
      finalContent: { title: 'Cancelled', status: 'cancelled' },
      dismissalPolicy: 'immediate',
    });
  }

  /**
   * Update progress
   */
  static async updateProgress(
    activityId: string,
    progress: number,
    status?: string
  ): Promise<void> {
    return this.update(activityId, {
      progress: Math.min(100, Math.max(0, progress)),
      ...(status && { status }),
    });
  }

  /**
   * Update with custom data
   */
  static async updateWithCustomData<T = any>(
    activityId: string,
    customData: T,
    otherFields?: Partial<GenericDeliveryState>
  ): Promise<void> {
    return this.update(activityId, {
      customData: JSON.stringify(customData),
      ...otherFields,
    });
  }

  /**
   * Set action buttons
   */
  static async setActions(
    activityId: string,
    primaryAction?: { label: string; deepLink: string },
    secondaryAction?: { label: string; deepLink: string }
  ): Promise<void> {
    return this.update(activityId, {
      actionLabel: primaryAction?.label,
      actionDeepLink: primaryAction?.deepLink,
      secondaryActionLabel: secondaryAction?.label,
      secondaryActionDeepLink: secondaryAction?.deepLink,
    });
  }

  /**
   * Get the current push token for server-side updates
   */
  static async getPushToken(activityId: string): Promise<string | null> {
    return LiveActivities.getPushToken(activityId);
  }
}

/**
 * Factory function to create a custom delivery with type-safe custom data
 */
export function createCustomDelivery<T extends Record<string, any>>(
  attributes: Omit<GenericDeliveryAttributes, 'type'> & { type?: GenericDeliveryAttributes['type'] },
  state: Omit<GenericDeliveryState, 'customData'> & { customData?: T }
): Promise<string> {
  const finalAttributes: GenericDeliveryAttributes = {
    id: attributes.id,
    type: attributes.type ?? 'custom',
    appIcon: attributes.appIcon,
    deepLink: attributes.deepLink,
  };

  const finalState: GenericDeliveryState = {
    title: state.title,
    subtitle: state.subtitle,
    status: state.status,
    progress: state.progress,
    primaryImage: state.primaryImage,
    secondaryImage: state.secondaryImage,
    actionLabel: state.actionLabel,
    actionDeepLink: state.actionDeepLink,
    secondaryActionLabel: state.secondaryActionLabel,
    secondaryActionDeepLink: state.secondaryActionDeepLink,
    customData: state.customData ? JSON.stringify(state.customData) : undefined,
  };

  return CustomDelivery.start(finalAttributes, finalState);
}
