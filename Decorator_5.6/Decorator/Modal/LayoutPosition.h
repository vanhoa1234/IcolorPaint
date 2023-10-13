//
//  LayoutPosition.h
//  Decorator
//
//  Created by Hoang Le on 8/12/14.
//  Copyright (c) 2014 Hoang Le. All rights reserved.
//

#import "FCModel.h"

@protocol LayoutPosition
@end

@interface LayoutPosition : FCModel
@property (nonatomic) int64_t layoutIndex;
@property (nonatomic) int64_t houseID;
@property (nonatomic) int64_t type;
@property (nonatomic) float xValue;
@property (nonatomic) float yValue;
@property (nonatomic) float width;
@property (nonatomic) float height;
@end
