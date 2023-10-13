//
//  BarrierColorViewController.m
//  Decorator
//
//  Created by Le Hoang on 3/23/16.
//  Copyright © 2016 Hoang Le. All rights reserved.
//

#import "BarrierColorViewController.h"

@interface BarrierColorViewController (){
    CGRect frame;
    LayerObject *layer;
    NSArray *barrierData;
    int selectedPattern;
    BOOL isExist;
    BOOL isChangePattern;
//    NSArray *groupData;
}

@end

@implementation BarrierColorViewController

- (id)initWithFrame:(CGRect)_frame andLayer:(LayerObject *)_layer{
    self = [super init];
    if (self) {
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
        barrierData = @[@"外壁材_9_A",@"外壁材_9_B",@"外壁材_9_C",@"外壁材_9_D",@"外壁材_10_A",@"外壁材_10_B",@"外壁材_10_C",@"外壁材_10_D",@"外壁材_6_A",@"外壁材_6_B",@"外壁材_6_C",@"外壁材_6_D",@"外壁材_13_A",@"外壁材_13_B",@"外壁材_13_C",@"外壁材_13_D",@"外壁材_15_A",@"外壁材_15_B",@"外壁材_15_C",@"外壁材_15_D",@"外壁材_11_A",@"外壁材_11_B",@"外壁材_11_C",@"外壁材_11_D",@"外壁材_5_A",@"外壁材_5_B",@"外壁材_5_C",@"外壁材_5_D",@"外壁材_12_A",@"外壁材_12_B",@"外壁材_12_C",@"外壁材_12_D",@"外壁材_4_A",@"外壁材_4_B",@"外壁材_4_C",@"外壁材_4_D",@"外壁材_1_A",@"外壁材_1_B",@"外壁材_1_C",@"外壁材_1_D",@"外壁材_3_A",@"外壁材_3_B",@"外壁材_3_C",@"外壁材_3_D",@"外壁材_2_A",@"外壁材_2_B",@"外壁材_2_C",@"外壁材_2_D",@"外壁材_16_A",@"外壁材_16_B",@"外壁材_16_C",@"外壁材_16_D",@"外壁材_7_A",@"外壁材_7_B",@"外壁材_7_C",@"外壁材_7_D",@"外壁材_8_A",@"外壁材_8_B",@"外壁材_8_C",@"外壁材_8_D",@"外壁材_14_A",@"外壁材_14_B",@"外壁材_14_C",@"外壁材_14_D",@"外壁材_20_A",@"外壁材_20_B",@"外壁材_20_C",@"外壁材_20_D",@"外壁材_19_A",@"外壁材_19_B",@"外壁材_19_C",@"外壁材_19_D",@"外壁材_17_A",@"外壁材_17_B",@"外壁材_17_C",@"外壁材_17_D",@"外壁材_18_A",@"外壁材_18_B",@"外壁材_18_C",@"外壁材_18_D",@"外壁材_22_A",@"外壁材_22_B",@"外壁材_22_C",@"外壁材_22_D",@"外壁材_21_A",@"外壁材_21_B",@"外壁材_21_C",@"外壁材_21_D",@"外壁材_23_A",@"外壁材_23_B",@"外壁材_23_C",@"外壁材_23_D",@"外壁材_24_A",@"外壁材_24_B",@"外壁材_24_C",@"外壁材_24_D",@"外壁材_25_A",@"外壁材_25_B",@"外壁材_25_C",@"外壁材_25_D",@"外壁材_26_A",@"外壁材_26_B",@"外壁材_26_C",@"外壁材_26_D",@"外壁材_27_A",@"外壁材_27_B",@"外壁材_27_C",@"外壁材_27_D",@"外壁材_28_A",@"外壁材_28_B",@"外壁材_28_C",@"外壁材_28_D",@"外壁材_29_A",@"外壁材_29_B",@"外壁材_29_C",@"外壁材_29_D",@"外壁材_30_A",@"外壁材_30_B",@"外壁材_30_C",@"外壁材_30_D",@"外壁材_31_A",@"外壁材_31_B",@"外壁材_31_C",@"外壁材_31_D",@"外壁材_32_A",@"外壁材_32_B",@"外壁材_32_C",@"外壁材_32_D",@"外壁材_33_A",@"外壁材_33_B",@"外壁材_33_C",@"外壁材_33_D",@"外壁材_34_A",@"外壁材_34_B",@"外壁材_34_C",@"外壁材_34_D",@"外壁材_35_A",@"外壁材_35_B",@"外壁材_35_C",@"外壁材_35_D",];
//        groupData = @[@"WB2117", @"WB2118", @"WB2223", @"WB2225", @"WB2333", @"WB2142", @"WB2149", @"WB2141", @"WB2144", @"WB2140", @"WB2179", @"WB2174", @"WB2178", @"WB2168", @"WB2170", @"WB2172", @"WB2287", @"WB2256", @"WB2289", @"WB2386", @"WB2295", @"WB2285", @"WB2394", @"WB2393", @"WB2391", @"WB3175", @"WB3147", @"WB3252", @"WB3220", @"WB3281", @"WB3288", @"WB3183", @"WB3284", @"WB3396", @"WB3335"];
    }
    return self;
}

//3480
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.frame = frame;
    _bt_cancel.superview.alpha = 0;
    _bt_cancel.layer.borderColor = [UIColor whiteColor].CGColor;
    _bt_cancel.layer.borderWidth = 6.0f;
    _bt_accept.layer.borderWidth = 6.0f;
    _bt_accept.layer.borderColor = [UIColor whiteColor].CGColor;
    
