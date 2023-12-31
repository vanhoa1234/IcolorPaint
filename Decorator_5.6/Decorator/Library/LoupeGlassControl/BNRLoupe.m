//
//  BNRLoupe.m
//  LoupeDemo
//
//  Created by Owen Mathews on 12/12/12.
//  Copyright (c) 2012 Big Nerd Ranch, LLC. All rights reserved.
//

/*
 Copyright (c) 2012, Big Nerd Ranch, LLC
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions
    are met:
 
 Redistributions of source code must retain the above copyright notice,
    this list of conditions and the following disclaimer.
 Redistributions in binary form must reproduce the above copyright  
    notice, this list of conditions and the following disclaimer in the
    documentation and/or other materials provided with the distribution.
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
    IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT   
    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
    COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
    BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
    CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
    LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
    ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
    POSSIBILITY OF SUCH DAMAGE.
*/

#import "BNRLoupe.h"
#import <QuartzCore/QuartzCore.h>

typedef enum {
    Horizontal = 0,
    Vertical
} LoupeConstraintDirection;

typedef enum {
    Greater = 0,
    Less
} LoupeConstraintSense;

typedef LoupeConstraintSense LoupeBias;

typedef struct  {
    CGFloat value;
    LoupeConstraintDirection direction;
    LoupeConstraintSense sense;
} LoupeConstraint;

#define kBNRLoupeAnimationTimeThreshold 0.05
#define kBNRLoupeAnimationDistanceThreshold 2
#define kBNRLoupeAnimationDuration 0.3

#define kBNRLoupeConstraintAnimationDivisor 1000

#define kBNRLoupeAppearanceAnimationDuration 0.16

@interface BNRLoupe () {
    CGPoint _position;
    CGFloat _diameter;
    CGFloat _edgeClearance;
    
    CGFloat _offsetAngle;
    CGFloat _offsetDiagonal;
    CGPoint _offset;
    
    LoupeConstraint constraints[2];
    
    CALayer *_overlayLayer;
    
    BOOL _shouldAnimateAppearance;
    BOOL _appearanceAnimationInProgress;
    CGPoint _savedOriginPoint;
    
    CGPoint _previousScreenPoint;
    NSTimeInterval _lastUpdate;
    
    CAShapeLayer *horizontalLine;
    CAShapeLayer *verticalLine;
}

@property (nonatomic, strong) CALayer *contentLayer;

- (void)setContentsCenter:(CGPoint)point shouldAnimate:(BOOL)shouldAnimate;

- (BOOL)constrainOffsetFromOriginPoint:(CGPoint)originPoint;

- (void)updateConstraints;

@end

@implementation BNRLoupe

@synthesize offset=_offsetDiagonal;

- (id)initWithDiameter:(CGFloat)diameter offset:(CGFloat)offset offsetAngle:(CGFloat)angle constraintsRect:(CGRect)rect edgeClearance:(CGFloat)clearance {
    self = [super init];
    if (self) {
        _diameter = diameter;
        _offsetDiagonal = offset;
        _constraintsRect = rect;
        [self setOffsetAngle:angle];
        _edgeClearance = clearance;
        
        _contentLayer = [[CALayer alloc] init];
        _contentLayer.bounds = CGRectMake(0, 0, _diameter, _diameter);
        _contentLayer.cornerRadius = _diameter / 2;
        _contentLayer.shadowOpacity = 0.4;
        _contentLayer.masksToBounds = YES;
        
        _overlayLayer = [[CALayer alloc] init];
        _overlayLayer.bounds = CGRectMake(0, 0, _diameter, _diameter);
//        _overlayLayer.contents = (__bridge id) [[UIImage imageNamed:@"loupeGlass"] CGImage];
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(_diameter/2, 0)];
        [path addLineToPoint:CGPointMake(_diameter/2, _diameter)];
        
        verticalLine = [[CAShapeLayer alloc] initWithLayer:_contentLayer];
        verticalLine.lineWidth = 1;
        verticalLine.strokeColor = [UIColor redColor].CGColor;
        [verticalLine setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:30],[NSNumber numberWithInt:30], nil]];
        verticalLine.lineDashPhase = 2.0f;
        verticalLine.path = path.CGPath;
        [_contentLayer addSublayer:verticalLine];
        
        [path removeAllPoints];
        [path moveToPoint:CGPointMake(0, _diameter/2)];
        [path addLineToPoint:CGPointMake(_diameter, _diameter/2)];
        horizontalLine = [[CAShapeLayer alloc] initWithLayer:_contentLayer];
        horizontalLine.lineWidth = 1;
        horizontalLine.strokeColor = [UIColor redColor].CGColor;
        [horizontalLine setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:30],[NSNumber numberWithInt:30], nil]];
        horizontalLine.lineDashPhase = 2.0f;
        horizontalLine.path = path.CGPath;
        [_contentLayer addSublayer:horizontalLine];
    }
    return self;
}

