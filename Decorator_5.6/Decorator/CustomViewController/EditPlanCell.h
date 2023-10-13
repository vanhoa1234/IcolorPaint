//
//  EditPlanCell.h
//  Decorator
//
//  Created by Hoang Le on 11/21/13.
//  Copyright (c) 2013 Hoang Le. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditPlanCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lb_no;
@property (weak, nonatomic) IBOutlet UILabel *lb_name;
@property (weak, nonatomic) IBOutlet UILabel *lb_date;
@property (weak, nonatomic) IBOutlet UIButton *bt_homeIcon;
@property (weak, nonatomic) IBOutlet UIButton *bt_edit;
@property (weak, nonatomic) IBOutlet UIView *view_feature;
@property (weak, nonatomic) IBOutlet UIButton *bt_layout;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *imgIndicator;
@property (weak, nonatomic) IBOutlet UIButton *bt_map;
@property (weak, nonatomic) IBOutlet UIButton *bt_editName;
@property (weak, nonatomic) IBOutlet UITextField *txt_planName;
@property (weak, nonatomic) IBOutlet UIImageView *img_home;

@end
