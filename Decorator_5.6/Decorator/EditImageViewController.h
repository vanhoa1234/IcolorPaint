//
//  EditImageViewController.h
//  Decorator
//
//  Created by Hoang Le on 5/13/14.
//  Copyright (c) 2014 Hoang Le. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import <UIKit/UIKit.h>
@class opencv;

@protocol EditImageViewControllerDelegate <NSObject>
@optional
- (void)editImageComplete:(cv::Mat)_cvimageUpdated;

@end

@interface EditImageViewController : UIViewController
@property (nonatomic, assign) id<EditImageViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIView *sliderArea;
- (IBAction)sliderValueChanged:(id)sender;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
- (id)initWithcvOriginalImage:(cv::Mat)_cvoriginalImage;
- (id)initWithcvOriginalImage:(cv::Mat)_cvoriginalImage withLayoutOrientation:(UIInterfaceOrientation)_orientation;
- (id)initWithcvOriginalImage:(cv::Mat)_cvoriginalImage withLayoutOrientation:(UIInterfaceOrientation)_orientation andLayerDatasource:(NSMutableArray *)_layerDatasource;
- (IBAction)backToPlan:(id)sender;
- (IBAction)backToRoot:(id)sender;
@property (weak, nonatomic) IBOutlet UISlider *sliderWidth;
- (IBAction)action_Undo:(id)sender;
- (IBAction)action_Redo:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btundo;
@property (weak, nonatomic) IBOutlet UIButton *btredo;
- (IBAction)previewAction:(id)sender;
@property (nonatomic) UIInterfaceOrientation layoutOrientation;
@property (weak, nonatomic) IBOutlet UIView *bannerView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIView *rightView;
@property (weak, nonatomic) IBOutlet UIImageView *bannerImage;
@property (weak, nonatomic) IBOutlet UIButton *btSmallErase;
@property (weak, nonatomic) IBOutlet UIButton *btBigErase;
- (IBAction)selectedType:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *menuView;
- (IBAction)selectedMenuItem:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *processingView;
- (IBAction)cancelProcessing:(id)sender;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *processingActivity;
@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (weak, nonatomic) IBOutlet UIImageView *previewImage;
- (IBAction)closePreview:(id)sender;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *menuBottomConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bannerTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewBottomContraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewLeftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewLeftConstraintPad;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewRightConstraintPad;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewWidthContraint;

@property (weak, nonatomic) IBOutlet UILabel *lbUndo;
@property (weak, nonatomic) IBOutlet UILabel *lbRedo;
@property (weak, nonatomic) IBOutlet UILabel *lbPreview;
@property (weak, nonatomic) IBOutlet UILabel *lbMasking;
@property (weak, nonatomic) IBOutlet UILabel *lbTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftMenuWidthConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewTopConstraintPad;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewBottomConstraintPad;

@end
