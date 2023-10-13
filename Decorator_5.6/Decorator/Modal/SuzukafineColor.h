//
//  SuzukafineColor.h
//  Decorator
//
//  Created by Le Hoang on 2/29/16.
//  Copyright © 2016 Hoang Le. All rights reserved.
//

#import "JSONModel.h"
#import "Suzukafine.h"

@protocol Suzukafine <NSObject>

@end

@interface SuzukafineColor : JSONModel
@property (strong, nonatomic) NSArray<Suzukafine> *Suzukafine;
@end
