//
//  PlanViewController.h
//  Decorator
//
//  Created by Hoang Le on 9/16/13.
//  Copyright (c) 2013 Hoang Le. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMMoveTableView.h"
#import "MBProgressHUD.h"
#import "NYSliderPopover.h"
@class MZFormSheetController;
@interface PlanViewController : UIViewController<FMMoveTableViewDataSource,FMMoveTableViewDelegate,UIScrollViewDelegate,MBProgressHUDDelegate>{
    NSMutableArray *layerDatasource;
    BOOL isAutoPath;
    UIBezierPath *myPath;
    CAShapeLayer *shapeLayer;
    BOOL startDraw;
    NSMutableArray *pointArray;
    MBProgressHUD *HUD;
    BOOL isEraserMode;
    BOOL isCreatePointMode;
    BOOL isEditingTableMode;
//    CAShapeLayer *circlePoint;
    NSMutableArray *buttonPointArray;
    
    int houseID;
    int savedPlanID;
    BOOL isSavedPlan;
//    int lastPlanID;
    int planIndex;
//    int lastSavedPlanID;
}
@property (weak, nonatomic) IBOutlet UIView *menuView;
- (IBAction)action_logout:(id)sender;
- (id)initWithImage:(UIImage *)_image withResizeImage:(BOOL)_isResizeImage andImageOrientation:(UIImageOrientation)orientation andLayoutOrientation:(UIInterfaceOrientation)_layoutOrientation;
- (id)initWithImage:(UIImage *)_image withResizeImage:(BOOL)_isResizeImage andImageOrientation:(UIImageOrientation)orientation withHouseID:(int)_houseID  andLayoutOrientation:(UIInterfaceOrientation)_layoutOrientation;
- (id)initWithImage:(UIImage *)_image withResizeImage:(BOOL)_isResizeImage andImageOrientation:(UIImageOrientation)orientation withHouseID:(int)_houseID planID:(int)_planID andLayers:(NSMutableArray *)_layers  andLayoutOrientation:(UIInterfaceOrientation)_layoutOrientation;
- (id)initWithImage:(UIImage *)_image withResizeImage:(BOOL)_isResizeImage andImageOrientation:(UIImageOrientation)orientation andLongitude:(float)_longitude andLatitude:(float)_latitude  andLayoutOrientation:(UIInterfaceOrientation)_layoutOrientation;
@property (strong, nonatomic) IBOutlet UIView *headerTableView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *rightView;
@property (weak, nonatomic) IBOutlet UIView *toolFrameView;
@property (weak, nonatomic) IBOutlet FMMoveTableView *planTableView;
- (IBAction)undoAction:(id)sender;
- (IBAction)redoAction:(id)sender;
@property (weak, nonatomic) IBOutlet UISlider *thresholdSlider;
- (IBAction)thresholdChanged:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *bt_undo;
@property (weak, nonatomic) IBOutlet UIButton *bt_redo;
@property (weak, nonatomic) IBOutlet UIButton *bt_complete;
@property (weak, nonatomic) IBOutlet UIButton *bt_removeLastPoint;
- (IBAction)action_removeLastPoint:(id)sender;
- (IBAction)action_CompletePointPath:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *view_drawMode;
@property (weak, nonatomic) IBOutlet UILabel *lb_penWidth;
@property (weak, nonatomic) IBOutlet NYSliderPopover *slider_penWidth;
@property (weak, nonatomic) IBOutlet UILabel *lb_planValue;

@property (nonatomic, strong)MZFormSheetController *formSheet;
@property (nonatomic, strong) NSDateFormatter *formatter;
- (IBAction)slider_penWidthChanged:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *lb_thresholdValue;

- (IBAction)setNewLayer:(id)sender;
- (IBAction)setEditingMode:(id)sender;

- (IBAction)savePlan:(id)sender;
- (IBAction)createNewPlan:(id)sender;
- (IBAction)deleteThisPlan:(id)sender;
- (IBAction)gotoLayout:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundTool;
@property (weak, nonatomic) IBOutlet UIImageView *background;
@property (weak, nonatomic) IBOutlet UIView *brushView;
@property (weak, nonatomic) IBOutlet UIButton *tool_pen;
@property (weak, nonatomic) IBOutlet UIButton *tool_handDraw;
@property (weak, nonatomic) IBOutlet UIButton *tool_eraser;
@property (weak, nonatomic) IBOutlet UIButton *tool_handEraser;
- (IBAction)toolAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *bg_scrollThreshold;
@property (weak, nonatomic) IBOutlet UIImageView *bg_scrollPen;
@property (weak, nonatomic) IBOutlet UIButton *applyIcon;
- (IBAction)applyPlanAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btNext;
- (IBAction)nextPlan:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btPrevious;
- (IBAction)previousPlan:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *bt_removePlan;
@property (weak, nonatomic) IBOutlet UIImageView *bannerView;
- (IBAction)tapToBanner:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *bt_savePlan;
@property (weak, nonatomic) IBOutlet UIButton *bt_addPlan;
@property (weak, nonatomic) IBOutlet UIButton *bt_deletePlan;
@property (weak, nonatomic) IBOutlet UIButton *bt_addLayer;
- (IBAction)gotoEditImage:(id)sender;
@property (nonatomic) UIInterfaceOrientation layoutOrientation;
@property (weak, nonatomic) IBOutlet UIView *bannerContainer;

@property (weak, nonatomic) IBOutlet UILabel *lb_transparentValue;
@property (weak, nonatomic) IBOutlet UIImageView *bg_scrollTransparent;
@property (weak, nonatomic) IBOutlet UISlider *slider_transparent;
- (IBAction)slider_transparentChanged:(id)sender;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *menuRightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *menuBottomConstraint;

@property (weak, nonatomic) IBOutlet UILabel *lbSave;
@property (weak, nonatomic) IBOutlet UILabel *lbUndo;
@property (weak, nonatomic) IBOutlet UILabel *lbRedo;
@property (weak, nonatomic) IBOutlet UILabel *lbDelete;
@property (weak, nonatomic) IBOutlet UILabel *lbAdd;
@property (weak, nonatomic) IBOutlet UILabel *lbEdit;
@property (weak, nonatomic) IBOutlet UILabel *lbLayout;
@property (weak, nonatomic) IBOutlet UILabel *lbBack;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *menuPortraitBottomConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewLeftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bannerTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewLeftConstraintPad;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewRightConstraintPad;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewTopConstraintPad;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewBottomConstraintPad;

@end
