//
//  CheckmarkTableViewCell.m
//  SpatialMusicMenu
//
//  Created by Jonas Hinge on 25/03/2014.
//  Copyright (c) 2014 Jonas Hinge. All rights reserved.
//

#import "CheckmarkTableViewCell.h"

@implementation CheckmarkTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _lblHeading = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 500, 60)];
        [self addSubview:_lblHeading];
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
