//
//  HouseAnnotation.m
//  Decorator
//
//  Created by Hoang Le on 1/8/14.
//  Copyright (c) 2014 Hoang Le. All rights reserved.
//

#import "HouseAnnotation.h"
#import "GBAnnotation.h"
//#import "GBRelatedInformationView.h"
#import <QuartzCore/QuartzCore.h>
static UIView *_expandingView;

@interface HouseAnnotation ()
@property (nonatomic, readonly) UIImage *standardPinImage;
@end

@implementation HouseAnnotation
@dynamic standardPinImage;

@synthesize leftCalloutAccessoryView = _leftCalloutAccessoryView;
@synthesize calloutView = _calloutView;

#pragma mark - Annotation on Map
- (UIImage *)imageForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[GBAnnotation class]]) {
        GBAnnotation *anno = annotation;
        
        if (anno.type == GBAnnotationTypeBridge) {
            return [self iconImageNamed:@"Bridge"];
        }
        
        if (anno.type == GBAnnotationTypeCity) {
            return [self iconImageNamed:@"City"];
        }
        
        if (anno.type == GBAnnotationTypeMuseum) {
            return [self iconImageNamed:@"Museum"];
        }
    }
    
    return [self standardPinImage];
}


- (UIImage *)iconImageNamed:(NSString *)name
{
    return [self imageWithImage:[UIImage imageNamed:name] scaledToSize:CGSizeMake(80.0, 80.0)];
}


#pragma mark - Annotation Callout Bubble
- (GBCustomCallout *)calloutView
{
    if (!_calloutView) {
        _calloutView = [GBCustomCallout new];
        _calloutView.delegate = self;
        _calloutView.verticalPadding = @10;
        _calloutView.maxSizeForLeftAccessory = CGSizeMake(30, 30);
        
        _calloutView.maxSizeForTitle = CGSizeMake(180, MAXFLOAT);
        _calloutView.maxSizeForSubTitle = CGSizeMake(150, MAXFLOAT);
    }
    
    return _calloutView;
}

#pragma mark leftCalloutAccessory
//- (UIView *)leftCalloutAccessoryView
//{
//    if (!_leftCalloutAccessoryView) {
//        GBAnnotation *annotation = self.annotation;
//        UIImage *image = [self imageWithImage:[UIImage imageWithContentsOfFile:annotation.imagePath] scaledToSize:CGSizeMake(180.0, 120.0)];
//        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
//        imageView.clipsToBounds = YES;
//        _leftCalloutAccessoryView = imageView;
//    }
//    return _leftCalloutAccessoryView;
//}


#pragma mark bottomView
//- (UIView *)bottomView
//{
//    if (!_bottomView) {
//        GBRelatedInformationView *bottomView = [[GBRelatedInformationView alloc] initWithFrame:CGRectMake(0, 0, 160, 25)];
//        bottomView.subject = self.annotation.title;
//        bottomView.clipsToBounds = YES;
//        _bottomView = bottomView;
//    }
//    return _bottomView;
//}

//
//- (UIView *)bottomView
//{
//    if (!_bottomView) {
//        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, 40)];
//        _bottomView.backgroundColor = [UIColor blueColor];
//        UIGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bottomViewTapped:)];
//        [_bottomView addGestureRecognizer:tap];
//    }
//    return _bottomView;
//}
//
//- (UIView *)bottomView
//{
//    if (!_expandingView) {
//        _expandingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, 40)];
//        _expandingView.backgroundColor = [UIColor blueColor];
//        UIGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bottomViewTapped:)];
//        tap.delegate = self;
//        [_expandingView addGestureRecognizer:tap];
//    }
//    return _expandingView;
//}

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
//{
//    return NO;
//}

//- (void)bottomViewTapped:(UIGestureRecognizer *)gestureRecognizer
//{
//    UIView *view = gestureRecognizer.view;
//    CGRect f = view.frame;
//    
//    int r = arc4random() % 50;
//    int spread = (f.size.height == 20) ? 0 : 25;
//    f.size = CGSizeMake(f.size.width, MAX(20, f.size.height + (r-spread)));
//    
//    view.frame = f;
//}
//
- (UIView *)contentView
{
    if (!_contentView) {
        GBAnnotation *annotation = self.annotation;
        UIImage *original = [UIImage imageWithContentsOfFile:annotation.imagePath];
        CGSize photoSize;
        if (original.size.width > original.size.height) {
            photoSize = CGSizeMake(200, 200 * original.size.height/original.size.width);
        }
        else
            photoSize = CGSizeMake(200 * original.size.width/original.size.height, 200);
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, photoSize.width, photoSize.height)];
        _contentView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];
        
        UIImage *image = [self imageWithImage:original scaledToSize:CGSizeMake(photoSize.width, photoSize.height)];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.layer.cornerRadius = 6.0f;
        imageView.clipsToBounds = YES;
        _contentView = imageView;
    }
    return _contentView;
}
//
//- (UIView *)rightAccessoryView
//{
//    if (!_rightAccessoryView) {
//        _rightAccessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 10)];
//        _rightAccessoryView.backgroundColor = [UIColor redColor];
//    }
//    return _rightAccessoryView;
//}
//
//- (UIView *)leftCalloutAccessoryView
//{
//    if (!_leftCalloutAccessoryView) {
//        _leftCalloutAccessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 10)];
//        _leftCalloutAccessoryView.backgroundColor = [UIColor orangeColor];
//    }
//    return _leftCalloutAccessoryView;
//}
//
//- (UIView *)topView
//{
//    if (!_topView) {
//        _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 10)];
//        _topView.backgroundColor = [UIColor redColor];
//    }
//    return _topView;
//}
//
//
//- (UIView *)headerView
//{
//    if (!_headerView) {
//        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 190, 10)];
//        _headerView.backgroundColor = [UIColor colorWithRed:0.0 green:0.7 blue:0.0 alpha:1.0];
//    }
//    return _headerView;
//}
//
//
//- (UIView *)footerView
//{
//    if (!_footerView) {
//        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 190, 10)];
//        _footerView.backgroundColor = [UIColor yellowColor];
//    }
//    return _footerView;
//}


#pragma mark Callout Delegate Modifications
- (CGPoint)calloutOffset
{
    return CGPointMake(-8, 0);
}


- (BOOL)shouldConstrainLeftAccessoryToContent
{
    // return self.bottomView ? YES : NO;
    return NO;
}

- (BOOL)shouldConstrainRightAccessoryToContent
{
    return NO;
}

- (BOOL)shouldVerticallyCenterLeftAccessory
{
    return YES;
}

- (BOOL)shouldVerticallyCenterRightAccessory
{
    return YES;
}

- (BOOL)shouldExpandToAccessoryHeight
{
    return NO;
}

- (BOOL)shouldExpandToAccessoryWidth
{
    return NO;
}

#pragma mark - Utility
- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext(newSize);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
