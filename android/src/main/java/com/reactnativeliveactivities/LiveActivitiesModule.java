package com.reactnativeliveactivities;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableNativeArray;

public class LiveActivitiesModule extends ReactContextBaseJavaModule {
  public static final String NAME = "LiveActivities";

  public LiveActivitiesModule(ReactApplicationContext reactContext) {
    super(reactContext);
  }

  @Override
  @NonNull
  public String getName() {
    return NAME;
  }

  @ReactMethod
  public void areActivitiesEnabled(Promise promise) {
    // On Android, we say yes, but it's a stub.
    promise.resolve(true); 
  }

  @ReactMethod
  public void startActivity(String activityType, ReadableMap attributes, ReadableMap contentState, Double staleDate, Double relevanceScore, Promise promise) {
    // Return a dummy ID
    promise.resolve("android-activity-" + System.currentTimeMillis());
  }

  @ReactMethod
  public void updateActivity(String activityId, ReadableMap contentState, @Nullable ReadableMap alertConfig, @Nullable Double staleDate, Promise promise) {
    promise.resolve(null);
  }

  @ReactMethod
  public void endActivity(String activityId, @Nullable ReadableMap finalContent, String dismissalPolicy, Promise promise) {
    promise.resolve(null);
  }
  
  @ReactMethod
  public void getActiveActivities(Promise promise) {
     WritableArray array = new WritableNativeArray();
     promise.resolve(array);
  }

  @ReactMethod
  public void endAllActivities(Promise promise) {
      promise.resolve(null);
  }

  @ReactMethod
  public void getPushToken(String activityId, Promise promise) {
      promise.resolve(null);
  }
}
