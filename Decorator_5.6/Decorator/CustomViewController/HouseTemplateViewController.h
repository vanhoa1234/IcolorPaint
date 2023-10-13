//
//  HouseTemplateViewController.h
//  Decorator
//
//  Created by Le Hoang on 2/22/16.
//  Copyright © 2016 Hoang Le. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LayerObject.h"
#import "HouseTemplate.h"

@protocol HouseTemplateViewControllerDelegate <NSObject>
@optional
- (void)dismissHouseTemplateViewController;
- (void)selectedHouseTemplate:(HouseTemplate *)_template;
@end

@interface HouseTemplateViewController : UIViewController
@property (nonatomic, assign) id<HouseTemplateViewControllerDelegate> delegate;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withFrame:(CGRect)_frame andLayer:(LayerObject *)_layer;
- (id)initWithFrame:(CGRect)_frame andLayer:(LayerObject *)_layer;
- (IBAction)dismissView:(id)sender;
- (IBAction)selectedTemplate:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *bt_cancel;
@end
