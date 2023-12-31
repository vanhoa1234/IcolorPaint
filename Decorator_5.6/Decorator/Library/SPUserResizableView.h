//
//  SPUserResizableView.h
//  SPUserResizableView
//
//  Created by Stephen Poletto on 12/10/11.
//
//  SPUserResizableView is a user-resizable, user-repositionable
//  UIView subclass.

#import <Foundation/Foundation.h>

typedef struct SPUserResizableViewAnchorPoint {
    CGFloat adjustsX;
    CGFloat adjustsY;
    CGFloat adjustsH;
    CGFloat adjustsW;
} SPUserResizableViewAnchorPoint;

@protocol SPUserResizableViewDelegate;
@class SPUGripViewBorderView;

@interface SPUserResizableView : UIView {
    UIButton *deleteButton;
    UIButton *editButton;
    SPUGripViewBorderView *borderView;
    UIView *contentView;
    CGPoint touchStart;
    CGFloat minWidth;
    CGFloat minHeight;
    
    // Used to determine which components of the bounds we'll be modifying, based upon where the user's touch started.
    SPUserResizableViewAnchorPoint anchorPoint;
    
    id <SPUserResizableViewDelegate> delegate;
    BOOL isHideEditControl;
}
- (id)initWithFrame:(CGRect)frame isHideEditControl:(BOOL)hideEditControl;

- (id)initWithFrame:(CGRect)frame isHideEditControl:(BOOL)hideEditControl andIsShowDeleteControl:(BOOL)hideDeleteControl;
@property (nonatomic, assign) id <SPUserResizableViewDelegate> delegate;

// Will be retained as a subview.
@property (nonatomic, assign) UIView *contentView;
@property (nonatomic) BOOL isHideEditButton;
@property (nonatomic) BOOL isShowDeleteButton;
// Default is 48.0 for each.
@property (nonatomic) CGFloat minWidth;
@property (nonatomic) CGFloat minHeight;

// Defaults to YES. Disables the user from dragging the view outside the parent view's bounds.
@property (nonatomic) BOOL preventsPositionOutsideSuperview;

@property (nonatomic) BOOL preventChangeSizeRatio;
- (void)hideEditingHandles;
- (void)showEditingHandles;

@end

@protocol SPUserResizableViewDelegate <NSObject>

@optional

// Called when the resizable view receives touchesBegan: and activates the editing handles.
- (void)userResizableViewDidBeginEditing:(SPUserResizableView *)userResizableView;

// Called when the resizable view receives touchesEnded: or touchesCancelled:
- (void)userResizableViewDidEndEditing:(SPUserResizableView *)userResizableView;

- (void)rotateView:(SPUserResizableView *)userResizableView;

- (void)editContentView:(SPUserResizableView *)userResizableView;

- (void)deleteContentView:(SPUserResizableView *)userResizableView;

- (void)didResizeEnd:(SPUserResizableView *)userResizableView;

- (void)didMoveEnd:(SPUserResizableView *)userResizableView;
@end
