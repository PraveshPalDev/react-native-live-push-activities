import { LiveActivities } from '../index';
import type {
  FoodDeliveryAttributes,
  FoodDeliveryState,
  FoodDeliveryStatus,
  FoodDeliveryStage,
} from '../types';

/**
 * Food Delivery Template (Swiggy/Zomato-style)
 * 
 * Features:
 * - Restaurant preparation status
 * - Order items summary
 * - Rider tracking with map
 * - Multiple status stages (Confirmed → Preparing → Picked Up → On the Way → Delivered)
 * - Estimated time with live updates
 * - Rating prompt on completion
 * 
 * @example
 * const activityId = await FoodDelivery.start(
 *   {
 *     orderId: 'FD-12345',
 *     restaurantName: 'Pizza Hut',
 *     restaurantLogo: 'https://example.com/logo.png',
 *     orderItems: 'Margherita Pizza, Garlic Bread',
 *   },
 *   {
 *     status: 'confirmed',
 *     statusStage: 0,
 *     estimatedMinutes: 30,
 *   }
 * );
 * 
 * // Update to preparing
 * await FoodDelivery.updateStatus(activityId, 'preparing', 1, {
 *   preparationTime: 15,
 * });
 * 
 * // Update rider info
 * await FoodDelivery.update(activityId, {
 *   riderName: 'Amit Singh',
 *   riderPhone: '+91-9876543210',
 *   riderPhoto: 'https://example.com/rider.jpg',
 * });
 * 
 * // Mark as delivered
 * await FoodDelivery.complete(activityId);
 */
export class FoodDelivery {
  /**
   * Start a new food delivery tracking activity
   */
  static async start(
    attributes: FoodDeliveryAttributes,
    state: FoodDeliveryState
  ): Promise<string> {
    return LiveActivities.startActivity<FoodDeliveryAttributes>({
      activityType: 'FoodDelivery',
      attributes,
      contentState: state,
    });
  }

  /**
   * Update an existing food delivery activity
   */
  static async update(
    activityId: string,
    state: Partial<FoodDeliveryState>
  ): Promise<void> {
    return LiveActivities.updateActivity(activityId, { contentState: state });
  }

  /**
   * Mark delivery as delivered
   */
  static async complete(activityId: string): Promise<void> {
    return LiveActivities.endActivity(activityId, {
      finalContent: { status: 'delivered', statusStage: 4 },
      dismissalPolicy: 'after-date',
    });
  }

  /**
   * Cancel the delivery
   */
  static async cancel(activityId: string, reason?: string): Promise<void> {
    return LiveActivities.endActivity(activityId, {
      finalContent: { status: 'cancelled' },
      dismissalPolicy: 'immediate',
    });
  }

  /**
   * Update status with stage helper
   */
  static async updateStatus(
    activityId: string,
    status: FoodDeliveryStatus,
    stage: FoodDeliveryStage,
    additionalData?: Partial<FoodDeliveryState>
  ): Promise<void> {
    return this.update(activityId, {
      status,
      statusStage: stage,
      ...additionalData,
    });
  }

  /**
   * Convenience method: Mark as confirmed
   */
  static async markConfirmed(
    activityId: string,
    estimatedMinutes: number
  ): Promise<void> {
    return this.updateStatus(activityId, 'confirmed', 0, { estimatedMinutes });
  }

  /**
   * Convenience method: Mark as preparing
   */
  static async markPreparing(
    activityId: string,
    preparationTime: number
  ): Promise<void> {
    return this.updateStatus(activityId, 'preparing', 1, { preparationTime });
  }

  /**
   * Convenience method: Mark as picked up by rider
   */
  static async markPickedUp(
    activityId: string,
    riderName: string,
    riderPhone: string,
    estimatedMinutes: number
  ): Promise<void> {
    return this.updateStatus(activityId, 'picked_up', 2, {
      riderName,
      riderPhone,
      estimatedMinutes,
    });
  }

  /**
   * Convenience method: Mark as on the way
   */
  static async markOnTheWay(
    activityId: string,
    currentLocation: string,
    estimatedMinutes: number,
    distanceRemaining?: number
  ): Promise<void> {
    return this.updateStatus(activityId, 'on_the_way', 3, {
      currentLocation,
      estimatedMinutes,
      distanceRemaining,
    });
  }

  /**
   * Convenience method: Mark as arriving
   */
  static async markArriving(
    activityId: string,
    estimatedMinutes: number = 5
  ): Promise<void> {
    return this.updateStatus(activityId, 'arriving', 3, { estimatedMinutes });
  }

  /**
   * Get the current push token for server-side updates
   */
  static async getPushToken(activityId: string): Promise<string | null> {
    return LiveActivities.getPushToken(activityId);
  }
}
