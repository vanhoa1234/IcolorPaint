//
//  HouseTemplate.h
//  Decorator
//
//  Created by Le Hoang on 2/23/16.
//  Copyright © 2016 Hoang Le. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HouseTemplate : NSObject
@property (nonatomic, strong) NSString *roofCode;
@property (nonatomic, strong) NSString *wall1Code;
@property (nonatomic, strong) NSString *wall2Code;
@property (nonatomic, strong) NSString *pipeCode;

@property (nonatomic) int roofR;
@property (nonatomic) int roofG;
@property (nonatomic) int roofB;

@property (nonatomic) int wall1R;
@property (nonatomic) int wall1G;
@property (nonatomic) int wall1B;

@property (nonatomic) int wall2R;
@property (nonatomic) int wall2G;
@property (nonatomic) int wall2B;

@property (nonatomic) int pipeR;
@property (nonatomic) int pipeG;
@property (nonatomic) int pipeB;
@end