- (void)drawTarget{
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(_diameter/2, 0)];
    [path addLineToPoint:CGPointMake(_diameter/2, _diameter)];
    
    [verticalLine setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:10],[NSNumber numberWithInt:10], nil]];
    verticalLine.lineDashPhase = 2.0f;
    verticalLine.path = path.CGPath;
    
    [path removeAllPoints];
    [path moveToPoint:CGPointMake(0, _diameter/2)];
    [path addLineToPoint:CGPointMake(_diameter, _diameter/2)];
    horizontalLine.path = path.CGPath;
}

- (void)drawCirclePoint{
    
}

- (void)setConstraintsRect:(CGRect)constraintsRect {
    _constraintsRect = constraintsRect;
    [self updateConstraints];
}

- (void)updateConstraints {
    constraints[Horizontal].direction = Horizontal;
    constraints[Vertical].direction = Vertical;
    if (_offset.x < 0) {
        constraints[Horizontal].value = _constraintsRect.origin.x;
        constraints[Horizontal].sense = Greater;
    } else {
        constraints[Horizontal].value = _constraintsRect.origin.x + _constraintsRect.size.width;
        constraints[Horizontal].sense = Less;
    }
    if (_offset.y < 0) {
        constraints[Vertical].value = _constraintsRect.origin.y;
        constraints[Vertical].sense = Greater;
    } else {
        constraints[Vertical].value = _constraintsRect.origin.y + _constraintsRect.size.height;
        constraints[Vertical].sense = Less;
    }
}

// Setting the offset angle as it should appear onscreen relative to the touch point.
- (void)setOffsetAngle:(CGFloat)offsetAngle {
    _offsetAngle = offsetAngle;
    _offset.x = cos(_offsetAngle) * _offsetDiagonal;
    _offset.y = -sin(_offsetAngle) * _offsetDiagonal;
    [self updateConstraints];
}

- (void)displayInView:(UIView *)view {
    [view.layer addSublayer:_contentLayer];
    [view.layer addSublayer:_overlayLayer];
    _shouldAnimateAppearance = YES;
}

