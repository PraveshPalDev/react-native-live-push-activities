/**
 * Type definitions for Live Push Activities
 */

// ============================================================================
// Quick Commerce Types (Zepto-style)
// ============================================================================

export interface QuickCommerceAttributes {
  orderId: string;
  items?: string;
  appIcon?: string;
  deepLink?: string;
}

export type QuickCommerceStatus =
  | 'confirmed'
  | 'preparing'
  | 'picked_up'
  | 'on_the_way'
  | 'arriving'
  | 'delivered'
  | 'cancelled';

export interface QuickCommerceState {
  status: QuickCommerceStatus;
  progress: number; // 0-100
  estimatedMinutes: number;
  riderName?: string;
  riderPhone?: string;
  riderPhoto?: string;
  currentLocation?: string;
  storeName?: string;
  storeLogo?: string;
}

// ============================================================================
// Food Delivery Types (Swiggy/Zomato-style)
// ============================================================================

export interface FoodDeliveryAttributes {
  orderId: string;
  restaurantName: string;
  restaurantLogo?: string;
  orderItems?: string;
  deliveryAddress?: string;
  appIcon?: string;
  deepLink?: string;
}

export type FoodDeliveryStatus =
  | 'confirmed'
  | 'preparing'
  | 'picked_up'
  | 'on_the_way'
  | 'arriving'
  | 'delivered'
  | 'cancelled';

export type FoodDeliveryStage =
  | 0 // Confirmed
  | 1 // Preparing
  | 2 // Picked Up
  | 3 // On the Way
  | 4 // Delivered;

export interface FoodDeliveryState {
  status: FoodDeliveryStatus;
  statusStage: FoodDeliveryStage;
  estimatedMinutes: number;
  riderName?: string;
  riderPhone?: string;
  riderPhoto?: string;
  currentLocation?: string;
  preparationTime?: number;
  distanceRemaining?: number;
}

// ============================================================================
// E-commerce Delivery Types (Flipkart/Amazon-style)
// ============================================================================

export interface EcommerceDeliveryAttributes {
  orderId: string;
  productName: string;
  productImage?: string;
  productDescription?: string;
  courierPartner?: string;
  trackingUrl?: string;
  appIcon?: string;
  deepLink?: string;
}

export type EcommerceDeliveryStatus =
  | 'ordered'
  | 'confirmed'
  | 'shipped'
  | 'in_transit'
  | 'out_for_delivery'
  | 'delivered'
  | 'delivery_attempted'
  | 'cancelled'
  | 'returned';

export type EcommerceDeliveryStage =
  | 0 // Ordered
  | 1 // Shipped
  | 2 // In Transit
  | 3 // Out for Delivery
  | 4 // Delivered;

export interface EcommerceDeliveryState {
  status: EcommerceDeliveryStatus;
  statusStage: EcommerceDeliveryStage;
  estimatedDeliveryDate?: number; // timestamp in milliseconds
  courierPartner?: string;
  trackingNumber?: string;
  currentHub?: string;
  deliveryAttempts?: number;
  rescheduleAvailable?: boolean;
}

// ============================================================================
// Generic Delivery Types (Fully Customizable)
// ============================================================================

export interface GenericDeliveryAttributes {
  id: string;
  type: 'delivery' | 'service' | 'booking' | 'ride' | 'custom';
  appIcon?: string;
  deepLink?: string;
}

export interface GenericDeliveryState {
  title: string;
  subtitle?: string;
  status: string;
  progress?: number; // 0-100
  primaryImage?: string;
  secondaryImage?: string;
  actionLabel?: string;
  actionDeepLink?: string;
  secondaryActionLabel?: string;
  secondaryActionDeepLink?: string;
  customData?: string; // JSON string for additional data
}

// ============================================================================
// Common Types
// ============================================================================

export interface AlertConfig {
  title?: string;
  body?: string;
  sound?: string;
}

export interface ActivityConfig<T = any> {
  activityType: string;
  attributes: T;
  contentState: Record<string, any>;
  staleDate?: number;
  relevanceScore?: number;
}

export interface UpdateConfig {
  contentState: Record<string, any>;
  alertConfig?: AlertConfig;
  staleDate?: number;
}

export interface EndConfig {
  finalContent?: Record<string, any>;
  dismissalPolicy?: 'immediate' | 'after-date' | 'default';
}

// ============================================================================
// Push Notification Types
// ============================================================================

export interface IOSPushPayload {
  'timestamp': number;
  'event': 'update' | 'end';
  'content-state': Record<string, any>;
  'alert'?: {
    'title'?: string;
    'body'?: string;
    'sound'?: string;
  };
}

export interface AndroidPushPayload {
  data: {
    type: string;
    notificationId: string;
    status: string;
    progress?: number;
    [key: string]: any;
  };
  notification?: {
    title?: string;
    body?: string;
    image?: string;
  };
  android?: {
    channel_id?: string;
    priority?: 'high' | 'default' | 'low';
    ttl?: number;
  };
}
