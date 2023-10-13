//
//  SuzukafineViewController.m
//  Decorator
//
//  Created by Hoang Le on 10/14/13.
//  Copyright (c) 2013 Hoang Le. All rights reserved.
//

#import "SuzukafineViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ImageProcessor.h"
#import "ColorUtils.h"
#import "SuzukafineColor.h"

@interface SuzukafineViewController ()
{
    NSMutableArray *_colorData;
    CGRect frame;
    LayerObject *layer;
    int selectedColorIndex;
    BOOL isExist;
    BOOL isChangeColor;
}

@end

@implementation SuzukafineViewController
@synthesize delegate;

- (id)initWithFrame:(CGRect)_frame{
    self = [super init];
    if (self) {
        frame = _frame;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithFrame:(CGRect)_frame andLayer:(LayerObject *)_layer{
    self = [self initWithFrame:_frame];
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
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.frame = frame;
    _bt_cancel.layer.borderColor = [UIColor whiteColor].CGColor;
    _bt_cancel.layer.borderWidth = 6.0f;
    _bt_accept.layer.borderWidth = 6.0f;
    _bt_accept.layer.borderColor = [UIColor whiteColor].CGColor;
    isExist = NO;
    selectedColorIndex = 0;
    self.scrollView.contentSize = CGSizeMake(800, self.scrollView.frame.size.height);

    NSString* path = [[NSBundle mainBundle] pathForResource:@"SuzukafineColor"
                                                     ofType:@"json"];
    NSString* content = [NSString stringWithContentsOfFile:path
                                                  encoding:NSUTF8StringEncoding
                                                     error:NULL];
    NSError *error;
    SuzukafineColor *object = [[SuzukafineColor alloc] initWithString:content error:&error];
    if (error) {
        NSLog(@"%@",error);
    }
    else{
        _colorData = [[NSMutableArray alloc] initWithArray:object.Suzukafine];
    }
    for (Suzukafine *color in _colorData) {
        if ([color.ColorCode isEqualToString:layer.colorValue.ColorCode]) {
            isExist = YES;
            break;
        }
        selectedColorIndex += 1;
    }
    [HUD hide:YES];
    if (isExist) {
        UIButton *selectedButton = (UIButton *)[self.view viewWithTag:selectedColorIndex+1];
        UIImageView *checkImg = [[UIImageView alloc] initWithFrame:CGRectMake(80, 8, 32, 32)];
        checkImg.image = [UIImage imageNamed:@"ok-icon"];
        checkImg.userInteractionEnabled = NO;
        checkImg.exclusiveTouch = NO;
        checkImg.tag = 1000;
        [selectedButton addSubview:checkImg];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CGFloat minScale = MIN(1, _scrollView.frame.size.height / 635);
        NSLog(@"%f %f", _scrollView.frame.size.height, minScale);
        _scrollView.minimumZoomScale = minScale;
        [_scrollView setZoomScale:minScale animated:NO];
        _subScrollView.hidden = NO;
        if (_scrollView.superview.frame.size.width > 726 * minScale) {
               _scrollLeftConstraint.constant = (_scrollView.superview.frame.size.width - 726 * minScale) / 2;
           }
        [UIView animateWithDuration:0.3f animations:^{
            [_scrollView setAlpha:1.0f];
        } completion:nil];
    });

}

#pragma mark - scroll view delegate
- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.subScrollView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
}

- (void)showHUD{
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
	[self.view addSubview:HUD];
    HUD.mode = MBProgressHUDModeIndeterminate;
    HUD.labelText = @"Loading...";
	HUD.dimBackground = YES;
	// Regiser for HUD callbacks so we can remove it from the window at the right time
	HUD.delegate = self;
    [HUD show:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)selectedColor:(id)sender {
    if (selectedColorIndex == [(UIButton *)sender tag] - 1) {
        return;
    }
    Suzukafine *color = [_colorData objectAtIndex:([(UIButton *)sender tag] - 1)];
    selectedColorIndex = [(UIButton *)sender tag] - 1;
    Color *convertColor = [[Color alloc] init];
    convertColor.No = color.No;
    convertColor.ColorCode = color.ColorCode;
    convertColor.R = color.R;
    convertColor.R1 = color.R;
    convertColor.G = color.G;
    convertColor.G1 = color.G;
    convertColor.B = color.B;
    convertColor.B1 = color.B;
    
    [[self.view viewWithTag:1000] removeFromSuperview];
    UIButton *selectedButton = (UIButton *)sender;
    UIImageView *checkImg = [[UIImageView alloc] initWithFrame:CGRectMake(80, 8, 32, 32)];
    checkImg.image = [UIImage imageNamed:@"ok-icon"];
    checkImg.userInteractionEnabled = NO;
    checkImg.exclusiveTouch = NO;
    checkImg.tag = 1000;
    [selectedButton addSubview:checkImg];
    
    isChangeColor = YES;
    [delegate selectedSuzukaColor:convertColor];
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        [_colorPreviewContainer setHidden: NO];
        _previewColorView.backgroundColor = [(UIButton *)sender backgroundColor];
        _previewColorName.text = convertColor.ColorCode;
    }
}

- (IBAction)closePatternPickerView:(id)sender {
    if (isChangeColor) {
        [delegate selectedSuzukaColor:layer.colorValue];
    }
    [delegate closeSuzukaPickerView:NO];
}

- (IBAction)acceptChanged:(id)sender {
    [delegate closeSuzukaPickerView:YES];
}

- (IBAction)cancelPreviewColor:(id)sender {
    [_colorPreviewContainer setHidden:YES];
}
@end
