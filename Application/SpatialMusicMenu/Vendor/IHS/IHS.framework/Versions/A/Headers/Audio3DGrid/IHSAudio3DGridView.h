///
///  IHSAudio3DGridView.h
///  IHS API
///
///  Created by Martin Lobger on 22/01/14.
///  Copyright (c) 2014 GN Store Nord A/S. All rights reserved.
///

#import <UIKit/UIKit.h>
#import <IHS/IHS.h>

@class IHSAudio3DSound;
@class IHSAudio3DGridModel, IHSAudio3DGridAnnotation, IHSAudio3DGridListenerAnnotation, IHSAudio3DGridSoundAnnotation;
@protocol IHSAudio3DGridModelSource;

@protocol IHSAudio3DGridViewDelegate;


#pragma mark - IHSAudio3DGridView

/**
 @brief                 The IHSAudio3DGridView is used to visually represent and manipulate an IHSAudio3DGridModel
 */
@interface IHSAudio3DGridView : UIView

/**
 @brief                 Object to receive messages from the audio grid view
 */
@property (nonatomic, weak) id <IHSAudio3DGridViewDelegate> delegate;

/**
 @brief                 The audio grid model to represent
 @details               All annotations from the previous audio grid model will be removed before the new model is added.
                        All sources of the audio grid model will be tried added as annotations.
 */
@property (nonatomic, strong) IHSAudio3DGridModel* audioModel;

/**
 @brief                 The annotation used to represent the listener.
 @details               If nil, then no listener annotation will be displayed.
 */
@property (nonatomic, strong) IHSAudio3DGridListenerAnnotation* listenerAnnotation;

/**
 @brief                 The currently added sound annotations.
 @details               This array will not include the listenerAnnotation or other views manually added to the IHSAudio3DGridView.
 */
@property (nonatomic, readonly, copy) NSArray* soundAnnotations;

/**
 @brief                 The virtual size in millimeters of the IHSAudio3DGridView
 @details               This virtually represents the physical size of the grid.
                        If the size of gridBounds is e.g. (10000,10000) the distance from
                        left to right will be 10 meters. This affects the movements of the listener
                        and how sound sources are heard at a distance.
 */
@property (nonatomic, assign) CGRect gridBounds;

/**
 @brief                 Add a sound annotation to the IHSAudio3DGridView
 @details               Only a sound annotation with an audioSource that is part of the current audioModel will be accepted.
                        Adding an annotation that is already added, will remove it before adding it again.
 @param annotation      The annotation to add to the audio grid model.
 @return                YES if the annotaiton was added or already was part of this audio grid view, else NO.
 */
- (BOOL)addAnnotation:(IHSAudio3DGridSoundAnnotation*)annotation;

/**
 @brief                 Removes the annotation form the IHSAudio3DGridView
 @details               Removing an annotation that is not present, will have no effect.
 @param annotation      The annotation to remove from the audio grid model.
 */
- (void)removeAnnotation:(IHSAudio3DGridSoundAnnotation*)annotation;

/**
 @brief                 Transform 2D virtual coordinates to screen coordinates
 */
- (CGPoint)viewPositionFromModelPosition:(CGPoint)position;

/**
 @brief                 Transform screen coordinates to 2D virtual coordinates
 */
- (CGPoint)modelPositionFromViewPosition:(CGPoint)position;

@end


#pragma mark - IHSAudio3DGridViewDelegate

/**
 @brief                 The IHSAudio3DGridViewDelegate protocol declares methods that are implemented by the delegate of the IHSAudio3DGridView object.
 */
@protocol IHSAudio3DGridViewDelegate <NSObject>

@required
/**
 @brief                 Message will be sent when the IHSAudio3DGridView needs an annotation to represent an IHSAudio3DGridModelSource
 @param audioGridView   The audio grid view that sent this message.
 @param audioSource     The audio source for which a sound annotation is requested.
 @return                The implementation of this message should return a IHSAudio3DGridSoundAnnotation derived instance.
                        If returning nil, no annotation will be added. It can be added later through the addAnnotation: message of the IHSAudio3DGridView class.
 */
- (IHSAudio3DGridSoundAnnotation*)audioGridView:(IHSAudio3DGridView*)audioGridView audioAnnotationForAudioSource:(id<IHSAudio3DGridModelSource>)audioSource;

@optional
/**
 @brief                 Message will be sent after the IHSAudio3DGridView has moved an annotation
 @param audioGridView   The audio grid view that sent this message.
 @param annotation      The annotation that was moved.
 */
- (void)audioGridView:(IHSAudio3DGridView*)audioGridView didMoveAnnotation:(IHSAudio3DGridAnnotation*)annotation;

@end
