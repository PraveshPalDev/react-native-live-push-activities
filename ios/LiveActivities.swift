import Foundation
import ActivityKit
import React

@objc(LiveActivities)
class LiveActivities: NSObject {
    
    // Storage for active activities
    private static var activeActivities: [String: Any] = [:]
    
    // MARK: - Check if Live Activities are enabled
    
    @objc
    func areActivitiesEnabled(_ resolve: @escaping RCTPromiseResolveBlock,
                             rejecter reject: @escaping RCTPromiseRejectBlock) {
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
            reject("E_NOT_SUPPORTED", "Live Activities require iOS 16.1 or higher", nil)
            return
        }
        
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            reject("E_NOT_ENABLED", "Live Activities are not enabled", nil)
            return
        }
        
        DispatchQueue.main.async {
            do {
                // Create activity based on type
                let activityId = UUID().uuidString
                
                switch activityType {
                case "RideTracking":
                    let activity = try self.startRideTrackingActivity(
                        attributes: attributes,
                        contentState: contentState,
                        staleDate: staleDate,
                        relevanceScore: relevanceScore
                    )
                    LiveActivities.activeActivities[activityId] = activity
                    
                case "DeliveryTracking":
                    let activity = try self.startDeliveryTrackingActivity(
                        attributes: attributes,
                        contentState: contentState,
                        staleDate: staleDate,
                        relevanceScore: relevanceScore
                    )
                    LiveActivities.activeActivities[activityId] = activity
                    
                case "SportsScore":
                    let activity = try self.startSportsScoreActivity(
                        attributes: attributes,
                        contentState: contentState,
                        staleDate: staleDate,
                        relevanceScore: relevanceScore
                    )
                    LiveActivities.activeActivities[activityId] = activity
                    
                case "Timer":
                    let activity = try self.startTimerActivity(
                        attributes: attributes,
                        contentState: contentState,
                        staleDate: staleDate,
                        relevanceScore: relevanceScore
                    )
                    LiveActivities.activeActivities[activityId] = activity
                    
                default:
                    // Generic activity - you can extend this
                    reject("E_INVALID_TYPE", "Unknown activity type: \\(activityType)", nil)
                    return
                }
                
                resolve(activityId)
                
            } catch {
                reject("E_START_FAILED", "Failed to start activity: \\(error.localizedDescription)", error)
            }
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
            reject("E_NOT_SUPPORTED", "Live Activities require iOS 16.1 or higher", nil)
            return
        }
        
        DispatchQueue.main.async {
            guard let activity = LiveActivities.activeActivities[activityId] else {
                reject("E_NOT_FOUND", "Activity not found", nil)
                return
            }
            
            do {
                try self.updateActivityContent(
                    activity: activity,
                    contentState: contentState,
                    alertConfig: alertConfig,
                    staleDate: staleDate
                )
                resolve(nil)
            } catch {
                reject("E_UPDATE_FAILED", "Failed to update activity: \\(error.localizedDescription)", error)
            }
        }
    }
    
    // MARK: - End Activity
    
    @objc
    func endActivity(_ activityId: String,
                    finalContent: NSDictionary?,
                    dismissalPolicy: String,
                    resolver resolve: @escaping RCTPromiseResolveBlock,
                    rejecter reject: @escaping RCTPromiseRejectBlock) {
        
        guard #available(iOS 16.1, *) else {
            reject("E_NOT_SUPPORTED", "Live Activities require iOS 16.1 or higher", nil)
            return
        }
        
        DispatchQueue.main.async {
            guard let activity = LiveActivities.activeActivities[activityId] else {
                reject("E_NOT_FOUND", "Activity not found", nil)
                return
            }
            
            Task {
                do {
                    try await self.endActivityContent(
                        activity: activity,
                        finalContent: finalContent,
                        dismissalPolicy: dismissalPolicy
                    )
                    LiveActivities.activeActivities.removeValue(forKey: activityId)
                    resolve(nil)
                } catch {
                    reject("E_END_FAILED", "Failed to end activity: \\(error.localizedDescription)", error)
                }
            }
        }
    }
    
    // MARK: - Get Active Activities
    
    @objc
    func getActiveActivities(_ resolve: @escaping RCTPromiseResolveBlock,
                            rejecter reject: @escaping RCTPromiseRejectBlock) {
        let activityIds = Array(LiveActivities.activeActivities.keys)
        resolve(activityIds)
    }
    
    // MARK: - End All Activities
    
    @objc
    func endAllActivities(_ resolve: @escaping RCTPromiseResolveBlock,
                         rejecter reject: @escaping RCTPromiseRejectBlock) {
        
        guard #available(iOS 16.1, *) else {
            reject("E_NOT_SUPPORTED", "Live Activities require iOS 16.1 or higher", nil)
            return
        }
        
        Task {
            for (activityId, activity) in LiveActivities.activeActivities {
                do {
                    try await self.endActivityContent(
                        activity: activity,
                        finalContent: nil,
                        dismissalPolicy: "default"
                    )
                } catch {
                    print("Failed to end activity \\(activityId): \\(error)")
                }
            }
            LiveActivities.activeActivities.removeAll()
            resolve(nil)
        }
    }
    
    // MARK: - Get Push Token
    
    @objc
    func getPushToken(_ activityId: String,
                     resolver resolve: @escaping RCTPromiseResolveBlock,
                     rejecter reject: @escaping RCTPromiseRejectBlock) {
        
        guard #available(iOS 16.1, *) else {
            reject("E_NOT_SUPPORTED", "Live Activities require iOS 16.1 or higher", nil)
            return
        }
        
        guard let activity = LiveActivities.activeActivities[activityId] as? Activity<ActivityAttributes> else {
            reject("E_NOT_FOUND", "Activity not found", nil)
            return
        }
        
        Task {
            for await pushToken in activity.pushTokenUpdates {
                let tokenString = pushToken.map { String(format: "%02x", $0) }.joined()
                resolve(tokenString)
                return
            }
            resolve(nil)
        }
    }
    
    // MARK: - Helper Methods (These would be implemented for each activity type)
    
    @available(iOS 16.1, *)
    private func startRideTrackingActivity(
        attributes: NSDictionary,
        contentState: NSDictionary,
        staleDate: NSNumber?,
        relevanceScore: NSNumber?
    ) throws -> Any {
        // Implementation will be in the Widget Extension
        // This is a placeholder that returns activity
        throw NSError(domain: "LiveActivities", code: -1, userInfo: [NSLocalizedDescriptionKey: "Implement specific activity types in Widget Extension"])
    }
    
    @available(iOS 16.1, *)
    private func startDeliveryTrackingActivity(
        attributes: NSDictionary,
        contentState: NSDictionary,
        staleDate: NSNumber?,
        relevanceScore: NSNumber?
    ) throws -> Any {
        throw NSError(domain: "LiveActivities", code: -1, userInfo: [NSLocalizedDescriptionKey: "Implement specific activity types in Widget Extension"])
    }
    
    @available(iOS 16.1, *)
    private func startSportsScoreActivity(
        attributes: NSDictionary,
        contentState: NSDictionary,
        staleDate: NSNumber?,
        relevanceScore: NSNumber?
    ) throws -> Any {
        throw NSError(domain: "LiveActivities", code: -1, userInfo: [NSLocalizedDescriptionKey: "Implement specific activity types in Widget Extension"])
    }
    
    @available(iOS 16.1, *)
    private func startTimerActivity(
        attributes: NSDictionary,
        contentState: NSDictionary,
        staleDate: NSNumber?,
        relevanceScore: NSNumber?
    ) throws -> Any {
        throw NSError(domain: "LiveActivities", code: -1, userInfo: [NSLocalizedDescriptionKey: "Implement specific activity types in Widget Extension"])
    }
    
    @available(iOS 16.1, *)
    private func updateActivityContent(
        activity: Any,
        contentState: NSDictionary,
        alertConfig: NSDictionary?,
        staleDate: NSNumber?
    ) throws {
        // Implementation for updating activities
    }
    
    @available(iOS 16.1, *)
    private func endActivityContent(
        activity: Any,
        finalContent: NSDictionary?,
        dismissalPolicy: String
    ) async throws {
        // Implementation for ending activities
    }
}
