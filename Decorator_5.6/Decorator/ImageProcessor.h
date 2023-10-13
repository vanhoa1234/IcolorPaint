//
//  ImageProcessor.h
//  Decorator
//
//  Created by Hoang Le on 9/17/13.
//  Copyright (c) 2013 Hoang Le. All rights reserved.
//
#import <opencv2/opencv.hpp>
#import <Foundation/Foundation.h>


@interface ImageProcessor : NSObject
+ (id)sharedManager;
@property (nonatomic) UIImageOrientation orientSrc;
@property (nonatomic, strong) NSMutableArray *jpmaColorList;
@property (nonatomic, strong) NSMutableArray *suzukaColorList;
- (void)getJPMAList;
- (void)getSuzukaList;
- (NSArray *)douglasPeucker:(NSArray *)points epsilon:(float)epsilon;
- (float)perpendicularDistance:(CGPoint)point lineA:(CGPoint)lineA lineB:(CGPoint)lineB;
- (NSMutableArray *)catmullRomSpline:(NSMutableArray *)points segments:(int)segments;

@end
