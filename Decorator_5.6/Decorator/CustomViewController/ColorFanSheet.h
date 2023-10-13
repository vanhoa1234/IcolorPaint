//
//  ColorFanSheet.h
//  Decorator
//
//  Created by Hoang Le on 9/20/13.
//  Copyright (c) 2013 Hoang Le. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ColorFanSheetDelegate <NSObject>

- (void)selectedColorButton:(id)sender;

@end

@interface ColorFanSheet : UIView
@property (nonatomic, assign) id<ColorFanSheetDelegate> delegate;
@property (strong, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic) IBOutlet UILabel *lb1;
@property (weak, nonatomic) IBOutlet UILabel *lb2;
@property (weak, nonatomic) IBOutlet UILabel *lb3;
@property (weak, nonatomic) IBOutlet UILabel *lb4;
@property (weak, nonatomic) IBOutlet UILabel *lb5;
@property (weak, nonatomic) IBOutlet UILabel *lb6;
@property (weak, nonatomic) IBOutlet UILabel *lb7;
@property (weak, nonatomic) IBOutlet UILabel *lb8;
@property (weak, nonatomic) IBOutlet UIButton *color1;
@property (weak, nonatomic) IBOutlet UIButton *color2;
@property (weak, nonatomic) IBOutlet UIButton *color3;
@property (weak, nonatomic) IBOutlet UIButton *color4;
@property (weak, nonatomic) IBOutlet UIButton *color5;
@property (weak, nonatomic) IBOutlet UIButton *color6;
@property (weak, nonatomic) IBOutlet UIButton *color7;
@property (weak, nonatomic) IBOutlet UIButton *color8;
@property (weak, nonatomic) IBOutlet UILabel *lb_title;
- (IBAction)selectedColor:(id)sender;
@end
