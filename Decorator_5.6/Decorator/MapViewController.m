//
//  MapViewController.m
//  Decorator
//
//  Created by Hoang Le on 1/8/14.
//  Copyright (c) 2014 Hoang Le. All rights reserved.
//

#import "MapViewController.h"
#import "HouseAnnotation.h"

@interface MapViewController (){
    NSArray *houses;
}
@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation MapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithHouses:(NSArray *)_houses{
    if ((self = [super init])) {
        houses = [[NSArray alloc] initWithArray:_houses];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mapView.showsUserLocation = YES;
    if ([CLLocationManager locationServicesEnabled]) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = (id)self;
        _locationManager.distanceFilter = 100;
        _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        [_locationManager startUpdatingLocation];
    }
    
    self.mapView.annotationViewClass = [HouseAnnotation class];
    self.mapView.calloutAccessoryControlTapped = ^(GBMapView *mapView, MKAnnotationView *annotationView, UIControl *control) {
        
    };
    
    for (House *house in houses) {
        if (house.latitude != 0 || house.longitude != 0) {
            CLLocationCoordinate2D location = {house.latitude,house.longitude};
            GBAnnotation *annotation = [GBAnnotation new];
            annotation.title = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"house_name", nil),house.houseName];
            annotation.subtitle = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"create_at", nil),house.date];
            annotation.imagePath = house.houseImage;
            annotation.coordinate = location;
            annotation.type = GBAnnotationTypeDefault;
            [self.mapView addAnnotation:annotation];
//            JPSThumbnail *empire = [[JPSThumbnail alloc] init];
//            empire.image = [UIImage imageWithContentsOfFile:house.houseImage];
//            empire.title = [NSString stringWithFormat:@"物件名: %@",house.houseName];
//            empire.subtitle = [NSString stringWithFormat:@"作成日: %@",house.date];
//            empire.coordinate = location;
//            [self.mapView addAnnotation:[[JPSThumbnailAnnotation alloc] initWithThumbnail:empire]];
        }
    }
    House *lastHouse = [houses lastObject];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:lastHouse.latitude longitude:lastHouse.longitude];
    double miles = 2.0;
    double scalingFactor = ABS(cos(2 * M_PI * location.coordinate.latitude / 360.0));
    MKCoordinateSpan span;
    span.latitudeDelta = miles/69.0;
    span.longitudeDelta = miles/(scalingFactor * 69.0);
    MKCoordinateRegion region;
    region.span = span;
    region.center = location.coordinate;
    [_mapView setRegion:region animated:YES];
    
    [_mapView selectAnnotation:[_mapView.annotations lastObject] animated:YES];
}

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation{
//    double miles = 2.0;
//    double scalingFactor = ABS(cos(2 * M_PI * newLocation.coordinate.latitude / 360.0));
//    MKCoordinateSpan span;
//    span.latitudeDelta = miles/69.0;
//    span.longitudeDelta = miles/(scalingFactor * 69.0);
//    MKCoordinateRegion region;
//    region.span = span;
//    region.center = newLocation.coordinate;
//    [_mapView setRegion:region animated:YES];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)exitMapView:(id)sender {
//    [self.navigationController popViewControllerWithFlipStyle:MPFlipStyleDirectionBackward];
    [self.navigationController fadePopViewController];
}
#pragma mark - MKMapViewDelegate
- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView{
//    [_mapView showAnnotations:_mapView.annotations animated:YES];
}
//- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
//    if ([view conformsToProtocol:@protocol(JPSThumbnailAnnotationViewProtocol)]) {
//        [((NSObject<JPSThumbnailAnnotationViewProtocol> *)view) didSelectAnnotationViewInMap:mapView];
//    }
//}
//
//- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
//    if ([view conformsToProtocol:@protocol(JPSThumbnailAnnotationViewProtocol)]) {
//        [((NSObject<JPSThumbnailAnnotationViewProtocol> *)view) didDeselectAnnotationViewInMap:mapView];
//    }
//}
//
//- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
//    
//    if ([annotation conformsToProtocol:@protocol(JPSThumbnailAnnotationProtocol)]) {
//        return [((NSObject<JPSThumbnailAnnotationProtocol> *)annotation) annotationViewInMap:mapView];
//    }
//    return nil;
//}
@end
