//
//  BackgroundPickerViewController.h
//  Decorator
//
//  Created by Hoang Le on 12/2/13.
//  Copyright (c) 2013 Hoang Le. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BackgroundPickerViewControllerDelegate <NSObject>
@optional
- (void)selectedBackgroundImage:(NSString *)_imageName;
- (void)dismissBackgroundPicker;
- (void)selectedBackgroundColor:(UIColor *)_color;
@end

@interface BackgroundPickerViewController : UIViewController
- (IBAction)dismissMe:(id)sender;

- (id)initWithOrientation:(UIInterfaceOrientation)_orientation;
@property (nonatomic, assign) id<BackgroundPickerViewControllerDelegate> delegate;
@end
