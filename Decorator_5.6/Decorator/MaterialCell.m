//
//  MaterialCell.m
//  Decorator
//
//  Created by Hoang Le on 11/27/13.
//  Copyright (c) 2013 Hoang Le. All rights reserved.
//

#import "MaterialCell.h"

@implementation MaterialCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
