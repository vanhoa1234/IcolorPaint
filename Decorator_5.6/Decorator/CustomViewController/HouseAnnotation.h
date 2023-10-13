//
//  HouseAnnotation.h
//  Decorator
//
//  Created by Hoang Le on 1/8/14.
//  Copyright (c) 2014 Hoang Le. All rights reserved.
//

#import "GBAnnotationView.h"

@interface HouseAnnotation : GBAnnotationView<GBCustomCalloutViewDelegate,UIGestureRecognizerDelegate>

@property (strong, nonatomic) GBCustomCallout *calloutView;
@property (nonatomic, strong) UIView *leftCalloutAccessoryView;

@property (nonatomic, strong) UIView *rightAccessoryView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIView *footerView;

- (BOOL)shouldExpandToAccessoryHeight;
- (BOOL)shouldExpandToAccessoryWidth;

- (BOOL)shouldVerticallyCenterLeftAccessory;
- (BOOL)shouldVerticallyCenterRightAccessory;

- (BOOL)shouldConstrainLeftAccessoryToContent;
- (BOOL)shouldConstrainRightAccessoryToContent;

- (CGPoint)calloutOffset;
@end
