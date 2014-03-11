//
//  NSString+IHSDeviceConnectionState.h
//  AuditoryMusicFinder
//
//  Created by Jonas Hinge on 03/03/2014.
//  Copyright (c) 2014 Jonas Hinge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IHS/IHS.h>

@interface NSString (IHSDeviceConnectionState)

+ (NSString*) stringFromIHSDeviceConnectionState:(IHSDeviceConnectionState)connectionState;

@end
