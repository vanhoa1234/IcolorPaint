//
//  Suzukafine.h
//  Decorator
//
//  Created by Hoang Le on 10/14/13.
//  Copyright (c) 2013 Hoang Le. All rights reserved.
//

#import "FCModel.h"

@interface Suzukafine : FCModel
@property (nonatomic, assign) int64_t No;
@property (nonatomic, copy) NSString *ColorCode;
@property (nonatomic, assign) int64_t R;
@property (nonatomic, assign) int64_t G;
@property (nonatomic, assign) int64_t B;
@end
