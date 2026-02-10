import ActivityKit
import Foundation
import React

// MARK: - Activity Attributes Definitions

// These structs MUST match exactly what you define in your Widget Extension.
// Copy these into a file in your Widget Extension target.

public struct RideTrackingAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public var status: String
        public var currentLocation: String?
        public var estimatedArrival: Date // Use Date for timestamps
        public var distance: Double?
    }
    
    public var driverName: String
    public var vehicleNumber: String
    public var vehicleType: String?
    public var pickup: String
    public var dropoff: String
    public var driverPhoto: String?
}

public struct DeliveryTrackingAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public var status: String
        public var currentLocation: String?
        public var estimatedArrival: Date
        public var stopsRemaining: Int?
    }
    
    public var courierName: String
    public var orderNumber: String
    public var orderItems: String?
    public var deliveryAddress: String?
}

public struct SportsScoreAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public var homeScore: Int
        public var awayScore: Int
        public var period: String
        public var timeRemaining: String?
        public var lastPlay: String?
        public var isLive: Bool
    }
    
    public var homeTeam: String
    public var awayTeam: String
    public var homeTeamLogo: String?
    public var awayTeamLogo: String?
    public var league: String?
}

public struct TimerAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public var endTime: Date
        public var isPaused: Bool
        public var remainingSeconds: Double?
    }
    
    public var title: String
    public var description: String?
    public var icon: String?
}

@objc(LiveActivities)
class LiveActivities: NSObject {
    
    // Store active activities
    private static var activeActivities: [String: Any?] = [:]
    
    // MARK: - Check Status
    
