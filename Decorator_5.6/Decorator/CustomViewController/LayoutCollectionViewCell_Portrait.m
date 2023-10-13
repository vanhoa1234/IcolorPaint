//
//  LayoutCollectionViewCell_Portrait.m
//  Decorator
//
//  Created by Le Hoang on 6/24/16.
//  Copyright © 2016 Hoang Le. All rights reserved.
//

#import "LayoutCollectionViewCell_Portrait.h"

@implementation LayoutCollectionViewCell_Portrait

- (void)awakeFromNib {
    [super awakeFromNib];
    self.lb_original.strokeColor = [UIColor blackColor];
    self.lb_original.strokeSize = 2.0f;
}

@end
