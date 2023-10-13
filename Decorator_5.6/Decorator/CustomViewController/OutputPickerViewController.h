//
//  OutputPickerViewController.h
//  Decorator
//
//  Created by Hoang Le on 12/2/13.
//  Copyright (c) 2013 Hoang Le. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    OUTPUT_MAIL = 0,
    OUTPUT_PRINTER = 1,
    OUTPUT_TWITTER = 2,
    OUTPUT_FACEBOOK = 3
}OutputType;

@protocol OutputPickerViewControllerDelegate <NSObject>
@optional
- (void)outputAction:(OutputType)type withFormat:(int)format;
- (void)gotoColorMode;
@end

@interface OutputPickerViewController : UIViewController
@property (nonatomic, assign) id<OutputPickerViewControllerDelegate> delegate;
- (IBAction)emailAction:(id)sender;
- (IBAction)printAction:(id)sender;
- (IBAction)twitterAction:(id)sender;
- (IBAction)facebookAction:(id)sender;
- (IBAction)selectedOutputType:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btTwitter;
@property (weak, nonatomic) IBOutlet UIButton *btFacebook;
@property (weak, nonatomic) IBOutlet UILabel *lbTwitter;
@property (weak, nonatomic) IBOutlet UILabel *lbFacebook;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segFormat;
@end
