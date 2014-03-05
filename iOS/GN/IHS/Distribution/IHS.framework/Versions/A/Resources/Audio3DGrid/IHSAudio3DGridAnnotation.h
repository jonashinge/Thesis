///
///  @file IHSAudio3DGridAnnotation.h
///  IHS API
///
///  Created by Martin Lobger on 10/02/14.
///  Copyright (c) 2014 GN Store Nord A/S. All rights reserved.
///

#import <UIKit/UIKit.h>
#import <IHS/IHS.h>


@class IHSAudio3DGridModel;
@protocol IHSAudio3DGridModelSource;


#pragma mark - IHSAudio3DGridAnnotation

/**
 @brief                 Basic audio grid view annotation
 @details               This class should never be inherited. It is inherited by IHSAudio3DGridListenerAnnotation and IHSAudio3DGridSoundAnnotation in this framework.
 */
@interface IHSAudio3DGridAnnotation : UIView

@end


#pragma mark - IHSAudio3DGridListenerAnnotation

/**
 @brief                 Annotation class representing the listener
 @details               This class should be inherited as it does not draw anything by itself.
 */
@interface IHSAudio3DGridListenerAnnotation : IHSAudio3DGridAnnotation

/**
 @brief                 Position of listener in 2D coordinate system
 @details               This value corresponds to the listenerPosition property of the IHSAudio3DGridModel being presented.
                        Changing this property will update the model.
                        And changing the listenerPosition on the model while this annotation is added to the IHSAudio3DGridView will update this property.
 */
@property (nonatomic, assign) CGPoint position;

/**
 @brief                 Heading of the listener in degrees
 @details               This value corresponds to the listenerHeading property of the IHSAudio3DGridModel being presented.
                        Changing this property will update the model.
                        And changing the listenerHeading on the model while this annotation is added to the IHSAudio3DGridView will update this property.
 */
@property (nonatomic, assign) float heading;

@end


#pragma mark - IHSAudio3DGridSoundAnnotation

/**
 @brief                 Annotation class representing a sound
 @details               This class should be inherited as it does not draw anything by itself.
 */
@interface IHSAudio3DGridSoundAnnotation : IHSAudio3DGridAnnotation

/**
 @brief                 The audio source being represented
 @details               This property must not be nil.
                        It is discouraged to change this property after the instance has been added to the IHSAudio3DGridView.
 */
@property (nonatomic, strong) id<IHSAudio3DGridModelSource> audioSource;

/**
 @brief                 Initializes the instance with the audioSource
 @details               It is encouraged to call this initializer. Internally it will call initWithFrame: with a CGRectZero frame.
 @return                The initialized instance or nil.
 */
- (instancetype)initWithAudioSource:(id<IHSAudio3DGridModelSource>)audioSource;

@end


