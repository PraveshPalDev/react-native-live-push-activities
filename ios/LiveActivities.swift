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

// ✅ Generic Attributes for Custom Usage without modifying Native Code
public struct GenericActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public var data: String // JSON string
    }
    public var fixedData: String // JSON string
}

@objc(LiveActivities)
class LiveActivities: NSObject {
    
    // Store active activities in memory (can be lost on restart)
    private static var activeActivities: [String: Any] = [:]
    
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
            var activityId: String? = nil
            
            // Helper to convert Double timestamp to Date
            func date(from time: Any?) -> Date {
                let ms = (time as? Double) ?? Date().timeIntervalSince1970 * 1000
                return Date(timeIntervalSince1970: ms / 1000)
            }
            
            // Helper to encode dict to JSON string
            func json(_ dict: NSDictionary) -> String {
                if let data = try? JSONSerialization.data(withJSONObject: dict, options: []) {
                    return String(data: data, encoding: .utf8) ?? "{}"
                }
                return "{}"
            }
            
            switch activityType {
            case "RideTrackingAttributes", "RideTracking":
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
                    estimatedArrival: date(from: contentState["estimatedArrival"] ?? contentState["estimatedArrivalTimestamp"]),
                    distance: contentState["distance"] as? Double
                )
                let activity = try Activity.request(attributes: attr, content: .init(state: state, staleDate: nil))
                LiveActivities.activeActivities[activity.id] = activity
                activityId = activity.id
                
            case "DeliveryTrackingAttributes", "DeliveryTracking":
                let attr = DeliveryTrackingAttributes(
                    courierName: attributes["courierName"] as? String ?? "",
                    orderNumber: attributes["orderNumber"] as? String ?? "",
                    orderItems: attributes["orderItems"] as? String,
                    deliveryAddress: attributes["deliveryAddress"] as? String
                )
                let state = DeliveryTrackingAttributes.ContentState(
                    status: contentState["status"] as? String ?? "preparing",
                    currentLocation: contentState["currentLocation"] as? String,
                    estimatedArrival: date(from: contentState["estimatedArrival"] ?? contentState["estimatedArrivalTimestamp"]),
                    stopsRemaining: contentState["stopsRemaining"] as? Int
                )
                let activity = try Activity.request(attributes: attr, content: .init(state: state, staleDate: nil))
                LiveActivities.activeActivities[activity.id] = activity
                activityId = activity.id

            case "SportsScoreAttributes", "SportsScore":
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
                let activity = try Activity.request(attributes: attr, content: .init(state: state, staleDate: nil))
                LiveActivities.activeActivities[activity.id] = activity
                activityId = activity.id

            case "TimerAttributes", "Timer":
                let attr = TimerAttributes(
                    title: attributes["title"] as? String ?? "",
                    description: attributes["description"] as? String,
                    icon: attributes["icon"] as? String
                )
                let state = TimerAttributes.ContentState(
                    endTime: date(from: contentState["endTime"] ?? contentState["endTimeTimestamp"]),
                    isPaused: contentState["isPaused"] as? Bool ?? false,
                    remainingSeconds: contentState["remainingSeconds"] as? Double
                )
                let activity = try Activity.request(attributes: attr, content: .init(state: state, staleDate: nil))
                LiveActivities.activeActivities[activity.id] = activity
                activityId = activity.id
                
            case "GenericActivityAttributes", "GenericActivity":
                 let attr = GenericActivityAttributes(
                    fixedData: json(attributes)
                 )
                 let state = GenericActivityAttributes.ContentState(
                    data: json(contentState)
                 )
                 let activity = try Activity.request(attributes: attr, content: .init(state: state, staleDate: nil))
                 LiveActivities.activeActivities[activity.id] = activity
                 activityId = activity.id
                
