//
//  ExportUtil.m
//  Decorator
//
//  Created by Hoang Le on 5/21/14.
//  Copyright (c) 2014 Hoang Le. All rights reserved.
//

#import "ExportUtil.h"
#import "ZipArchive.h"
#import "SSZipArchive.h"
#import "ArchiveObject.h"
#import "Plan.h"
#import "Material.h"
#import "LayoutPosition.h"
@implementation ExportUtil
@synthesize delegate;

- (BOOL)importFromURL:(NSURL *)importURL {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSError *error = nil;
        if(!error)
        {
            NSString *timeDir = [NSString stringWithFormat:@"%d",(int)[[NSDate date] timeIntervalSince1970]];
            NSString *cachePath = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:timeDir];
            NSString *documentPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:timeDir];
            
            NSString *zipPath = [importURL.path stringByReplacingOccurrencesOfString:@"/private" withString:@""];
            if(!error)
            {
                ZipArchive *zip = [[ZipArchive alloc] init];
                [zip UnzipOpenFile:zipPath Password:@"abc123iColorpaint"];
                NSString *outputDir = [cachePath stringByAppendingPathComponent:[self generateRandomString]];
                NSFileManager* fm = [NSFileManager defaultManager];
                if (![fm createDirectoryAtPath:outputDir withIntermediateDirectories:YES attributes:nil error:nil]) {
                    return ;
                }
                [zip UnzipFileTo:outputDir overWrite:YES];
                [zip CloseZipFile2];
                [fm removeItemAtURL:importURL error:nil];
                NSDirectoryEnumerator* dirEnum = [fm enumeratorAtPath:outputDir];
                NSString* file;
                while ((file = [dirEnum nextObject])) {
                    NSError *error;
                    if (![fm createDirectoryAtPath:documentPath withIntermediateDirectories:YES attributes:nil error:nil]) {
                        return;
                    }
                    
                    if ([[file pathExtension] isEqualToString:@"json"]) {
                        [self saveJSONToDatabase:[outputDir stringByAppendingPathComponent:file] withDocument:documentPath andCache:cachePath];
                    }
                    else if ([file rangeOfString:@"masking_huan_"].location != NSNotFound){
                        [fm moveItemAtPath:[outputDir stringByAppendingPathComponent:file] toPath:[cachePath stringByAppendingPathComponent:file] error:&error];
                    }
                    else {
                        [fm moveItemAtPath:[outputDir stringByAppendingPathComponent:file] toPath:[documentPath stringByAppendingPathComponent:file] error:&error];
                    }
                    if (error) {
                        NSLog(@"ERROR %@",error);
                    }
                }
                [fm removeItemAtPath:outputDir error:nil];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [delegate importedMailData];
                });
            }
            else
            {
                [delegate importDataError:@"Saving file error"];
            }
        }
        else
        {
            [delegate importDataError:@"Saving file error"];
        }
    
    });
    return YES;
}

- (void)saveJSONToDatabase:(NSString *)jsonPath withDocument:(NSString *)documentDir andCache:(NSString *)cacheDir{
    NSError *error;
    ArchiveObject *archiveObj = [[ArchiveObject alloc] initWithData:[NSData dataWithContentsOfFile:jsonPath] error:&error];
    NSDictionary *jsonDictionary = [archiveObj toDictionary];
    if (!error) {
        House *house = [House new];
        house.houseName = archiveObj.houseObj.houseName;
        house.date = archiveObj.houseObj.date;
        house.applyPlan = archiveObj.houseObj.applyPlan;
        house.longitude = archiveObj.houseObj.longitude;
        house.latitude = archiveObj.houseObj.latitude;
        house.houseImage = [documentDir stringByAppendingPathComponent:[archiveObj.houseObj.houseImage lastPathComponent]];
        house.houseImageThumnail = [documentDir stringByAppendingPathComponent:[archiveObj.houseObj.houseImageThumnail lastPathComponent]];
        house.backgroundImg = archiveObj.houseObj.backgroundImg;
        [house save];
        __block int lasthouseID;
        [[FCModel databaseQueue] inDatabase:^(FMDatabase *db) {
            lasthouseID = (int)[db lastInsertRowId];
        }];
        NSMutableDictionary *planKeyPairs = [NSMutableDictionary dictionary];
        for (NSDictionary *dictionary in [jsonDictionary objectForKey:@"plans"]) {
            Plan *plan = [Plan new];
            plan.imageLink = [dictionary objectForKey:@"imageLink"];
            plan.planName = [dictionary objectForKey:@"planName"];
            plan.applyPlan = [[dictionary objectForKey:@"applyPlan"] intValue];
            plan.houseID = lasthouseID;
            plan.planIndex = [dictionary objectForKey:@"planIndex"];
            [plan save];
            __block int lastID;
            [[FCModel databaseQueue] inDatabase:^(FMDatabase *db) {
                lastID = (int)[db lastInsertRowId];
            }];
            [planKeyPairs setObject:[NSNumber numberWithInt:lastID] forKey:[dictionary objectForKey:@"planID"]];
        }
//        if ((archiveObj.isPhone && [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) || (!archiveObj.isPhone && [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)) {
//            for (NSDictionary *layoutDictionary in [jsonDictionary objectForKey:@"layoutPosition"]) {
//                LayoutPosition *position = [LayoutPosition new];
//                position.houseID = lasthouseID;
//                position.type = [[layoutDictionary objectForKey:@"type"] intValue];
//                position.xValue = [[layoutDictionary objectForKey:@"xValue"] floatValue];
//                position.yValue = [[layoutDictionary objectForKey:@"yValue"] floatValue];
//                position.width = [[layoutDictionary objectForKey:@"width"] floatValue];
//                position.height = [[layoutDictionary objectForKey:@"height"] floatValue];
//                [position save];
//            }
//        }
        
        for (NSDictionary *dictionary in [jsonDictionary objectForKey:@"materials"]) {
            Material *material = [Material new];
            material.planID = [[planKeyPairs objectForKey:[dictionary objectForKey:@"planID"]] intValue];
            material.type = [[dictionary objectForKey:@"type"] intValue];
            material.colorCode = [dictionary objectForKey:@"colorCode"];
            material.feature = [dictionary objectForKey:@"feature"];
            material.gloss = [dictionary objectForKey:@"gloss"];
            material.pattern = [dictionary objectForKey:@"pattern"];
            material.isSelected = [[dictionary objectForKey:@"isSelected"] boolValue];
            material.imageLink = [dictionary objectForKey:@"imageLink"];
            material.patternImage = [dictionary objectForKey:@"patternImage"];
            material.R1 = [[dictionary objectForKey:@"R1"] intValue];
            material.G1 = [[dictionary objectForKey:@"G1"] intValue];
            material.B1 = [[dictionary objectForKey:@"B1"] intValue];
            material.No = [[dictionary objectForKey:@"No"] intValue];
            material.imageLink = [cacheDir stringByAppendingPathComponent:[material.imageLink lastPathComponent]];
            [material save];
        }
    }
    else
        NSLog(@"Error %@",error);
}

-(NSString*)generateRandomString {
    NSMutableString* string = [NSMutableString stringWithCapacity:15];
    for (int i = 0; i < 10; i++) {
        [string appendFormat:@"%C", (unichar)('a' + arc4random_uniform(25))];
    }
    return string;
}
@end
