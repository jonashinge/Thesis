//
//  NSString+IHSDeviceConnectionState.m
//  AuditoryMusicFinder
//
//  Created by Jonas Hinge on 03/03/2014.
//  Copyright (c) 2014 Jonas Hinge. All rights reserved.
//

#import "NSString+IHSDeviceConnectionState.h"

@implementation NSString (IHSDeviceConnectionState)

+ (NSString*) stringFromIHSDeviceConnectionState:(IHSDeviceConnectionState)connectionState
{
    switch (connectionState)
    {
        case IHSDeviceConnectionStateNone:              return @"(none)";
        case IHSDeviceConnectionStateBluetoothOff:      return @"N/A";
        case IHSDeviceConnectionStateDiscovering:       return @"Discovering";
        case IHSDeviceConnectionStateConnecting:        return @"Connecting";
        case IHSDeviceConnectionStateConnected:         return @"Connected";
        case IHSDeviceConnectionStateConnectionFailed:  return @"Failed connecting";
        case IHSDeviceConnectionStateLingering:         return @"Lingering";
        case IHSDeviceConnectionStateDisconnected:      return @"Disconnected";
            
            // omit default: so we get compiler warning/error if IHSDeviceConnectionState should change.
    }
    
    return @"(unknown)";
}

@end