    @objc
    func areActivitiesEnabled(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        if #available(iOS 16.1, *) {
            resolve(ActivityAuthorizationInfo().areActivitiesEnabled)
        } else {
            resolve(false)
        }
    }
    
    // MARK: - Start Activity
    
    @objc
    func startActivity(_ activityType: String,
                       attributes: NSDictionary,
                       contentState: NSDictionary,
                       staleDate: NSNumber?,
                       relevanceScore: NSNumber?,
                       resolver resolve: @escaping RCTPromiseResolveBlock,
                       rejecter reject: @escaping RCTPromiseRejectBlock) {
        
        guard #available(iOS 16.1, *) else {
            reject("E_NOT_SUPPORTED", "Live Activities require iOS 16.1+", nil)
            return
        }
        
        do {
            let activityId = UUID().uuidString
            var activity: Any? = nil
            
            // Helper to convert Double timestamp to Date
            func date(from time: Any?) -> Date {
                let ms = (time as? Double) ?? Date().timeIntervalSince1970 * 1000
                return Date(timeIntervalSince1970: ms / 1000)
            }
            
            switch activityType {
            case "RideTracking":
                let attr = RideTrackingAttributes(
                    driverName: attributes["driverName"] as? String ?? "",
                    vehicleNumber: attributes["vehicleNumber"] as? String ?? "",
                    vehicleType: attributes["vehicleType"] as? String,
                    pickup: attributes["pickup"] as? String ?? "",
                    dropoff: attributes["dropoff"] as? String ?? "",
                    driverPhoto: attributes["driverPhoto"] as? String
                )
                let state = RideTrackingAttributes.ContentState(
                    status: contentState["status"] as? String ?? "waiting",
                    currentLocation: contentState["currentLocation"] as? String,
                    estimatedArrival: date(from: contentState["estimatedArrival"]),
                    distance: contentState["distance"] as? Double
                )
                activity = try Activity.request(attributes: attr, content: .init(state: state, staleDate: nil))
                
            case "DeliveryTracking":
                let attr = DeliveryTrackingAttributes(
                    courierName: attributes["courierName"] as? String ?? "",
                    orderNumber: attributes["orderNumber"] as? String ?? "",
                    orderItems: attributes["orderItems"] as? String,
                    deliveryAddress: attributes["deliveryAddress"] as? String
                )
                let state = DeliveryTrackingAttributes.ContentState(
                    status: contentState["status"] as? String ?? "preparing",
                    currentLocation: contentState["currentLocation"] as? String,
                    estimatedArrival: date(from: contentState["estimatedArrival"]),
                    stopsRemaining: contentState["stopsRemaining"] as? Int
                )
                activity = try Activity.request(attributes: attr, content: .init(state: state, staleDate: nil))

            case "SportsScore":
                let attr = SportsScoreAttributes(
                    homeTeam: attributes["homeTeam"] as? String ?? "",
                    awayTeam: attributes["awayTeam"] as? String ?? "",
                    homeTeamLogo: attributes["homeTeamLogo"] as? String,
                    awayTeamLogo: attributes["awayTeamLogo"] as? String,
                    league: attributes["league"] as? String
                )
                let state = SportsScoreAttributes.ContentState(
                    homeScore: contentState["homeScore"] as? Int ?? 0,
                    awayScore: contentState["awayScore"] as? Int ?? 0,
                    period: contentState["period"] as? String ?? "1st",
                    timeRemaining: contentState["timeRemaining"] as? String,
                    lastPlay: contentState["lastPlay"] as? String,
                    isLive: contentState["isLive"] as? Bool ?? true
                )
                activity = try Activity.request(attributes: attr, content: .init(state: state, staleDate: nil))

            case "Timer":
                let attr = TimerAttributes(
                    title: attributes["title"] as? String ?? "",
                    description: attributes["description"] as? String,
                    icon: attributes["icon"] as? String
                )
                let state = TimerAttributes.ContentState(
                    endTime: date(from: contentState["endTime"]),
                    isPaused: contentState["isPaused"] as? Bool ?? false,
                    remainingSeconds: contentState["remainingSeconds"] as? Double
                )
                activity = try Activity.request(attributes: attr, content: .init(state: state, staleDate: nil))
                
            default:
                reject("E_INVALID_TYPE", "Unknown activity type: \(activityType)", nil)
                return
            }
            
            if let act = activity as? Activity<RideTrackingAttributes> {
                LiveActivities.activeActivities[act.id] = act
                resolve(act.id)
            } else if let act = activity as? Activity<DeliveryTrackingAttributes> {
                LiveActivities.activeActivities[act.id] = act
                resolve(act.id)
            } else if let act = activity as? Activity<SportsScoreAttributes> {
                LiveActivities.activeActivities[act.id] = act
                resolve(act.id)
            } else if let act = activity as? Activity<TimerAttributes> {
                LiveActivities.activeActivities[act.id] = act
                resolve(act.id)
            } else {
                reject("E_START_FAILED", "Failed to cast activity", nil)
            }
            
        } catch {
            reject("E_START_FAILED", error.localizedDescription, error)
        }
    }
    
    // MARK: - Update Activity
    
    @objc
    func updateActivity(_ activityId: String,
                       contentState: NSDictionary,
                       alertConfig: NSDictionary?,
                       staleDate: NSNumber?,
                       resolver resolve: @escaping RCTPromiseResolveBlock,
                       rejecter reject: @escaping RCTPromiseRejectBlock) {
        
        guard #available(iOS 16.1, *) else {
            reject("E_NOT_SUPPORTED", "Live Activities require iOS 16.1+", nil)
            return
        }
        
        Task {
            // Helper to convert Double to Date
            func date(from time: Any?) -> Date {
                let ms = (time as? Double) ?? Date().timeIntervalSince1970 * 1000
                return Date(timeIntervalSince1970: ms / 1000)
            }
            
            // Construct Alert Configuration
            var alert: AlertConfiguration? = nil
            if let config = alertConfig {
                alert = AlertConfiguration(
                    title: config["title"] as? LocalizedStringResource ?? "",
                    body: config["body"] as? LocalizedStringResource ?? "",
                    sound: .default
                )
            }
            
            // Attempt to update based on stored type
            if let activity = LiveActivities.activeActivities[activityId] as? Activity<RideTrackingAttributes> {
                let state = RideTrackingAttributes.ContentState(
                    status: contentState["status"] as? String ?? activity.content.state.status,
                    currentLocation: contentState["currentLocation"] as? String ?? activity.content.state.currentLocation,
                    estimatedArrival: date(from: contentState["estimatedArrival"] ?? activity.content.state.estimatedArrival.timeIntervalSince1970 * 1000),
                    distance: contentState["distance"] as? Double ?? activity.content.state.distance
                )
                await activity.update(ActivityContent(state: state, staleDate: nil), alertConfiguration: alert)
                resolve(nil)
            }
            else if let activity = LiveActivities.activeActivities[activityId] as? Activity<DeliveryTrackingAttributes> {
                let state = DeliveryTrackingAttributes.ContentState(
                    status: contentState["status"] as? String ?? activity.content.state.status,
                    currentLocation: contentState["currentLocation"] as? String ?? activity.content.state.currentLocation,
                    estimatedArrival: date(from: contentState["estimatedArrival"] ?? activity.content.state.estimatedArrival.timeIntervalSince1970 * 1000),
                    stopsRemaining: contentState["stopsRemaining"] as? Int ?? activity.content.state.stopsRemaining
                )
                await activity.update(ActivityContent(state: state, staleDate: nil), alertConfiguration: alert)
                resolve(nil)
            }
            else if let activity = LiveActivities.activeActivities[activityId] as? Activity<SportsScoreAttributes> {
                let state = SportsScoreAttributes.ContentState(
                    homeScore: contentState["homeScore"] as? Int ?? activity.content.state.homeScore,
                    awayScore: contentState["awayScore"] as? Int ?? activity.content.state.awayScore,
                    period: contentState["period"] as? String ?? activity.content.state.period,
                    timeRemaining: contentState["timeRemaining"] as? String ?? activity.content.state.timeRemaining,
                    lastPlay: contentState["lastPlay"] as? String ?? activity.content.state.lastPlay,
                    isLive: contentState["isLive"] as? Bool ?? activity.content.state.isLive
                )
                await activity.update(ActivityContent(state: state, staleDate: nil), alertConfiguration: alert)
                resolve(nil)
            }
            else if let activity = LiveActivities.activeActivities[activityId] as? Activity<TimerAttributes> {
                let state = TimerAttributes.ContentState(
                    endTime: date(from: contentState["endTime"] ?? activity.content.state.endTime.timeIntervalSince1970 * 1000),
                    isPaused: contentState["isPaused"] as? Bool ?? activity.content.state.isPaused,
                    remainingSeconds: contentState["remainingSeconds"] as? Double ?? activity.content.state.remainingSeconds
                )
                await activity.update(ActivityContent(state: state, staleDate: nil), alertConfiguration: alert)
                resolve(nil)
            }
            else {
                // Try to find by ID if not in memory (e.g. app restart)
                // Note: This simple implementation relies on memory cache.
                // For production, you'd iterate Activity<T>.activities
                reject("E_NOT_FOUND", "Activity not found in current session", nil)
            }
        }
    }
    
    // MARK: - End & List
    
    @objc
    func endActivity(_ activityId: String,
                     finalContent: NSDictionary?,
                     dismissalPolicy: String,
                     resolver resolve: @escaping RCTPromiseResolveBlock,
                     rejecter reject: @escaping RCTPromiseRejectBlock) {
        
        guard #available(iOS 16.1, *) else {
            reject("E_NOT_SUPPORTED", "iOS 16.1+ required", nil)
            return
        }
        
        Task {
            func end<T: ActivityAttributes>(activity: Activity<T>?) async {
                guard let activity = activity else { return }
                await activity.end(nil, dismissalPolicy: .default)
            }
            
            if let activity = LiveActivities.activeActivities[activityId] as? Activity<RideTrackingAttributes> {
                await end(activity: activity)
            } else if let activity = LiveActivities.activeActivities[activityId] as? Activity<DeliveryTrackingAttributes> {
                await end(activity: activity)
            } else if let activity = LiveActivities.activeActivities[activityId] as? Activity<SportsScoreAttributes> {
                await end(activity: activity)
            } else if let activity = LiveActivities.activeActivities[activityId] as? Activity<TimerAttributes> {
                await end(activity: activity)
            }
            
            LiveActivities.activeActivities.removeValue(forKey: activityId)
            resolve(nil)
        }
    }
    
    @objc
    func getActiveActivities(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        // Return keys from our memory cache
        resolve(Array(LiveActivities.activeActivities.keys))
    }
    
    @objc
    func endAllActivities(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        guard #available(iOS 16.1, *) else { resolve(nil); return }
        
        Task {
            for activity in Activity<RideTrackingAttributes>.activities { await activity.end(nil, dismissalPolicy: .immediate) }
            for activity in Activity<DeliveryTrackingAttributes>.activities { await activity.end(nil, dismissalPolicy: .immediate) }
            for activity in Activity<SportsScoreAttributes>.activities { await activity.end(nil, dismissalPolicy: .immediate) }
            for activity in Activity<TimerAttributes>.activities { await activity.end(nil, dismissalPolicy: .immediate) }
            
            LiveActivities.activeActivities.removeAll()
            resolve(nil)
        }
    }
    
    @objc
    func getPushToken(_ activityId: String, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        guard #available(iOS 16.1, *) else { resolve(nil); return }
        
        // Helper to get token
        func getToken<T: ActivityAttributes>(activity: Activity<T>?) {
            guard let activity = activity else { resolve(nil); return }
            Task {
                for await data in activity.pushTokenUpdates {
                    let token = data.map { String(format: "%02x", $0) }.joined()
                    resolve(token)
                    return
                }
            }
        }

        if let activity = LiveActivities.activeActivities[activityId] as? Activity<RideTrackingAttributes> { getToken(activity: activity) }
        else if let activity = LiveActivities.activeActivities[activityId] as? Activity<DeliveryTrackingAttributes> { getToken(activity: activity) }
        else if let activity = LiveActivities.activeActivities[activityId] as? Activity<SportsScoreAttributes> { getToken(activity: activity) }
        else if let activity = LiveActivities.activeActivities[activityId] as? Activity<TimerAttributes> { getToken(activity: activity) }
        else { resolve(nil) }
    }
}
