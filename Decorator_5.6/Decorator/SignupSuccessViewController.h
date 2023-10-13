//
//  SignupSuccessViewController.h
//  Decorator
//
//  Created by Le Hoang on 6/6/16.
//  Copyright © 2016 Hoang Le. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignupSuccessViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *background;
- (IBAction)backtoMenu:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *bt_back;

@end
