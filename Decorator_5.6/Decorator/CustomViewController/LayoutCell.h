//
//  LayoutCell.h
//  Decorator
//
//  Created by Hoang Le on 11/29/13.
//  Copyright (c) 2013 Hoang Le. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "THLabel.h"
@interface LayoutCell : UITableViewCell
@property (weak, nonatomic) IBOutlet THLabel *lb_name;
@property (weak, nonatomic) IBOutlet THLabel *lb_color;

@end