- (void)animateAppearanceFromOriginPoint:(CGPoint)originPoint {
    _shouldAnimateAppearance = NO;
    _appearanceAnimationInProgress = YES;
    _contentLayer.position = _position;
    _overlayLayer.position = _position;
    
    [CATransaction begin];
    {
        [CATransaction setAnimationDuration:kBNRLoupeAppearanceAnimationDuration];
        [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
        
        // Position animation
        CABasicAnimation *contentPosition = [CABasicAnimation animationWithKeyPath:@"position"];
        contentPosition.fromValue = [NSValue valueWithCGPoint:originPoint];
        contentPosition.toValue = [NSValue valueWithCGPoint:_position];
        CABasicAnimation *overlayPosition = [CABasicAnimation animationWithKeyPath:@"position"];
        overlayPosition.fromValue = [NSValue valueWithCGPoint:originPoint];
        overlayPosition.toValue = [NSValue valueWithCGPoint:_position];
        
        // Scale animation
        CABasicAnimation *contentScale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        contentScale.fromValue = @(0);
        contentScale.toValue = @(1);
        CABasicAnimation *overlayScale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        overlayScale.fromValue = @(0);
        overlayScale.toValue = @(1);
        
        // Watch one (any will do) so we can react to the animations completing
        [contentPosition setDelegate:self];
        
        // Apply them
        [_contentLayer addAnimation:contentPosition forKey:@"appearance animation"];
        [_contentLayer addAnimation:contentScale forKey:nil];
        [_overlayLayer addAnimation:overlayPosition forKey:nil];
        [_overlayLayer addAnimation:overlayScale forKey:nil];
    }
    [CATransaction commit];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    _appearanceAnimationInProgress = NO;
}

- (void)removeFromView {
    _lastUpdate = 0;
    _previousScreenPoint = CGPointMake(-CGFLOAT_MAX, -CGFLOAT_MAX);
    [_contentLayer removeFromSuperlayer];
    [_overlayLayer removeFromSuperlayer];
}

- (void)setImage:(UIImage *)image {
    _image = image;
    _contentLayer.contents = (__bridge id) [_image CGImage];
}

- (void)setContentsCenter:(CGPoint)point shouldAnimate:(BOOL)shouldAnimate {
    // Calculate the contents rect. The rect is always given relative to
    // a coordinate system that goes from (0, 0) to (1, 1).
    CGFloat loupeDiameterWidthScaled = _diameter / _image.size.width;
    CGFloat loupeDiameterHeightScaled = _diameter / _image.size.height;
    CGFloat loupePositionXScaled = (point.x / _image.size.width) - loupeDiameterWidthScaled / 2;
    CGFloat loupePositionYScaled = (point.y / _image.size.height) - loupeDiameterHeightScaled / 2;
    CGRect loupeRect = CGRectMake(loupePositionXScaled, loupePositionYScaled, loupeDiameterWidthScaled, loupeDiameterHeightScaled);
    
    [CATransaction begin];
    {
        if (shouldAnimate)
            [CATransaction setAnimationDuration:kBNRLoupeAnimationDuration];
        else
            [CATransaction setDisableActions:YES];
        _contentLayer.contentsRect = loupeRect;
    }
    [CATransaction commit];
}

- (void)setScreenPoint:(CGPoint)point {
    @try {
        // Determine if we've moved a small enough distance to warrant animating
        NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
        CGFloat distanceTraveled = hypot(point.x - _previousScreenPoint.x, point.y - _previousScreenPoint.y);
        BOOL animate = NO;
        if (now - _lastUpdate >= kBNRLoupeAnimationTimeThreshold && distanceTraveled <= kBNRLoupeAnimationDistanceThreshold)
            animate = YES;
        
        // Find the point in the image and update loupe contents
        CGPoint imagePoint = CGPointApplyAffineTransform(point, self.screenToImageTransform);
        imagePoint.x = round(imagePoint.x);
        imagePoint.y = round(imagePoint.y);
        [self setContentsCenter:imagePoint shouldAnimate:animate];
        
        // Don't bother setting position if we're animating in.
        //--TODO: maybe adjust target of animation?
        if (_appearanceAnimationInProgress)
            return;
        
        // Calculate position of loupe
        _position.x = point.x + _offset.x;
        _position.y = point.y + _offset.y;
        CGPoint unconstrainedPosition = _position;
        BOOL constraintsBroken = [self constrainOffsetFromOriginPoint:point];
        CGFloat constraintDelta = 0;
        if (constraintsBroken)
            constraintDelta = hypot(unconstrainedPosition.x - _position.x, unconstrainedPosition.y - _position.y);
        
        if (_shouldAnimateAppearance) {
            // Flag was set by displayInView:
            [self animateAppearanceFromOriginPoint:point];
        } else {
            [CATransaction begin];
            {
                if (constraintsBroken || animate)
                    [CATransaction setDisableActions:NO];
                else
                    [CATransaction setDisableActions:YES];
                if (constraintDelta > 0)
                    [CATransaction setAnimationDuration:constraintDelta / kBNRLoupeConstraintAnimationDivisor];
                else if (animate)
                    [CATransaction setAnimationDuration:kBNRLoupeAnimationDuration];
                _contentLayer.position = _position;
                _overlayLayer.position = _position;
            }
            [CATransaction commit];
        }
        
        _lastUpdate = now;
        _previousScreenPoint = point;
    }
    @catch (NSException *exception) {
        [CATransaction commit];
        [_contentLayer removeAllAnimations];
        [_overlayLayer removeAllAnimations];
        [self removeFromView];
    }
    @finally {
        
    }
}

- (BOOL)constrainOffsetFromOriginPoint:(CGPoint)originPoint {
    BOOL constraintsBroken = NO;
    if ([self breaksConstrant:constraints[Vertical]]) {
        constraintsBroken = YES;
        _position = [self pointByObservingConstraint:constraints[Vertical] withOriginPoint:originPoint bias:Less]; // Shift to left
        if ([self breaksConstrant:constraints[Horizontal]])
            _position = [self pointByObservingConstraint:constraints[Horizontal] withOriginPoint:originPoint bias:Greater]; // Shift down
    } else if ([self breaksConstrant:constraints[Horizontal]]) {
        constraintsBroken = YES;
        _position = [self pointByObservingConstraint:constraints[Horizontal] withOriginPoint:originPoint bias:Less]; // Shift up
        if ([self breaksConstrant:constraints[Vertical]])
            _position = [self pointByObservingConstraint:constraints[Vertical] withOriginPoint:originPoint bias:Greater]; // Shift right
    }
    return constraintsBroken;
}

- (BOOL)breaksConstrant:(LoupeConstraint)constraint {
    if (constraint.direction == Horizontal) {
        if (constraint.sense == Greater) {
            if (constraint.value + _diameter / 2 + _edgeClearance > _position.x)
                return YES;
        } else {
            if (constraint.value - _diameter / 2 - _edgeClearance < _position.x)
                return YES;
        }
    } else {
        if (constraint.sense == Greater) {
            if (constraint.value + _diameter / 2 + _edgeClearance > _position.y)
                return YES;
        } else {
            if (constraint.value - _diameter / 2 - _edgeClearance < _position.y)
                return YES;
        }
    }
    return NO;
}

- (CGPoint)pointByObservingConstraint:(LoupeConstraint)c withOriginPoint:(CGPoint)originPoint bias:(LoupeConstraintSense)bias {
    CGPoint newPoint;
    
    CGFloat origPrim = (c.direction == Horizontal)? originPoint.x : originPoint.y;
    CGFloat origSec = (c.direction == Horizontal)? originPoint.y : originPoint.x;
    CGFloat *newPrim = (c.direction == Horizontal)? &(newPoint.x) : &(newPoint.y);
    CGFloat *newSec = (c.direction == Horizontal)? &(newPoint.y) : &(newPoint.x);
    
    CGPoint deltaFromOrigin;
    CGFloat *deltaPrim = (c.direction == Horizontal)? &(deltaFromOrigin.x) : &(deltaFromOrigin.y);
    CGFloat *deltaSec = (c.direction == Horizontal)? &(deltaFromOrigin.y) : &(deltaFromOrigin.x);
    
    *newPrim = (c.sense == Greater)? (c.value + _edgeClearance + _diameter / 2) : (c.value - (_edgeClearance + _diameter / 2));
    *deltaPrim = (c.sense == Greater)? *newPrim - origPrim : origPrim - *newPrim;
    
    *deltaSec = sqrt((_offsetDiagonal * _offsetDiagonal) - ((*deltaPrim) * (*deltaPrim)));
    if (bias == Less)
        *deltaSec = -(*deltaSec);
    
    *newSec = origSec + *deltaSec;
    
    return newPoint;
}

@end
