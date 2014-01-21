//
//  MixerCoreAudioController.h
//  HeadsetExplorer
//
//  Created by Jonas Hinge on 20/01/2014.
//  Copyright (c) 2014 GN Store Nord A/S. All rights reserved.
//

#import "CocoaLibSpotify.h"

@interface MixerCoreAudioController : SPCoreAudioController

- (void)applyPanningToMixer:(float) panVal;

@end
