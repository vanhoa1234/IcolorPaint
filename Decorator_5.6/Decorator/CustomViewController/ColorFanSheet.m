//
//  ColorFanSheet.m
//  Decorator
//
//  Created by Hoang Le on 9/20/13.
//  Copyright (c) 2013 Hoang Le. All rights reserved.
//

#import "ColorFanSheet.h"

@implementation ColorFanSheet
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"ColorFanSheet" owner:self options:nil];
        [self addSubview:self.view];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (IBAction)selectedColor:(id)sender {
    [delegate selectedColorButton:sender];
}
@end
