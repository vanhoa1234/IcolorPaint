//
//  RoundedButton10px.m
//  Decorator
//
//  Created by Le Hoang on 4/8/16.
//  Copyright © 2016 Hoang Le. All rights reserved.
//

#import "RoundedButton10px.h"

@implementation RoundedButton10px
- (void)drawRect:(CGRect)rect {
    // Drawing code
    self.layer.cornerRadius = 12.0f;
    self.layer.borderWidth = 2.0f;
    self.layer.borderColor = [UIColor whiteColor].CGColor;
    self.layer.masksToBounds = YES;
}
@end
