//
//  OrderDetailViewController.h
//  Decorator
//
//  Created by Hoang Le on 11/25/13.
//  Copyright (c) 2013 Hoang Le. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderDetailViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
- (id)initWithDetailList:(NSArray *)_detailList;
- (id)initWithDetailList:(NSArray *)_detailList andPlans:(NSArray *)_plans;
- (IBAction)backToOrder:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *orderTableView;
- (IBAction)showEmailComposer:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *background;
- (IBAction)backtoTop:(id)sender;
@end
