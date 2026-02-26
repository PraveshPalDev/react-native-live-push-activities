import { LiveActivities } from '../index';
import type {
  QuickCommerceAttributes,
  QuickCommerceState,
  QuickCommerceStatus,
} from '../types';

/**
 * Quick Commerce Delivery Template (Zepto-style)
 * 
 * Features:
 * - 10-minute countdown timer
 * - Progress bar (0-100%)
 * - Rider name and photo
 * - Live location status
 * - Cancel/Contact buttons
 * 
 * @example
 * const activityId = await QuickCommerceDelivery.start(
 *   {
 *     orderId: 'ORD-12345',
 *     items: 'Groceries, Fruits',
 *   },
 *   {
 *     status: 'confirmed',
 *     progress: 0,
 *     estimatedMinutes: 10,
 *   }
 * );
 * 
 * // Update progress
 * await QuickCommerceDelivery.update(activityId, {
 *   status: 'on_the_way',
 *   progress: 60,
 *   estimatedMinutes: 4,
 *   riderName: 'Rahul Kumar',
 *   riderPhone: '+91-9876543210',
 * });
 * 
 * // Mark as delivered
 * await QuickCommerceDelivery.complete(activityId);
 */
export class QuickCommerceDelivery {
  /**
   * Start a new quick commerce delivery tracking activity
   */
  static async start(
    attributes: QuickCommerceAttributes,
    state: QuickCommerceState
  ): Promise<string> {
    return LiveActivities.startActivity<QuickCommerceAttributes>({
      activityType: 'QuickCommerce',
      attributes,
      contentState: state,
    });
  }

  /**
   * Update an existing quick commerce delivery activity
   */
  static async update(
    activityId: string,
    state: Partial<QuickCommerceState>
  ): Promise<void> {
    return LiveActivities.updateActivity(activityId, { contentState: state });
  }

  /**
   * Mark delivery as delivered
   */
  static async complete(activityId: string): Promise<void> {
    return LiveActivities.endActivity(activityId, {
      finalContent: { status: 'delivered', progress: 100 },
      dismissalPolicy: 'after-date',
    });
  }

  /**
   * Cancel the delivery
   */
  static async cancel(activityId: string, reason?: string): Promise<void> {
    return LiveActivities.endActivity(activityId, {
      finalContent: { status: 'cancelled', progress: 0 },
      dismissalPolicy: 'immediate',
    });
  }

  /**
   * Update status with predefined status helpers
   */
  static async updateStatus(
    activityId: string,
    status: QuickCommerceStatus,
    additionalData?: Partial<QuickCommerceState>
  ): Promise<void> {
    const progressMap: Record<QuickCommerceStatus, number> = {
      confirmed: 10,
      preparing: 25,
      picked_up: 50,
      on_the_way: 70,
      arriving: 90,
      delivered: 100,
      cancelled: 0,
    };

    return this.update(activityId, {
      status,
      progress: progressMap[status],
      ...additionalData,
    });
  }

  /**
   * Get the current push token for server-side updates
   */
  static async getPushToken(activityId: string): Promise<string | null> {
    return LiveActivities.getPushToken(activityId);
  }
}
