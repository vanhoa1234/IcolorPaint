//
//  ResetAccountViewController.h
//  Decorator
//
//  Created by Le Hoang on 2/24/16.
//  Copyright © 2016 Hoang Le. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResetAccountViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *background;
@property (weak, nonatomic) IBOutlet UIButton *bt_sent;
- (IBAction)backtoMenu:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lb_error;
@property (weak, nonatomic) IBOutlet UITextField *txt_email;
- (IBAction)action_sentEmail:(id)sender;
@end
