//
//  PatternPickerViewController.m
//  Decorator
//
//  Created by Hoang Le on 10/9/13.
//  Copyright (c) 2013 Hoang Le. All rights reserved.
//

#import "PatternPickerViewController.h"
#import <QuartzCore/QuartzCore.h>
//#import "GMGridView.h"

@interface PatternPickerViewController ()//<GMGridViewDataSource, GMGridViewActionDelegate>
{
//    __gm_weak GMGridView *_gmGridView;
    NSMutableArray *_patternData;
    CGRect frame;
    LayerObject *layer;
    BOOL isExist;
    int selectedPattern;
    BOOL isChangePattern;
}

@end

@implementation PatternPickerViewController
@synthesize delegate;

- (id)initWithFrame:(CGRect)_frame andLayer:(LayerObject *)_layer{
    self = [super init];
    if (self) {
//        layer = _layer;
        layer = [[LayerObject alloc] init];
        layer.type = _layer.type;
        layer.image = _layer.image;
        layer.name = _layer.name;
        layer.color = _layer.color;
        layer.colorValue = _layer.colorValue;
        layer.patternImage = _layer.patternImage;
        layer.feature = _layer.feature;
        layer.gloss = _layer.gloss;
        layer.pattern = _layer.pattern;
        frame = _frame;
        _patternData = [[NSMutableArray alloc] initWithObjects:@"ＧＴ102",@"ＧＴ106",@"ＧＴ204",@"ＧＴ305",@"ＧＴ407",@"ＧＴ408",@"ＧＴ601", nil];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation;{
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.frame = frame;
    if (frame.size.width < frame.size.height) {
        self.containView.frame = CGRectMake(self.containView.frame.origin.x, self.containView.frame.origin.y - 120, self.containView.frame.size.width, self.containView.frame.size.height);
    }
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        _bt_accept.hidden = YES;
        _bt_cancel.hidden = YES;
    }
    _bt_cancel.layer.borderColor = [UIColor whiteColor].CGColor;
    _bt_cancel.layer.borderWidth = 6.0f;
    _bt_accept.layer.borderWidth = 6.0f;
    _bt_accept.layer.borderColor = [UIColor whiteColor].CGColor;
    selectedPattern = 0;
    isExist = NO;
    if (layer.patternImage.length > 0) {
        for (NSString *pattern in _patternData) {
            if ([pattern isEqualToString:layer.patternImage]) {
                isExist = YES;
                break;
            }
            selectedPattern++;
        }
    }
    if (isExist) {
        UIButton *selectedButton = (UIButton *)[self.view viewWithTag:selectedPattern+1];
        UIImageView *checkImg = [[UIImageView alloc] initWithFrame:CGRectMake(80, 8, 32, 32)];
        checkImg.image = [UIImage imageNamed:@"ok-icon"];
        checkImg.userInteractionEnabled = NO;
        checkImg.exclusiveTouch = NO;
        checkImg.tag = 1000;
        [selectedButton addSubview:checkImg];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)selectedButtonPattern:(id)sender {
    if (selectedPattern == [(UIButton *)sender tag] - 1) {
        return;
    }
    selectedPattern = [(UIButton *)sender tag] - 1;
    [[self.view viewWithTag:1000] removeFromSuperview];
    UIButton *selectedButton = (UIButton *)sender;
    UIImageView *checkImg = [[UIImageView alloc] initWithFrame:CGRectMake(80, 8, 32, 32)];
    checkImg.image = [UIImage imageNamed:@"ok-icon"];
    checkImg.userInteractionEnabled = NO;
    checkImg.exclusiveTouch = NO;
    checkImg.tag = 1000;
    [selectedButton addSubview:checkImg];
    NSString *selectedPatternName = [_patternData objectAtIndex:([(UIButton *)sender tag]-1)];
    isChangePattern = YES;
    [delegate selectedPattern:selectedPatternName];
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        [_colorPreviewContainer setHidden: NO];
        _previewColorView.layer.contents = (id)[(UIButton *)sender currentBackgroundImage].CGImage;
        _previewColorName.text = [_patternData objectAtIndex:([(UIButton *)sender tag]-1)];
    }
}

- (IBAction)closePatternPickerView:(id)sender {
    if (isChangePattern) {
        [delegate cancelSelectPatternWithLayer:layer];
    }
    [delegate closePatternPickerView:NO];
}

- (IBAction)acceptChangePattern:(id)sender {
    [delegate closePatternPickerView:YES];
}

- (IBAction)cancelPreviewColor:(id)sender {
    [_colorPreviewContainer setHidden:YES];
}
@end
