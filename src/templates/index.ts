import { LiveActivities } from '../index';

/**
 * Ride Tracking Template
 */
export interface RideTrackingAttributes {
  driverName: string;
  vehicleNumber: string;
  vehicleType?: string;
  pickup: string;
  dropoff: string;
  driverPhoto?: string;
}

export interface RideTrackingState {
  status: 'waiting' | 'on-the-way' | 'arriving' | 'in-progress' | 'completed';
  currentLocation?: string;
  estimatedArrival: number;
  distance?: number;
}

export class RideTracking {
  static async start(
    attributes: RideTrackingAttributes,
    state: RideTrackingState
  ): Promise<string> {
    return LiveActivities.startActivity<RideTrackingAttributes>({
      activityType: 'RideTracking',
      attributes,
      contentState: state,
    });
  }

  static async update(
    activityId: string,
    state: Partial<RideTrackingState>
  ): Promise<void> {
    return LiveActivities.updateActivity(activityId, { contentState: state });
  }

  static async complete(activityId: string): Promise<void> {
    return LiveActivities.endActivity(activityId, {
      finalContent: { status: 'completed' },
      dismissalPolicy: 'after-date',
    });
  }
}

/**
 * Delivery Tracking Template
 */
export interface DeliveryTrackingAttributes {
  courierName: string;
  orderNumber: string;
  orderItems?: string;
  deliveryAddress?: string;
}

export interface DeliveryTrackingState {
  status:
    | 'preparing'
    | 'out-for-delivery'
    | 'nearby'
    | 'delivered'
    | 'failed';
  currentLocation?: string;
  estimatedArrival: number;
  stopsRemaining?: number;
}

export class DeliveryTracking {
  static async start(
    attributes: DeliveryTrackingAttributes,
    state: DeliveryTrackingState
  ): Promise<string> {
    return LiveActivities.startActivity<DeliveryTrackingAttributes>({
      activityType: 'DeliveryTracking',
      attributes,
      contentState: state,
    });
  }

  static async update(
    activityId: string,
    state: Partial<DeliveryTrackingState>
  ): Promise<void> {
    return LiveActivities.updateActivity(activityId, { contentState: state });
  }

  static async complete(
    activityId: string,
    wasDelivered: boolean = true
  ): Promise<void> {
    return LiveActivities.endActivity(activityId, {
      finalContent: {
        status: wasDelivered ? 'delivered' : 'failed',
      },
    });
  }
}

/**
 * Sports Score Template
 */
export interface SportsScoreAttributes {
  homeTeam: string;
  awayTeam: string;
  homeTeamLogo?: string;
  awayTeamLogo?: string;
  league?: string;
}

export interface SportsScoreState {
  homeScore: number;
  awayScore: number;
  period: string;
  timeRemaining?: string;
  lastPlay?: string;
  isLive: boolean;
}

export class SportsScore {
  static async start(
    attributes: SportsScoreAttributes,
    state: SportsScoreState
  ): Promise<string> {
    return LiveActivities.startActivity<SportsScoreAttributes>({
      activityType: 'SportsScore',
      attributes,
      contentState: state,
    });
  }

  static async update(
    activityId: string,
    state: Partial<SportsScoreState>
  ): Promise<void> {
    return LiveActivities.updateActivity(activityId, { contentState: state });
  }

  static async endGame(activityId: string): Promise<void> {
    return LiveActivities.endActivity(activityId, {
      finalContent: { isLive: false },
    });
  }
}

/**
 * Timer Template
 */
export interface TimerAttributes {
  title: string;
  description?: string;
  icon?: string;
}

export interface TimerState {
  endTime: number;
  isPaused: boolean;
  remainingSeconds?: number;
}

export class Timer {
  static async start(
    attributes: TimerAttributes,
    durationSeconds: number
  ): Promise<string> {
    const endTime = Date.now() + durationSeconds * 1000;
    return LiveActivities.startActivity<TimerAttributes>({
      activityType: 'Timer',
      attributes,
      contentState: {
        endTime,
        isPaused: false,
        remainingSeconds: durationSeconds,
      },
    });
  }

  static async pause(activityId: string): Promise<void> {
    return LiveActivities.updateActivity(activityId, {
      contentState: { isPaused: true },
    });
  }

  static async resume(activityId: string, remainingSeconds: number): Promise<void> {
    const endTime = Date.now() + remainingSeconds * 1000;
    return LiveActivities.updateActivity(activityId, {
      contentState: {
        endTime,
        isPaused: false,
        remainingSeconds,
      },
    });
  }

  static async complete(activityId: string): Promise<void> {
    return LiveActivities.endActivity(activityId);
  }
}

/**
 * Export all templates
 */
export const Templates = {
  RideTracking,
  DeliveryTracking,
  SportsScore,
  Timer,
};
