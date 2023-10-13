//
//  ColorPickerModalViewViewController.m
//  Decorator
//
//  Created by Hoang Le on 2/6/14.
//  Copyright (c) 2014 Hoang Le. All rights reserved.
//

#import "ColorPickerModalViewViewController.h"

@interface ColorPickerModalViewViewController (){
    LayerObject *layer;
    int numberOfLayer;
}

@end

@implementation ColorPickerModalViewViewController
@synthesize orientation;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithHidePatternColor:(UIInterfaceOrientation)_orientation {
//    self = [super init];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && UIInterfaceOrientationIsPortrait(_orientation)) {
        self = [self initWithNibName:@"ColorPickerModalViewViewController_Portrait" bundle:nil];
    } else {
        self = [self initWithNibName:@"ColorPickerModalViewViewController" bundle:nil];
    }
    if (self) {
        isHidePatternColor = YES;
    }
    return self;
}

- (id)initWithHidePatternColorWithLayerObject:(LayerObject *)_layer andOrientation:(UIInterfaceOrientation)_orientation withLayerCount:(int)_numberOfLayer{
    self = [self initWithHidePatternColor:_orientation];
    if (self) {
        layer = _layer;
        orientation = _orientation;
        numberOfLayer = _numberOfLayer;
    }
    return self;
}

- (id)initWithLayer:(LayerObject *)_layer andOrientation:(UIInterfaceOrientation)_orientation withLayerCount:(int)_numberOfLayer{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && UIInterfaceOrientationIsPortrait(_orientation)) {
        self = [self initWithNibName:@"ColorPickerModalViewViewController_Portrait" bundle:nil];
    } else {
        self = [self initWithNibName:@"ColorPickerModalViewViewController" bundle:nil];
    }
    if (self) {
        layer = _layer;
        orientation = _orientation;
        numberOfLayer = _numberOfLayer;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    if (isHidePatternColor) {
//        _lb_pattern.enabled = NO;
//        _bt_pattern.enabled = NO;
//        
//        _lb_wbpattern.enabled = NO;
//        _bt_wbpattern.enabled = NO;
//    }
    if (numberOfLayer > 10) {
        _lb_housetemplate.enabled = NO;
        _bt_housetemplate.enabled = NO;
    }
    else{
        _lb_housetemplate.enabled = YES;
        _bt_housetemplate.enabled = YES;
    }
//    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
//        self.view.backgroundColor = [UIColor clearColor];
//    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)closeMe:(id)sender {
    [_delegate closeColorPicker];
}

- (IBAction)selectSuzukaColor:(id)sender {
    [_delegate selectColorType:LCT_SUZUKAFINE tranferLayer:layer];
}

- (IBAction)selectColorType2:(id)sender {
    [_delegate selectColorType:LCT_TYPE2 tranferLayer:layer];
}

- (IBAction)selectColorType3:(id)sender {
    [_delegate selectColorType:LCT_TYPE3 tranferLayer:layer];
}

- (IBAction)selectCSColor:(id)sender {
    [_delegate selectColorType:LCT_CSTYPE tranferLayer:layer];
}
- (IBAction)selectNoPaintLayer:(id)sender {
    [_delegate selectColorType:LCT_NOPAINT tranferLayer:layer];
}

- (IBAction)selectHouseTemplateType:(id)sender {
    [_delegate selectColorType:LCT_HOUSE_TEMPLATE tranferLayer:layer];
}

- (IBAction)selectBarrierColor:(id)sender {
    [_delegate selectColorType:LCT_BARRIER tranferLayer:layer];
}

- (IBAction)selectSuzukaRoofColor:(id)sender {
    [_delegate selectColorType:LCT_SUZUKAROOF tranferLayer:layer];
}

- (IBAction)selectPickColor:(id)sender {
    [_delegate selectColorType:LCT_PICKCOLOR tranferLayer:layer];
}
@end
