//
//  JPMAColor.h
//  Decorator
//
//  Created by Le Hoang on 2/22/16.
//  Copyright © 2016 Hoang Le. All rights reserved.
//

#import "JSONModel.h"
#import "JPMA.h"

@protocol JPMA <NSObject>

@end

@interface JPMAColor : JSONModel
@property (strong, nonatomic) NSArray<JPMA> *JPMA;
@end
