//
//  OrderViewController.h
//  Decorator
//
//  Created by Hoang Le on 11/25/13.
//  Copyright (c) 2013 Hoang Le. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MDSpreadView.h"

@interface OrderViewController : UIViewController<MDSpreadViewDelegate,MDSpreadViewDataSource>
- (id)initWithHouseID:(int)_houseID andName:(NSString *)_houseName;
@property (weak, nonatomic) IBOutlet UIButton *bt1;
@property (weak, nonatomic) IBOutlet UIButton *bt2;
- (id)initWithHouseID:(int)_houseID andName:(NSString *)_houseName isFromLayout:(BOOL)_isfromLayout;
- (IBAction)backToEditPlan:(id)sender;
@property (weak, nonatomic) IBOutlet MDSpreadView *spreadView;
@property (weak, nonatomic) IBOutlet UILabel *lb_title;
- (IBAction)gotoOrderDetail:(id)sender;
- (IBAction)showMailComposer:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *background;
@property (weak, nonatomic) IBOutlet UIImageView *maskTableView;
@end
