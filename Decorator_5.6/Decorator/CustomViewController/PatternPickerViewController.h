//
//  PatternPickerViewController.h
//  Decorator
//
//  Created by Hoang Le on 10/9/13.
//  Copyright (c) 2013 Hoang Le. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LayerObject.h"
@protocol PatternPickerViewControllerDelegate <NSObject>
@optional
- (void)closePatternPickerView:(BOOL)_isChangePattern;
- (void)selectedPattern:(NSString *)_patternStr;
- (void)cancelSelectPatternWithLayer:(LayerObject *)_layer;
@end

@interface PatternPickerViewController : UIViewController
@property (nonatomic, assign) id<PatternPickerViewControllerDelegate> delegate;
- (id)initWithFrame:(CGRect)_frame andLayer:(LayerObject *)_layer;
- (IBAction)closePatternPickerView:(id)sender;
- (IBAction)selectedButtonPattern:(id)sender;
- (IBAction)acceptChangePattern:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *bt_cancel;
@property (weak, nonatomic) IBOutlet UIButton *bt_accept;
@property (weak, nonatomic) IBOutlet UIView *containView;

@property (weak, nonatomic) IBOutlet UIView *previewColorView;
@property (weak, nonatomic) IBOutlet UILabel *previewColorName;
- (IBAction)cancelPreviewColor:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *colorPreviewContainer;
@end
