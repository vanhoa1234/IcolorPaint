//
//  LayerCell.m
//  Decorator
//
//  Created by Hoang Le on 9/16/13.
//  Copyright (c) 2013 Hoang Le. All rights reserved.
//

#import "LayerCell.h"

@implementation LayerCell

//- (void)drawRect:(CGRect)rect{
//    [super drawRect:rect];
//    NSAttributedString *attributedText =
//    [[NSAttributedString alloc] initWithString:@"sdadad"
//                                    attributes:@{NSStrokeWidthAttributeName: [NSNumber numberWithInt:-6],
//                                                 NSStrokeColorAttributeName: [UIColor blackColor],
//                                                 NSForegroundColorAttributeName: [UIColor whiteColor]}];
//    [self.layerButton setAttributedTitle:attributedText forState:UIControlStateNormal];
//    [self.colorButton setAttributedTitle:attributedText forState:UIControlStateNormal];
//}

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
- (void)prepareForMove{
    [[self layerImage] setImage:nil];
    [[self layerButton] setTitle:@"" forState:UIControlStateNormal];
    [[self colorButton] setTitle:@"" forState:UIControlStateNormal];
    self.lbName.text = @"";
    self.lblColor.text = @"";
}
@end
