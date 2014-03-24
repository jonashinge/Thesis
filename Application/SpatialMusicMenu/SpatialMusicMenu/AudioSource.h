//
//  AudioSource.h
//  AudioGrid 3D
//
//  Created by Martin Lobger on 13/02/14.
//  Copyright (c) 2014 GN Store Nord A/S. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IHS/IHS.h>


// Implements the IHSAudio3DGridModelSource protocol that is
// used together with the IHSAudio3DGridModel.
@interface AudioSource : NSObject <IHSAudio3DGridModelSource>

@property (nonatomic, strong) NSString* imageName;

- (instancetype)initWithSound:(NSString*)soundName andImage:(NSString*)imageName;

@end
