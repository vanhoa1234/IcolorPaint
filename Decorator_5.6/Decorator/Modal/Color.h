//
//  Color.h
//  Decorator
//
//  Created by Hoang Le on 9/20/13.
//  Copyright (c) 2013 Hoang Le. All rights reserved.
//

#import "FCModel.h"

@interface Color : FCModel
@property (nonatomic, assign) int64_t No;
@property (nonatomic, copy) NSString *ColorCode;
@property (nonatomic, assign) int64_t R;
@property (nonatomic, assign) int64_t G;
@property (nonatomic, assign) int64_t B;
@property (nonatomic, assign) int64_t R1;
@property (nonatomic, assign) int64_t G1;
@property (nonatomic, assign) int64_t B1;

@end