//    self.scrollView.contentSize = CGSizeMake(5830, self.scrollView.frame.size.height);
//    if (self.view.frame.size.width < self.view.frame.size.height) {
//        self.scrollView.frame = CGRectMake(110, self.scrollView.frame.origin.y, self.scrollView.frame.size.width - 30, self.scrollView.frame.size.height);
//    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CGFloat minScale = MIN(1, _scrollView.frame.size.height / 630);
        NSLog(@"%f %f", _scrollView.frame.size.height, minScale);
        
        _scrollView.minimumZoomScale = minScale;
        _scrollView.maximumZoomScale = minScale;
        _headerScrollView.minimumZoomScale = minScale;
        [_scrollView setZoomScale:minScale animated:NO];
        [_headerScrollView setZoomScale:minScale animated:NO];
        [UIView animateWithDuration:0.1f animations:^{
            _bt_cancel.superview.alpha = 1;
            [_scrollView setAlpha:1.0f];
            [_headerScrollView setAlpha:1.0f];
        } completion:nil];
        
        selectedPattern = 0;
        isExist = NO;
        if (layer.patternImage.length > 0) {
            for (NSString *pattern in barrierData) {
                if ([pattern isEqualToString:layer.patternImage]) {
                    isExist = YES;
                    break;
                }
                selectedPattern++;
            }
        }
        if (isExist) {
            UIButton *selectedButton = (UIButton *)[self.view viewWithTag:selectedPattern+1];
            UIImageView *checkImg = [[UIImageView alloc] initWithFrame:CGRectMake(60, 8, 32, 32)];
            checkImg.image = [UIImage imageNamed:@"ok-icon"];
            checkImg.userInteractionEnabled = NO;
            checkImg.exclusiveTouch = NO;
            checkImg.tag = 1000;
            [selectedButton addSubview:checkImg];
            
            CGRect selectedRect = [selectedButton.superview convertRect:selectedButton.frame toView:_scrollView];
            if ((selectedRect.origin.x + _scrollView.frame.size.width/2) > _scrollView.contentSize.width) {
                [_scrollView scrollRectToVisible:CGRectMake(_scrollView.contentSize.width - 20, selectedRect.origin.y,selectedRect.size.width,selectedRect.size.height) animated:YES];
            }
            else{
                [_scrollView scrollRectToVisible:CGRectMake((selectedRect.origin.x + _scrollView.frame.size.width/2), selectedRect.origin.y,selectedRect.size.width,selectedRect.size.height) animated:YES];
            }
        }
        else
            selectedPattern = -1;
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

#pragma mark - scroll view delegate
- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    if (scrollView == _headerScrollView) {
        return self.headerSubScrollView;
    }
    return self.subScrollView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
}


- (IBAction)selectedColor:(id)sender {
    if (selectedPattern == [(UIButton *)sender tag] - 1) {
        return;
    }
    selectedPattern = [(UIButton *)sender tag] - 1;
    [[self.view viewWithTag:1000] removeFromSuperview];
    UIButton *selectedButton = (UIButton *)sender;
    UIImageView *checkImg = [[UIImageView alloc] initWithFrame:CGRectMake(60, 8, 32, 32)];
    checkImg.image = [UIImage imageNamed:@"ok-icon"];
    checkImg.userInteractionEnabled = NO;
    checkImg.exclusiveTouch = NO;
    checkImg.tag = 1000;
    [selectedButton addSubview:checkImg];
    NSString *selectedPatternName = [barrierData objectAtIndex:([(UIButton *)sender tag]-1)];
    isChangePattern = YES;
    [_delegate selectedBarrierPattern:selectedPatternName];
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        [_colorPreviewContainer setHidden: NO];
//        _previewColorView.layer.contents = (id)[UIImage imageNamed:[NSString stringWithFormat:@"icon_%@", selectedPatternName]].CGImage;
        _previewColorView.layer.contents = (id)[(UIButton *)sender currentBackgroundImage].CGImage;
        int type = [(UIButton *)sender tag] % 4;
        switch (type) {
            case 1:
                _previewTypeName.text = NSLocalizedString(@"︻石材調小柄︼", nil);
                break;
            case 2:
                _previewTypeName.text = NSLocalizedString(@"︻石材調中柄︼", nil);
                break;
            case 3:
                _previewTypeName.text = NSLocalizedString(@"︻タイル調︼", nil);
                break;
            default:
                _previewTypeName.text = NSLocalizedString(@"︻石材調大柄︼", nil);
                break;
        }
        for (UIView *subView in [[(UIButton *)sender superview] subviews]) {
            if ([subView isKindOfClass:[UILabel class]]) {
                _previewColorName.text = [(UILabel *)subView text];
                break;
            }
        }
        
    }
}

- (IBAction)cancelPreviewColor:(id)sender {
    [_colorPreviewContainer setHidden:YES];
}

- (IBAction)acceptChangePattern:(id)sender {
    [_delegate dismissBarrierColorController:YES];
}

- (IBAction)dismissThisController:(id)sender {
    if (isChangePattern) {
        [_delegate cancelBarrierPattern:layer];
    }
    [_delegate dismissBarrierColorController:NO];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == _scrollView) {
        _titleScrollView.contentOffset = CGPointMake(0, scrollView.contentOffset.y);
    }
}
@end
