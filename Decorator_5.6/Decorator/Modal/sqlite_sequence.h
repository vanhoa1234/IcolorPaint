//
//  sqlite_sequence.h
//  Decorator
//
//  Created by Hoang Le on 12/13/13.
//  Copyright (c) 2013 Hoang Le. All rights reserved.
//

#import "FCModel.h"

@interface sqlite_sequence : FCModel
@property (nonatomic, assign) int64_t seq;
@property (nonatomic, copy) NSString *name;
@end
