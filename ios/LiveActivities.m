#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(LiveActivities, NSObject)

RCT_EXTERN_METHOD(areActivitiesEnabled:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(startActivity:(NSString *)activityType
                  attributes:(NSDictionary *)attributes
                  contentState:(NSDictionary *)contentState
                  staleDate:(NSNumber * _Nullable)staleDate
                  relevanceScore:(NSNumber * _Nullable)relevanceScore
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(updateActivity:(NSString *)activityId
                  contentState:(NSDictionary *)contentState
                  alertConfig:(NSDictionary * _Nullable)alertConfig
                  staleDate:(NSNumber * _Nullable)staleDate
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(endActivity:(NSString *)activityId
                  finalContent:(NSDictionary * _Nullable)finalContent
                  dismissalPolicy:(NSString *)dismissalPolicy
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(getActiveActivities:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(endAllActivities:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(getPushToken:(NSString *)activityId
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

+ (BOOL)requiresMainQueueSetup
{
  return NO;
}

@end
