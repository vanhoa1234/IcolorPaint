//
//  NYPopover.m
//  NYReader
//
//  Created by Cassius Pacheco on 21/12/12.
//  Copyright (c) 2012 Nyvra Software. All rights reserved.
//

#import "NYPopover.h"

@implementation NYPopover

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        //Default values, can be changed after
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.imageView.image = [[UIImage imageNamed:@"popupBackground"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
        [self addSubview:self.imageView];
        
//        self.textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
//        self.textLabel.backgroundColor = [UIColor clearColor];
//        self.textLabel.textColor = [UIColor blackColor];
//        self.textLabel.font = [UIFont boldSystemFontOfSize:20];
//        self.textLabel.textAlignment = UITextAlignmentCenter;
//        self.textLabel.adjustsFontSizeToFitWidth = YES;
//        
//        [self addSubview:self.textLabel];
        
        self.circle = [[CAShapeLayer alloc] initWithLayer:self.layer];
        [self.layer addSublayer:self.circle];
        CGRect box = CGRectMake(65, 68, 10, 10);
        UIBezierPath *ballBezierPath = [UIBezierPath bezierPathWithOvalInRect:box];
        self.circle.path = ballBezierPath.CGPath;
        self.circle.fillColor = [UIColor colorWithRed:242./255. green:131./255. blue:106./255. alpha:1].CGColor;
    }
    
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    self.imageView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    
    CGFloat y = (frame.size.height - 26) / 3;
    
    if (frame.size.height < 38)
        y = 0;
    
    
//    self.circle.frame = CGRectMake(0, 0, 10, 10);
//    self.textLabel.frame = CGRectMake(5, 102, frame.size.width, 30);
}

@end
