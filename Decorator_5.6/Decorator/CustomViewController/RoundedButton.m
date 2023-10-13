//
//  RoundedButton.m
//  Decorator
//
//  Created by Le Hoang on 4/6/16.
//  Copyright © 2016 Hoang Le. All rights reserved.
//

#import "RoundedButton.h"

@implementation RoundedButton

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    self.layer.cornerRadius = 5.0f;
    self.layer.masksToBounds = YES;
}

@end
