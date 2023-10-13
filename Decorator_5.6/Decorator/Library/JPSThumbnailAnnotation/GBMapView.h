//
//  GBMapView.h
//  MapCallouts
//
//  Created by Adam Barrett on 2013-09-05.
//
//

#import <MapKit/MapKit.h>
#import "GBAnnotationView.h"

@class GBMapView;

typedef void (^MapCallback)(GBMapView *mapView);
typedef void (^MapErrorCallback)(GBMapView *mapView, NSError *error);
typedef void (^AnnotationViewCallback)(GBMapView *mapView, MKAnnotationView *annotationView);
typedef void (^AnnotationViewsCallback)(GBMapView *mapView, NSArray *views);
typedef void (^AnnotationViewControlCallback)(GBMapView *mapView, MKAnnotationView *annotationView, UIControl *control);
typedef void (^RegionChangeCallback)(GBMapView *mapView, BOOL animated);
typedef void (^UserLocationCallback)(GBMapView *mapView, MKUserLocation *userLocation);

@interface GBMapView : MKMapView <MKMapViewDelegate>

@property (nonatomic, strong) MKAnnotationView *selectedAnnotationView;

#pragma mark - Block Callbacks (instead of delegate)
@property (nonatomic, copy) AnnotationViewCallback didSelectAnnotationsView;
@property (nonatomic, copy) AnnotationViewCallback didDeselectAnnotationsView;
@property (nonatomic, copy) AnnotationViewControlCallback calloutAccessoryControlTapped;

@property (nonatomic, copy) AnnotationViewsCallback didAddAnnotationViews;

@property (nonatomic, copy) RegionChangeCallback regionWillChange;
@property (nonatomic, copy) RegionChangeCallback regionDidChange;

@property (nonatomic, copy) UserLocationCallback didUpdateUserLocation;
@property (nonatomic, copy) MapErrorCallback didFailToLocateUser;

@property (nonatomic, copy) MapCallback willStartLoadingMap;
@property (nonatomic, copy) MapCallback didFinishLoadingMap;
@property (nonatomic, copy) MapErrorCallback didFailLoadingMap;

@property (nonatomic, assign) Class annotationViewClass;

- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
                  zoomLevel:(NSUInteger)zoomLevel
                   animated:(BOOL)animated;

@end