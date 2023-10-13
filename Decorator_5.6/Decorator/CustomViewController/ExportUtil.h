//
//  ExportUtil.h
//  Decorator
//
//  Created by Hoang Le on 5/21/14.
//  Copyright (c) 2014 Hoang Le. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ExportUtilDelegate <NSObject>
@optional
- (void)importedMailData;
- (void)importDataError:(NSString *)errorMessage;
@end

@interface ExportUtil : NSObject
- (BOOL)importFromURL:(NSURL *)importURL;
@property (nonatomic, assign) id<ExportUtilDelegate> delegate;
@end
