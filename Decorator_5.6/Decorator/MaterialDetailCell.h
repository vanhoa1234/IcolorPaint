//
//  MaterialDetailCell.h
//  Decorator
//
//  Created by Hoang Le on 11/25/13.
//  Copyright (c) 2013 Hoang Le. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MaterialDetailCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *img_type;
@property (weak, nonatomic) IBOutlet UILabel *lb_type;
@property (weak, nonatomic) IBOutlet UIView *view_feature;
@property (weak, nonatomic) IBOutlet UIImageView *img_feature;
@property (weak, nonatomic) IBOutlet UILabel *fname;
@property (weak, nonatomic) IBOutlet UILabel *fdescription;
@property (weak, nonatomic) IBOutlet UILabel *fgloss;
@property (weak, nonatomic) IBOutlet UILabel *fpattern;
@property (weak, nonatomic) IBOutlet UIButton *bt_setting;
@property (weak, nonatomic) IBOutlet UIButton *bt_info;
@property (weak, nonatomic) IBOutlet UIButton *bt_catalog;

@end