            default:
                reject("E_INVALID_TYPE", "Unknown activity type: \(activityType)", nil)
                return
            }
            
            if let id = activityId {
                resolve(id)
            } else {
                reject("E_START_FAILED", "Activity ID was nil after start", nil)
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
            
            func json(_ dict: NSDictionary) -> String {
                if let data = try? JSONSerialization.data(withJSONObject: dict, options: []) {
                    return String(data: data, encoding: .utf8) ?? "{}"
                }
                return "{}"
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
            
            // Try to find activity across all known types (handles app restarts)
            var found = false
            
            // RIDE TRACKING
            if let activity = Activity<RideTrackingAttributes>.activities.first(where: { $0.id == activityId }) {
                found = true
                let state = RideTrackingAttributes.ContentState(
                    status: contentState["status"] as? String ?? activity.content.state.status,
                    currentLocation: contentState["currentLocation"] as? String ?? activity.content.state.currentLocation,
                    estimatedArrival: date(from: contentState["estimatedArrival"] ?? contentState["estimatedArrivalTimestamp"] ?? activity.content.state.estimatedArrival.timeIntervalSince1970 * 1000),
                    distance: contentState["distance"] as? Double ?? activity.content.state.distance
                )
                await activity.update(ActivityContent(state: state, staleDate: nil), alertConfiguration: alert)
            }
            
            // DELIVERY TRACKING
            if !found, let activity = Activity<DeliveryTrackingAttributes>.activities.first(where: { $0.id == activityId }) {
                found = true
                let state = DeliveryTrackingAttributes.ContentState(
                    status: contentState["status"] as? String ?? activity.content.state.status,
                    currentLocation: contentState["currentLocation"] as? String ?? activity.content.state.currentLocation,
                    estimatedArrival: date(from: contentState["estimatedArrival"] ?? contentState["estimatedArrivalTimestamp"] ?? activity.content.state.estimatedArrival.timeIntervalSince1970 * 1000),
                    stopsRemaining: contentState["stopsRemaining"] as? Int ?? activity.content.state.stopsRemaining
                )
                await activity.update(ActivityContent(state: state, staleDate: nil), alertConfiguration: alert)
            }
            
            // SPORTS SCORE
            if !found, let activity = Activity<SportsScoreAttributes>.activities.first(where: { $0.id == activityId }) {
                found = true
                let state = SportsScoreAttributes.ContentState(
                    homeScore: contentState["homeScore"] as? Int ?? activity.content.state.homeScore,
                    awayScore: contentState["awayScore"] as? Int ?? activity.content.state.awayScore,
                    period: contentState["period"] as? String ?? activity.content.state.period,
                    timeRemaining: contentState["timeRemaining"] as? String ?? activity.content.state.timeRemaining,
                    lastPlay: contentState["lastPlay"] as? String ?? activity.content.state.lastPlay,
                    isLive: contentState["isLive"] as? Bool ?? activity.content.state.isLive
                )
                await activity.update(ActivityContent(state: state, staleDate: nil), alertConfiguration: alert)
            }
            
            // TIMER
            if !found, let activity = Activity<TimerAttributes>.activities.first(where: { $0.id == activityId }) {
                found = true
                let state = TimerAttributes.ContentState(
                    endTime: date(from: contentState["endTime"] ?? contentState["endTimeTimestamp"] ?? activity.content.state.endTime.timeIntervalSince1970 * 1000),
                    isPaused: contentState["isPaused"] as? Bool ?? activity.content.state.isPaused,
                    remainingSeconds: contentState["remainingSeconds"] as? Double ?? activity.content.state.remainingSeconds
                )
                await activity.update(ActivityContent(state: state, staleDate: nil), alertConfiguration: alert)
            }
            
            // GENERIC
            if !found, let activity = Activity<GenericActivityAttributes>.activities.first(where: { $0.id == activityId }) {
                found = true
                let state = GenericActivityAttributes.ContentState(
                    data: json(contentState)
                )
                await activity.update(ActivityContent(state: state, staleDate: nil), alertConfiguration: alert)
            }
            
            if found {
                resolve(nil)
            } else {
                reject("E_NOT_FOUND", "Activity with ID \(activityId) not found", nil)
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
            var found = false
            let policy: ActivityUIDismissalPolicy = (dismissalPolicy == "immediate") ? .immediate : .default
            
            // Try to end across all known types
            if let activity = Activity<RideTrackingAttributes>.activities.first(where: { $0.id == activityId }) {
                found = true; await activity.end(nil, dismissalPolicy: policy)
            } else if let activity = Activity<DeliveryTrackingAttributes>.activities.first(where: { $0.id == activityId }) {
                found = true; await activity.end(nil, dismissalPolicy: policy)
            } else if let activity = Activity<SportsScoreAttributes>.activities.first(where: { $0.id == activityId }) {
                found = true; await activity.end(nil, dismissalPolicy: policy)
            } else if let activity = Activity<TimerAttributes>.activities.first(where: { $0.id == activityId }) {
                found = true; await activity.end(nil, dismissalPolicy: policy)
            } else if let activity = Activity<GenericActivityAttributes>.activities.first(where: { $0.id == activityId }) {
                found = true; await activity.end(nil, dismissalPolicy: policy)
            }
            
            if found {
                LiveActivities.activeActivities.removeValue(forKey: activityId)
                resolve(nil)
            } else {
                resolve(nil) 
            }
        }
    }
    
    @objc
    func getActiveActivities(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        guard #available(iOS 16.1, *) else {
            resolve([])
            return
        }
        
        // Combine all activity IDs from system (robust check)
        var allIds: [String] = []
        allIds.append(contentsOf: Activity<RideTrackingAttributes>.activities.map { $0.id })
        allIds.append(contentsOf: Activity<DeliveryTrackingAttributes>.activities.map { $0.id })
        allIds.append(contentsOf: Activity<SportsScoreAttributes>.activities.map { $0.id })
        allIds.append(contentsOf: Activity<TimerAttributes>.activities.map { $0.id })
         allIds.append(contentsOf: Activity<GenericActivityAttributes>.activities.map { $0.id })
        
        resolve(allIds)
    }
    
    @objc
    func endAllActivities(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        guard #available(iOS 16.1, *) else { resolve(nil); return }
        
        Task {
            for activity in Activity<RideTrackingAttributes>.activities { await activity.end(nil, dismissalPolicy: .immediate) }
            for activity in Activity<DeliveryTrackingAttributes>.activities { await activity.end(nil, dismissalPolicy: .immediate) }
            for activity in Activity<SportsScoreAttributes>.activities { await activity.end(nil, dismissalPolicy: .immediate) }
            for activity in Activity<TimerAttributes>.activities { await activity.end(nil, dismissalPolicy: .immediate) }
             for activity in Activity<GenericActivityAttributes>.activities { await activity.end(nil, dismissalPolicy: .immediate) }
            
            LiveActivities.activeActivities.removeAll()
            resolve(nil)
        }
    }
    
    @objc
    func getPushToken(_ activityId: String, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        guard #available(iOS 16.1, *) else { resolve(nil); return }
        
        Task {
            var tokenFound = ""
            
            func extractToken<T: ActivityAttributes>(activity: Activity<T>) async -> String? {
                 for await data in activity.pushTokenUpdates {
                    let token = data.map { String(format: "%02x", $0) }.joined()
                    return token
                 }
                 return nil
            }

            // Find activity and get token
            if let activity = Activity<RideTrackingAttributes>.activities.first(where: { $0.id == activityId }) {
               if let t = await extractToken(activity: activity) { tokenFound = t }
            } else if let activity = Activity<DeliveryTrackingAttributes>.activities.first(where: { $0.id == activityId }) {
               if let t = await extractToken(activity: activity) { tokenFound = t }
            } else if let activity = Activity<SportsScoreAttributes>.activities.first(where: { $0.id == activityId }) {
               if let t = await extractToken(activity: activity) { tokenFound = t }
            } else if let activity = Activity<TimerAttributes>.activities.first(where: { $0.id == activityId }) {
               if let t = await extractToken(activity: activity) { tokenFound = t }
            } else if let activity = Activity<GenericActivityAttributes>.activities.first(where: { $0.id == activityId }) {
               if let t = await extractToken(activity: activity) { tokenFound = t }
            }
            
            if !tokenFound.isEmpty {
                resolve(tokenFound)
            } else {
                resolve(nil)
            }
        }
    }
}
