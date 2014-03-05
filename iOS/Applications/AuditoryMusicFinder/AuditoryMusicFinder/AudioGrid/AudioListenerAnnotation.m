//
//  AudioListenerAnnotation.m
//  AudioGrid 3D
//
//  Created by Martin Lobger on 14/02/14.
//  Copyright (c) 2014 GN Store Nord A/S. All rights reserved.
//

#import "AudioListenerAnnotation.h"

@implementation AudioListenerAnnotation
{
    UIImageView*    _imageView;
}

- (id)init
{
    return [self initWithFrame:CGRectMake(0, 0, 64, 64)];
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Load image to show as listener
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.image = [UIImage animatedImageNamed:@"Listener-" duration:1.0];
        [_imageView startAnimating];
        [self addSubview:_imageView];
    }
    return self;
}


- (void)setHeading:(float)heading
{
    super.heading = heading;
    CGFloat radianAngle = (heading * M_PI) / 180.; // Turn degrees into radians
    _imageView.transform = CGAffineTransformMakeRotation(radianAngle);
}

@end
