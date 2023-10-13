//
//  LabList.h
//  Decorator
//
//  Created by Le Hoang on 2/26/20.
//  Copyright © 2020 Hoang Le. All rights reserved.
//

#import "FCModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol Lab <NSObject>
@end

@interface LabList : JSONModel
@property (strong, nonatomic) NSArray<Lab> *Lab;
@end

NS_ASSUME_NONNULL_END
