//
//  GBCustomCallout.h
//  MapCallouts
//
//  Created by Adam Barrett on 2013-09-12.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>

@protocol GBCustomCalloutViewDelegate;
@protocol GBCustomCalloutConstrainingRectSupplier;

// options for which directions the callout is allowed to "point" in.
typedef enum {
    GBCustomCalloutArrowDirectionAny,
    GBCustomCalloutArrowDirectionDown = 1UL << 0,
    GBCustomCalloutArrowDirectionUp = 1UL << 1,
} GBCustomCalloutArrowDirection;

// options for the callout present/dismiss animation
typedef enum {
    GBCustomCalloutAnimationBounce,
    GBCustomCalloutAnimationFade,
} GBCustomCalloutAnimation;

@interface GBCustomCallout : UIView <UIGestureRecognizerDelegate>
{}
#pragma mark - Annotations
@property (nonatomic, weak) MKAnnotationView *annotationView;
@property (nonatomic, weak) MKMapView *mapView;

#pragma mark - Delegates and Decision makers
@property (nonatomic, weak) id<GBCustomCalloutViewDelegate> delegate;
@property (nonatomic, assign) GBCustomCalloutArrowDirection allowedArrowDirections;

#pragma mark - Subviews
// Custom title/subtitle views. if these are set, the respective title/subtitle properties will be ignored.
@property (nonatomic, strong) UIView *titleView, *subtitleView;
// Custom "content" view that can be any width/height. If this is set, title/subtitle/titleView/subtitleView are all ignored.
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *leftAccessoryView;
@property (nonatomic, strong) UIView *rightAccessoryView;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIView *bottomView;

#pragma mark - Callout Modifications
@property (nonatomic, assign) CGPoint offset;

@property (nonatomic, assign) CGSize maxSizeForLeftAccessory, maxSizeForRightAccessory, maxSizeForTitle, maxSizeForSubTitle;

// space between map border and callout (on automove)
@property (nonatomic, strong) NSNumber *horizontalMargin, *verticalMargin;
// space around the subviews
@property (nonatomic, strong) NSNumber *horizontalPadding, *verticalPadding;
// space inbetween the subviews
@property (nonatomic, strong) NSNumber *subviewHorizontalMargin, *subviewVerticalMargin;
// inset from which the arrow may appear under(/over) the callout
@property (nonatomic, strong) NSNumber *anchorMargin;

@property (nonatomic, assign) GBCustomCalloutAnimation presentAnimation, dismissAnimation; // default GBCalloutAnimationBounce, GBCalloutAnimationFade respectively

@property (nonatomic, strong) UIColor *activeBackgroundColor;

@property (nonatomic, assign) BOOL bubbleShape;

@property (nonatomic, assign) BOOL calloutTapTriggersRightAccessory;

#pragma mark - Class methods
+ (GBCustomCallout *)customCalloutWithDelegate:(id<GBCustomCalloutViewDelegate>)delegate;

#pragma mark - Instance Methods
- (void)presentCalloutForAnnotationView:(MKAnnotationView *)annotationView
                              inMapView:(MKMapView *)mapView;

- (void)             dismiss;

@end

#pragma mark - GBCustomCalloutDelegateProtocol
#pragma mark -
@protocol GBCustomCalloutViewDelegate <NSObject>

// Title and subtitle for use by selection UI.
- (NSString *)       title;
- (NSString *)       subtitle;

@optional

- (UIView *)         titleView;
- (UIView *)         subtitleView;
- (UIView *)         contentView;

- (UIView *)         leftAccessoryView;
- (UIView *)         rightAccessoryView;

- (UIView *)         topView;
- (UIView *)         bottomView;

- (UIView *)         headerView;
- (UIView *)         footerView;

- (UIView *)         backgroundView;

- (CGPoint)          calloutOffset;

- (BOOL)             shouldExpandToAccessoryHeight;
- (BOOL)             shouldExpandToAccessoryWidth;
- (BOOL)             shouldVerticallyCenterLeftAccessory;
- (BOOL)             shouldVerticallyCenterRightAccessory;
- (BOOL)             shouldConstrainLeftAccessoryToContent;
- (BOOL)             shouldConstrainRightAccessoryToContent;

@end


@protocol GBCustomCalloutConstrainingRectSupplier <NSObject>
@optional
- (CGRect)           rectToConstrainCallouts;
@end


#pragma mark - ***** Helper CLASSES ***** -
#pragma mark - *** GBCustomTitleLabel *** -
@interface GBCustomTitleLabel : UILabel
{}
@property (nonatomic, assign) CGSize maxSize;
@end;
#pragma mark - *** GBCustomSubtitleLabel *** -
@interface GBCustomSubtitleLabel : GBCustomTitleLabel
{}
@end;
#pragma mark - *** GBCustomContentView *** -
@interface GBCustomContentView : UIView
{}
@end;