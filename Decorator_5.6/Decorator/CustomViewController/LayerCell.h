//
//  LayerCell.h
//  Decorator
//
//  Created by Hoang Le on 9/16/13.
//  Copyright (c) 2013 Hoang Le. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "THLabel.h"

@interface LayerCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *layerImage;
@property (weak, nonatomic) IBOutlet UIButton *layerButton;
@property (weak, nonatomic) IBOutlet UIButton *colorButton;
@property (weak, nonatomic) IBOutlet THLabel *lbName;
@property (weak, nonatomic) IBOutlet THLabel *lblColor;
- (void)prepareForMove;
@property (weak, nonatomic) IBOutlet UIView *higlightView;
@end
