//
//  MaterialCell.h
//  Decorator
//
//  Created by Hoang Le on 11/27/13.
//  Copyright (c) 2013 Hoang Le. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MaterialCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *img_feature;
@property (weak, nonatomic) IBOutlet UILabel *fname;
@property (weak, nonatomic) IBOutlet UILabel *fdescription;
@property (weak, nonatomic) IBOutlet UILabel *fgloss;
@property (weak, nonatomic) IBOutlet UILabel *fpattern;
@property (weak, nonatomic) IBOutlet UIButton *bt_setting;
@property (weak, nonatomic) IBOutlet UIView *view_feature;

@end
