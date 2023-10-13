//
//  ColorFanViewController.m
//  Decorator
//
//  Created by Hoang Le on 9/20/13.
//  Copyright (c) 2013 Hoang Le. All rights reserved.
//

#import "ColorFanViewController.h"
#import "ColorFanSheet.h"
#import "Color.h"
#import "JPMA.h"
#import <QuartzCore/QuartzCore.h>
#import "ImageProcessor.h"
#import "UIView+ColorOfPoint.h"
#import "JPMAColor.h"

#define SHEET_WIDTH 141.5f
#define NUMBER_OF_SHEET 87
#define FILE_WIDTH 12288
@interface ColorFanViewController (){
    NSMutableArray *colorList;
    int pageIndex;
    BOOL isSelectedSheet;
    int selectedIndex;
    CGRect frame;
    BOOL isLoadingFinish;
    LayerObject *layer;
    int selectedColorIndex;
    BOOL isExist;
    BOOL isChangeColor;
    CGFloat minScale;
}

@end

@implementation ColorFanViewController
@synthesize delegate;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithFrame:(CGRect)_frame{
    self = [super init];
    if (self) {
        frame = _frame;
    }
    return self;
}

- (id)initWithFrame:(CGRect)_frame andLayerSelected:(LayerObject *)_layer{
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

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation;{
}

- (void)showHUD{
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
	[self.view addSubview:HUD];
    HUD.mode = MBProgressHUDModeIndeterminate;
    HUD.labelText = @"Loading...";
	HUD.dimBackground = YES;
	HUD.delegate = self;
    [HUD show:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    self.view.frame = frame;
    _bt_cancel.superview.alpha = 0;
    _bt_cancel.layer.borderColor = [UIColor whiteColor].CGColor;
    _bt_cancel.layer.borderWidth = 6.0f;
    _bt_accept.layer.borderWidth = 6.0f;
    _bt_accept.layer.borderColor = [UIColor whiteColor].CGColor;
//    _colorImage.frame = CGRectMake(0, 0, 14112, 550);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_colorImage setImage:[UIImage imageNamed:@"JPMA_color"]];
        [_scrollView setContentSize:_colorImage.image.size];//CGSizeMake(15996, 594)];
        minScale = MIN(1, _scrollView.frame.size.height / _colorImage.image.size.height);
        self.scrollView.minimumZoomScale = minScale;
        [self.scrollView setZoomScale:minScale animated:NO];
        
        [UIView animateWithDuration:0.1f animations:^{
            _bt_cancel.superview.alpha = 1;
            [_scrollView setAlpha:1.0f];
        } completion:nil];
        
        selectedColorIndex = 0;
        isExist = NO;
        NSString* path = [[NSBundle mainBundle] pathForResource:@"JPMAColor"
                                                         ofType:@"json"];
        NSString* content = [NSString stringWithContentsOfFile:path
                                                      encoding:NSUTF8StringEncoding
                                                         error:NULL];
        NSError *error;
        JPMAColor *object = [[JPMAColor alloc] initWithString:content error:&error];
        if (error) {
            NSLog(@"%@",error);
        }
        else{
            colorList = [[NSMutableArray alloc] initWithArray:object.JPMA];
        }
        for (JPMA *color in colorList) {
            if ([layer.colorValue.ColorCode isEqualToString:color.ColorCode]) {
                isExist = YES;
                break;
            }
            selectedColorIndex += 1;
        }
        if (isExist) {
            [self addSelectedColorIcon:selectedColorIndex];
        }
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToColorSheet:)];
        tapGesture.numberOfTapsRequired = 1;
        tapGesture.numberOfTouchesRequired = 1;
        [_scrollView addGestureRecognizer:tapGesture];
    });
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _colorImage;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
}

- (void)addSelectedColorIcon:(int)_selectedColorIndex{
    if (!isExist) {
        return;
    }
    int xvalue,yvalue;
    xvalue = floor(_selectedColorIndex/8);
    yvalue = _selectedColorIndex % 8;
    CGRect checkFrame = CGRectMake((ceil(FILE_WIDTH *xvalue/NUMBER_OF_SHEET)+10) * minScale, (69 * yvalue + 33) * minScale, 32 * minScale, 32 * minScale);
    UIImageView *checkIcon = [[UIImageView alloc] initWithFrame:checkFrame];
    checkIcon.image = [UIImage imageNamed:@"ok-icon"];
    checkIcon.userInteractionEnabled = NO;
    checkIcon.exclusiveTouch = NO;
    checkIcon.tag = 1000;
    [_scrollView addSubview:checkIcon];
    CGRect scrollToFrame = CGRectMake(MAX(0, (ceil(FILE_WIDTH *xvalue/NUMBER_OF_SHEET)-(_scrollView.frame.size.width - SHEET_WIDTH)/2)) * minScale, 0, _scrollView.frame.size.width, _scrollView.frame.size.height);
    dispatch_async(dispatch_get_main_queue(), ^{
        [_scrollView scrollRectToVisible:scrollToFrame animated:YES];
    });
   
}

- (void)tapToColorSheet:(UITapGestureRecognizer *)gesture{
    CGPoint location = [gesture locationInView:_scrollView];
    if (location.y < 34 * minScale || location.y > 585 * minScale) {
        return;
    }
    UIColor *selectedColor = [_scrollView colorOfPoint:location];
    if (CGColorEqualToColor(selectedColor.CGColor, [UIColor colorWithRed:1 green:1 blue:1 alpha:1].CGColor)||CGColorEqualToColor(selectedColor.CGColor, [UIColor colorWithRed:0 green:0 blue:0 alpha:0].CGColor)) {
        return;
    }
    int xValue,yValue;
    xValue = floor(location.x/(SHEET_WIDTH * minScale));
    yValue = floor(location.y/(69 * minScale));
    JPMA *color = [colorList objectAtIndex:(xValue * 8 + yValue)];
    if (color.ColorCode.length == 0) {
        return;
    }
    Color *convertColor = [[Color alloc] init];
    convertColor.No = color.No;
    convertColor.ColorCode = color.ColorCode;
    convertColor.R = color.R;
    convertColor.R1 = color.R;
    convertColor.G = color.G;
    convertColor.G1 = color.G;
    convertColor.B = color.B;
    convertColor.B1 = color.B;
    
    [[self.scrollView viewWithTag:1000] removeFromSuperview];
    UIImageView *checkImg = [[UIImageView alloc] initWithFrame:CGRectMake((xValue*SHEET_WIDTH+10) * minScale, (69 * yValue + 33) * minScale, 32 * minScale, 32 * minScale)];
    checkImg.image = [UIImage imageNamed:@"ok-icon"];
    checkImg.userInteractionEnabled = NO;
    checkImg.exclusiveTouch = NO;
    checkImg.tag = 1000;
    [self.scrollView addSubview:checkImg];
    isChangeColor = YES;
    [delegate selectedColorValue:convertColor];
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        [_colorPreviewContainer setHidden: NO];
        _previewColorView.backgroundColor = selectedColor;
        _previewColorName.text = convertColor.ColorCode;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)backToColorMenu:(id)sender {
    if (isChangeColor) {
        [delegate cancelSelectJPMAColor:layer];
    }
    [delegate closeColorFanController:NO];
}

- (IBAction)acceptChangeColor:(id)sender {
    [delegate closeColorFanController:YES];
}
- (IBAction)cancelPreviewColor:(id)sender {
    [_colorPreviewContainer setHidden:YES];
}
@end
