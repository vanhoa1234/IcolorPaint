//
//  MapViewController.h
//  Decorator
//
//  Created by Hoang Le on 1/8/14.
//  Copyright (c) 2014 Hoang Le. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "GBMapView.h"
#import "GBAnnotation.h"

@interface MapViewController : UIViewController
- (IBAction)exitMapView:(id)sender;
@property (weak, nonatomic) IBOutlet GBMapView *mapView;
- (id)initWithHouses:(NSArray *)_houses;
@end
