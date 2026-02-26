import { LiveActivities } from '../index';
import type {
  EcommerceDeliveryAttributes,
  EcommerceDeliveryState,
  EcommerceDeliveryStatus,
  EcommerceDeliveryStage,
} from '../types';

/**
 * E-commerce Delivery Template (Flipkart/Amazon-style)
 * 
 * Features:
 * - Multi-day tracking timeline
 * - Shipment stages (Ordered → Shipped → In Transit → Out for Delivery → Delivered)
 * - Courier partner info
 * - Tracking URL integration
 * - Delivery attempt notifications
 * - Reschedule option
 * 
 * @example
 * const activityId = await EcommerceDelivery.start(
 *   {
 *     orderId: 'EC-12345',
 *     productName: 'iPhone 15 Pro Max',
 *     productImage: 'https://example.com/iphone.png',
 *     courierPartner: 'BlueDart',
 *     trackingUrl: 'https://bluedart.com/track/123',
 *   },
 *   {
 *     status: 'ordered',
 *     statusStage: 0,
 *     estimatedDeliveryDate: Date.now() + 3 * 24 * 60 * 60 * 1000, // 3 days
 *   }
 * );
 * 
 * // Update to shipped
 * await EcommerceDelivery.markShipped(activityId, 'BD-TRACK-123', 'Delhi Hub');
 * 
 * // Update to in transit
 * await EcommerceDelivery.markInTransit(activityId, 'Mumbai Hub');
 * 
 * // Mark as out for delivery
 * await EcommerceDelivery.markOutForDelivery(activityId);
 * 
 * // Mark as delivered
 * await EcommerceDelivery.complete(activityId);
 */
export class EcommerceDelivery {
  /**
   * Start a new e-commerce delivery tracking activity
   */
  static async start(
    attributes: EcommerceDeliveryAttributes,
    state: EcommerceDeliveryState
  ): Promise<string> {
    return LiveActivities.startActivity<EcommerceDeliveryAttributes>({
      activityType: 'EcommerceDelivery',
      attributes,
      contentState: state,
    });
  }

  /**
   * Update an existing e-commerce delivery activity
   */
  static async update(
    activityId: string,
    state: Partial<EcommerceDeliveryState>
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
   * Mark as returned
   */
  static async markReturned(activityId: string, reason?: string): Promise<void> {
    return LiveActivities.endActivity(activityId, {
      finalContent: { status: 'returned' },
      dismissalPolicy: 'immediate',
    });
  }

  /**
   * Update status with stage helper
   */
  static async updateStatus(
    activityId: string,
    status: EcommerceDeliveryStatus,
    stage: EcommerceDeliveryStage,
    additionalData?: Partial<EcommerceDeliveryState>
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
    estimatedDeliveryDate: number
  ): Promise<void> {
    return this.updateStatus(activityId, 'confirmed', 0, { estimatedDeliveryDate });
  }

  /**
   * Convenience method: Mark as shipped
   */
  static async markShipped(
    activityId: string,
    trackingNumber: string,
    currentHub: string
  ): Promise<void> {
    return this.updateStatus(activityId, 'shipped', 1, {
      trackingNumber,
      currentHub,
    });
  }

  /**
   * Convenience method: Mark as in transit
   */
  static async markInTransit(
    activityId: string,
    currentHub: string
  ): Promise<void> {
    return this.updateStatus(activityId, 'in_transit', 2, { currentHub });
  }

  /**
   * Convenience method: Mark as out for delivery
   */
  static async markOutForDelivery(
    activityId: string,
    courierPartner?: string
  ): Promise<void> {
    return this.updateStatus(activityId, 'out_for_delivery', 3, {
      courierPartner,
    });
  }

  /**
   * Mark delivery attempt failed
   */
  static async markDeliveryAttempted(
    activityId: string,
    attempts: number,
    rescheduleAvailable: boolean = true
  ): Promise<void> {
    return this.update(activityId, {
      status: 'delivery_attempted',
      deliveryAttempts: attempts,
      rescheduleAvailable,
    });
  }

  /**
   * Get the current push token for server-side updates
   */
  static async getPushToken(activityId: string): Promise<string | null> {
    return LiveActivities.getPushToken(activityId);
  }
}
