//
//  SMMDeviceManager.h
//  SpatialMusicMenu
//
//  Created by Jonas Hinge on 14/03/2014.
//  Copyright (c) 2014 Jonas Hinge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSString+IHSDeviceConnectionState.h"

@class SMMDeviceManager;

@protocol SMMDeviceManagerConnectionDelegate <NSObject>

@required
- (void)smmDeviceManagerFoundAmbiguousDevices:(SMMDeviceManager *)manager;

@optional
- (void)smmDeviceManager:(SMMDeviceManager *)manager connectedStateChanged:(IHSDeviceConnectionState)connectionState;

@end


@protocol SMMDeviceManagerDelegate <NSObject>

@optional
- (void)smmDeviceManager:(SMMDeviceManager *)manager fusedHeadingChanged:(float)heading;
@optional
- (void)smmDeviceManager:(SMMDeviceManager *)manager gyroHeadingChanged:(float)heading;
@optional
- (void)smmDeviceManager:(SMMDeviceManager *)manager gestureRecognized:(NSDictionary *)result;

@end


@interface SMMDeviceManager : NSObject

@property (nonatomic, weak) id<SMMDeviceManagerConnectionDelegate> connectionDelegate;
@property (nonatomic, weak) id<SMMDeviceManagerDelegate> delegate;
@property (readonly) BOOL isRecordingGesture;
@property (nonatomic) float playerHeading;

- (void)showDeviceSelection:(UIViewController *)parentViewController;

- (void)connectToDevice;
- (void)playAudio;
- (void)stopAudio;
- (void)addSound:(IHSAudio3DSound *)sound;
- (void)removeSound:(IHSAudio3DSound *)sound;
- (void)startRecordingGesture;
- (NSArray *)stopRecordingGesture;
- (void)updateGestures:(NSArray *)gestures;

@end
