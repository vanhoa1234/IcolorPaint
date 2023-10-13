//
//  LayoutCollectionViewCell_6Cell.m
//  Decorator
//
//  Created by Le Hoang on 3/1/16.
//  Copyright © 2016 Hoang Le. All rights reserved.
//

#import "LayoutCollectionViewCell_6Cell.h"

@implementation LayoutCollectionViewCell_6Cell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.lb_original.strokeColor = [UIColor blackColor];
    self.lb_original.strokeSize = 2.0f;
}

@end
