//
//  GBAnnotation.h
//  GBAnnotationViewDemo
//
//  Created by Adam Barrett on 2013-09-26.
//  Copyright (c) 2013 GB Internet Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

typedef enum {
    GBAnnotationTypeDefault,
    GBAnnotationTypeBridge,
    GBAnnotationTypeCity,
    GBAnnotationTypeMuseum,
} GBAnnotationType;

@interface GBAnnotation : NSObject <MKAnnotation>

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, copy) NSString *imagePath;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@property (nonatomic, assign) GBAnnotationType type;

@end
