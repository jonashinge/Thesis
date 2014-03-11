///
///  @file IHSAudio3DGridModel.h
///  IHS API
///
///  Created by Per Sandholm on 02/12/13.
///  Copyright (c) 2013 GN Store Nord A/S. All rights reserved.
///

#import <Foundation/Foundation.h>
#import <IHS/IHS.h>


@class IHSAudio3DSound;
@protocol IHSAudio3DGridModelDelegate;


#pragma mark - IHSAudio3DGridModelSource

/**
 @brief                 Representation of an audio source.
 @details               The heading and distance properties of the sound,
                        will be updated by the IHSAudio3DGridModel according
                        to what the position property holds.
                        In other words, changing the position property of an
                        IHSAudio3DGridModelSource that is part of a IHSAudio3DGridModel
                        will update the sound.heading and sound.distance parameters.
                        On the other hand, updating sound.distance or sound.heading will
                        have an immediate effect on audio output, but will not update the
                        position property. Furthermore, they will be 'reset' when the
                        IHSAudio3DGridModel recalculates the entire model.
 */
@protocol IHSAudio3DGridModelSource <NSObject>

@required

/**
 @brief                 The IHSAudio3DSound that will be played back by the IHSDevice.
 */
@property (nonatomic, readonly) IHSAudio3DSound* sound;

/**
 @brief                 Position of audio source in a 2D coordinate system
 */
@property (nonatomic, assign) CGPoint position;

@end


#pragma mark - IHSAudio3DGridModel

/**
 @brief                 An Audio Grid to keep track of audio sources and the listener.
 @details               The Audio Grid will manipulate the sources according to the listener position and heading.
                        Also if an audio source is moved, the model will update accordingly.
 @note                  The IHSAudio3DGridModel does not know about the IHSDevice.
                        It is up to you to add and remove sound to and from the IHSDevice.
                        You will be notified through the IHSAudio3DGridModelDelegate messages.
 */
@interface IHSAudio3DGridModel : NSObject

/**
 @brief                 Object to receive messages from the audio grid model
 @note                  Remember to listen for audioModel:didAddSource: and audioModel:willRemoveSource:
                        as the IHSAudio3DGridModel will not add or remove sounds to and from the IHSDevice.
 */
@property (nonatomic, weak) id<IHSAudio3DGridModelDelegate> delegate;

/**
 @brief                 Position of listener in a 2D coordinate system
 */
@property (nonatomic, assign) CGPoint listenerPosition;

/**
 @brief                 Heading of the listener in degrees in a 2D coordinate system
 */
@property (nonatomic, assign) CGFloat listenerHeading;

/**
 @brief                 Audio sources in model.
 @details               The sources are managed through addSource: and removeSource:
 */
@property (nonatomic, readonly, copy) NSArray* sources;

/**
 @brief                 Centeroid of audio sources
 @details               This is a calculated property.
                        It will go through all sources and calculate the centeroid.
 */
@property (nonatomic, readonly) CGPoint centeroid;

/**
 @brief                 Bounds of audio source coordinate system
 @details               This is a calculated property.
                        It will go through all sources and calculate the bounding rectangle.
 */
@property (nonatomic, readonly) CGRect bounds;

/**
 @brief                 Returns an empty audio source model
 @return                The instance pointer or nil if an error occurred.
 */
- (id)init;

/**
 @brief                 Adds the source to the audio grid model sources
                        The source will be positioned at source.position
 */
- (void)addSource:(id<IHSAudio3DGridModelSource>)source;

/**
 @brief                 Removes the source from the audio grid model sources
 */
- (void)removeSource:(id<IHSAudio3DGridModelSource>)source;

/**
 @brief                 Removes all sources from audio grid model sources
 */
- (void)removeAllSources;

/**
 @brief                 Transpose coordinates for sources and listener
 */
- (void)transpose:(CGAffineTransform)transformation;

@end


#pragma mark - IHSAudio3DGridModelDelegate

/**
 @brief                 The IHSAudio3DGridModelDelegate protocol declares methods that are implemented by the delegate of the IHSAudio3DGridModel object.
 @details               These methods provide you with information about key events in an audio grid model's execution such as when sources are added or removed.
                        Implementing these methods gives you a chance to respond to these audio grid model events and respond accordingly.
 @note                  You should add and remove audio sources respectively in your IHSDevice when receiving the respective messages.
 */
@protocol IHSAudio3DGridModelDelegate <NSObject>

@optional

/**
 @brief                 Message will be sent after the source has been added to model and the model has been updated
 @param audioModel      The audio grid model that sent the message.
 @param source          The source that was added.
 */
- (void)audioModel:(IHSAudio3DGridModel*)audioModel didAddSource:(id<IHSAudio3DGridModelSource>)source;

/**
 @brief                 Message will be sent right before the source is removed from the model
 @param audioModel      The audio grid model that sent the message.
 @param source          The source that was removed.
 */
- (void)audioModel:(IHSAudio3DGridModel*)audioModel willRemoveSource:(id<IHSAudio3DGridModelSource>)source;

/**
 @brief                 Message will be sent when source is repositioned in the model
 @param audioModel      The audio grid model that sent the message.
 @param source          The source that was repositioned.
 */
- (void)audioModel:(IHSAudio3DGridModel*)audioModel didMoveSource:(id<IHSAudio3DGridModelSource>)source;

/**
 @brief                 Message will be sent when the listener is repositioned.
 @param audioModel      The audio grid model that sent the message.
 @param position        The new position of the listener.
 */
- (void)audioModel:(IHSAudio3DGridModel*)audioModel didUpdateListenerPosition:(CGPoint)position;

/**
 @brief                 Message will be sent when the listener heading is updated
 @param audioModel      The audio grid model that sent the message.
 @param heading         The new listener heading - in degrees
 */
- (void)audioModel:(IHSAudio3DGridModel*)audioModel didUpdateListenerHeading:(CGFloat)heading;

@end
