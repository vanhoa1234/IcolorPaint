//
//  ColorPickerModalViewViewController.h
//  Decorator
//
//  Created by Hoang Le on 2/6/14.
//  Copyright (c) 2014 Hoang Le. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LayerObject.h"

typedef enum {
    LCT_SUZUKAFINE = 0,
    LCT_TYPE2 = 1,
    LCT_TYPE3 = 2,
    LCT_NOPAINT = 3,
    LCT_CSTYPE = 4,
    LCT_HOUSE_TEMPLATE = 5,
    LCT_BARRIER = 6,
    LCT_SUZUKAROOF = 7,
    LCT_PICKCOLOR = 8
}LayerColorType;

@protocol ColorPickerModalViewViewControllerDelegate <NSObject>
@optional
- (void)closeColorPicker;
- (void)selectColorType:(int)_type tranferLayer:(LayerObject *)_layer;

@end

@interface ColorPickerModalViewViewController : UIViewController{
    BOOL isHidePatternColor;
}
@property (nonatomic) UIInterfaceOrientation orientation;
@property (nonatomic, assign) id<ColorPickerModalViewViewControllerDelegate> delegate;
- (id)initWithHidePatternColor;
- (id)initWithHidePatternColorWithLayerObject:(LayerObject *)_layer andOrientation:(UIInterfaceOrientation)_orientation withLayerCount:(int)_numberOfLayer;
- (id)initWithLayer:(LayerObject *)_layer andOrientation:(UIInterfaceOrientation)_orientation withLayerCount:(int)_numberOfLayer;
- (IBAction)closeMe:(id)sender;
- (IBAction)selectSuzukaColor:(id)sender;
- (IBAction)selectColorType2:(id)sender;
- (IBAction)selectColorType3:(id)sender;
- (IBAction)selectCSColor:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lb_pattern;
@property (weak, nonatomic) IBOutlet UIButton *bt_pattern;
- (IBAction)selectNoPaintLayer:(id)sender;
- (IBAction)selectHouseTemplateType:(id)sender;
- (IBAction)selectBarrierColor:(id)sender;
- (IBAction)selectSuzukaRoofColor:(id)sender;
- (IBAction)selectPickColor:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *bt_wbpattern;
@property (weak, nonatomic) IBOutlet UILabel *lb_wbpattern;

@property (weak, nonatomic) IBOutlet UILabel *lb_housetemplate;
@property (weak, nonatomic) IBOutlet UIButton *bt_housetemplate;
@end
