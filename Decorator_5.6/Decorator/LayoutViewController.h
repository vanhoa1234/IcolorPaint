//
//  LayoutViewController.h
//  Decorator
//
//  Created by Hoang Le on 11/28/13.
//  Copyright (c) 2013 Hoang Le. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "ZDStickerView.h"
#import "LayoutCell.h"
#import "SPUserResizableView.h"

@class THLabel;
@class Plan;

@protocol LayoutViewControllerDelegate <NSObject>
@optional
- (void)closeLayoutController;
//- (void)updateApplyPlanStatus:(int)status;
- (void)updateApplyPlanStatus:(int)status atIndex:(int)_planIndex;
@end

@interface LayoutViewController : UIViewController<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,SPUserResizableViewDelegate,UITextViewDelegate, UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
@property (nonatomic, assign) id<LayoutViewControllerDelegate> delegate;

- (id)initWithPlanID:(int)_planID withImageOrientation:(UIInterfaceOrientation)_orientation;
//- (id)initWithHouseID:(int)_houseID andMaterials:(NSMutableArray *)_materials andImage:(UIImage *)_planImage andPlan:(Plan *)_plan;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UITextField *inputView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (strong, nonatomic) IBOutlet UIView *headerView;
- (IBAction)showBackgroundPicker:(id)sender;
- (IBAction)showOutputMenu:(id)sender;
- (IBAction)exitLayoutManager:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *bt_output;
@property (weak, nonatomic) IBOutlet UIImageView *logo;

@property (weak, nonatomic) IBOutlet UIImageView *background;
- (IBAction)gotoSampleOrder:(id)sender;
@property (weak, nonatomic) IBOutlet THLabel *lb_username;
@property (weak, nonatomic) IBOutlet THLabel *lb_logoPrefix;
@property (weak, nonatomic) IBOutlet UIButton *btPrevious;
@property (weak, nonatomic) IBOutlet UIButton *btPrevious2;
@property (weak, nonatomic) IBOutlet UIButton *btNext;
- (IBAction)nextLayout:(id)sender;
- (IBAction)previousLayout:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *textfieldInput;
- (IBAction)gotoMasking:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *bt_masking;
- (IBAction)gotoMenu:(id)sender;
- (IBAction)applyThisPlan:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *txt_houseName;
@property (weak, nonatomic) IBOutlet UIButton *bt_applyPlan;
@property (weak, nonatomic) IBOutlet UILabel *lb_planName;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIView *draggableViewContainer;
- (IBAction)startEditHouseName:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *bt_editHouseName;
@property (weak, nonatomic) IBOutlet UILabel *txt_info;
- (IBAction)actionAddText:(id)sender;
@property (nonatomic) UIInterfaceOrientation layoutOrientation;
- (IBAction)undoLayoutAction:(id)sender;
- (IBAction)redoLayoutAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *bt_undo;
@property (weak, nonatomic) IBOutlet UIButton *bt_redo;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
//@property (weak, nonatomic) IBOutlet UIView *collectionContainer;
@property (weak, nonatomic) IBOutlet UIView *controlContainer;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomHeightConstraint;

@property (weak, nonatomic) IBOutlet UILabel *lbUndo;
@property (weak, nonatomic) IBOutlet UILabel *lbRedo;
@property (weak, nonatomic) IBOutlet UILabel *lbComment;
@property (weak, nonatomic) IBOutlet UILabel *lbBackground;
@property (weak, nonatomic) IBOutlet UILabel *lbExport;
@property (weak, nonatomic) IBOutlet UILabel *lbMasking;
@property (weak, nonatomic) IBOutlet UILabel *lbBack;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *applyRightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *planTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *planLeftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *planRightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoHeightConstraint;
@end
