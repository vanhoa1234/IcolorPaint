//
//  EditOrderViewController.h
//  Decorator
//
//  Created by Hoang Le on 11/26/13.
//  Copyright (c) 2013 Hoang Le. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Material.h"
@protocol EditOrderViewControllerDelegate <NSObject>
@optional
- (void)savedEditOder:(Material *)_savedMaterial;
@end

@interface EditOrderViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, assign) id<EditOrderViewControllerDelegate> delegate;
- (IBAction)backToOrderDetail:(id)sender;
- (IBAction)saveOrderDetail:(id)sender;
- (id)initWithMaterial:(Material *)_material;
@property (weak, nonatomic) IBOutlet UITableView *featureTableView;
@property (weak, nonatomic) IBOutlet UIImageView *img_type;
@property (weak, nonatomic) IBOutlet UILabel *lb_type;
@property (weak, nonatomic) IBOutlet UIImageView *background;
@end
