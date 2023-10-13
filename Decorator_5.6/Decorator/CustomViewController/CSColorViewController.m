//
//  CSColorViewController.m
//  Decorator
//
//  Created by Le Hoang on 2/19/16.
//  Copyright © 2016 Hoang Le. All rights reserved.
//

#import "CSColorViewController.h"

@interface CSColorViewController (){
    CGRect frame;
    LayerObject *layer;
    BOOL isExist;
    int selectedCSColor;
    BOOL isChangeCSColor;
    NSMutableArray *csColors;
    int selectedColorIndex;
}

@end

@implementation CSColorViewController

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
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.frame = frame;
    _bt_cancel.layer.borderColor = [UIColor whiteColor].CGColor;
    _bt_cancel.layer.borderWidth = 6.0f;
    _bt_accept.layer.borderWidth = 6.0f;
    _bt_accept.layer.borderColor = [UIColor whiteColor].CGColor;
    _scrollview.contentSize = CGSizeMake(2042, 588);
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"CSColor" ofType:@"plist"];
    csColors = [[NSMutableArray alloc] initWithArray:[NSArray arrayWithContentsOfFile:plistPath]];
    selectedColorIndex = 0;
    for (NSString *colorCode in csColors) {
        selectedColorIndex += 1;
        if ([colorCode isEqualToString:layer.colorValue.ColorCode]) {
            isExist = YES;
            break;
        }
    }
    if (isExist) {
        UIButton *selectedButton = (UIButton *)[self.view viewWithTag:selectedColorIndex];
        UIImageView *checkImg = [[UIImageView alloc] initWithFrame:CGRectMake(80, 8, 32, 32)];
        checkImg.image = [UIImage imageNamed:@"ok-icon"];
        checkImg.userInteractionEnabled = NO;
        checkImg.exclusiveTouch = NO;
        checkImg.tag = 1000;
        [selectedButton addSubview:checkImg];
        
        CGRect selectedRect = [selectedButton.superview convertRect:selectedButton.frame toView:_scrollview];
        if ((selectedRect.origin.x + _scrollview.frame.size.width/2) > _scrollview.contentSize.width) {
            [_scrollview scrollRectToVisible:CGRectMake(_scrollview.contentSize.width - 20, selectedRect.origin.y,selectedRect.size.width,selectedRect.size.height) animated:YES];
        }
        else{
            [_scrollview scrollRectToVisible:CGRectMake((selectedRect.origin.x + _scrollview.frame.size.width/2), selectedRect.origin.y,selectedRect.size.width,selectedRect.size.height) animated:YES];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CGFloat minScale = _scrollview.frame.size.height / 520;
        NSLog(@"%f %f", _scrollview.frame.size.height, minScale);
        _scrollview.minimumZoomScale = minScale;
        [_scrollview setZoomScale:minScale animated:NO];
        _subScrollView.hidden = NO;
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - scroll view delegate
- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.subScrollView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)dismissThisController:(id)sender {
    if (isChangeCSColor) {
        [_delegate cancelSelectCSColorWithLayer:layer];
    }
    [_delegate dismissCSColorController:NO];
}

- (IBAction)acceptColorChange:(id)sender {
    [_delegate dismissCSColorController:YES];
}

- (IBAction)selectedColor:(id)sender {
    if (selectedColorIndex == [(UIButton *)sender tag] - 1) {
        return;
    }
    [[self.view viewWithTag:1000] removeFromSuperview];
    UIButton *selectedButton = (UIButton *)sender;
    UIImageView *checkImg = [[UIImageView alloc] initWithFrame:CGRectMake(80, 8, 32, 32)];
    checkImg.image = [UIImage imageNamed:@"ok-icon"];
    checkImg.userInteractionEnabled = NO;
    checkImg.exclusiveTouch = NO;
    checkImg.tag = 1000;
    [selectedButton addSubview:checkImg];
    
    selectedColorIndex = [selectedButton tag] - 1;
    UIColor *buttonColor = selectedButton.backgroundColor;
    const CGFloat *_components = CGColorGetComponents(buttonColor.CGColor);
    Color *convertColor = [[Color alloc] init];
    convertColor.No = selectedButton.tag + 1;
    convertColor.ColorCode = [csColors objectAtIndex:selectedColorIndex];
    convertColor.R = _components[0]*255;
    convertColor.R1 = _components[0]*255;
    convertColor.G = _components[1]*255;
    convertColor.G1 = _components[1]*255;
    convertColor.B = _components[2]*255;
    convertColor.B1 = _components[2]*255;
    isChangeCSColor = YES;
    [_delegate selectedCSColor:convertColor];
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        [_colorPreviewContainer setHidden: NO];
        _previewColorView.backgroundColor = buttonColor;
        _previewColorName.text = convertColor.ColorCode;
    }
}

- (IBAction)cancelPreviewColor:(id)sender {
    [_colorPreviewContainer setHidden:YES];
}
@end
