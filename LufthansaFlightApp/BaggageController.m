//
//  BaggageController.m
//  LufthansaFlightApp
//
//  Created by Akshit Malhotra on 11/8/14.
//  Copyright (c) 2014 Hackathon. All rights reserved.
//

#import "BaggageController.h"
#import "CrumbPath.h"
#import "CrumbPathView.h"

@interface BaggageController ()

@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic, strong) CrumbPath *crumbs;
@property (nonatomic, strong) CrumbPathView *crumbView;
@property (weak, nonatomic) IBOutlet MKMapView *map;

@end

@implementation BaggageController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self; // Tells the location manager to send updates to this object

    
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    

    [self.locationManager requestWhenInUseAuthorization];
    
    [self.map setUserTrackingMode:MKUserTrackingModeFollowWithHeading animated:NO];
    
    
    [self.locationManager startUpdatingLocation];

    
}

-(void)viewDidDisappear:(BOOL)animated
{
    self.locationManager.delegate = nil;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mapview

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    if (newLocation)
    {
        
        // make sure the old and new coordinates are different
        if ((oldLocation.coordinate.latitude != newLocation.coordinate.latitude) &&
            (oldLocation.coordinate.longitude != newLocation.coordinate.longitude))
        {
            if (!self.crumbs)
            {
                // This is the first time we're getting a location update, so create
                // the CrumbPath and add it to the map.
                //
                _crumbs = [[CrumbPath alloc] initWithCenterCoordinate:newLocation.coordinate];
                [self.map addOverlay:self.crumbs];
                
                
                
                MKCoordinateRegion newRegion;
                newRegion.center.latitude = 39.278112;
                newRegion.center.longitude = -76.622772;
                newRegion.span.latitudeDelta = 0.008388;
                newRegion.span.longitudeDelta = 0.016243;
                
                [self.map setRegion:newRegion animated:YES];
                
                // On the first location update only, zoom map to user location
               // MKCoordinateRegion region =
                //MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 2000, 2000);
                //[self.map setRegion:region animated:YES];
            }
            else
            {
                // This is a subsequent location update.
                // If the crumbs MKOverlay model object determines that the current location has moved
                // far enough from the previous location, use the returned updateRect to redraw just
                // the changed area.
                //
                // note: iPhone 3G will locate you using the triangulation of the cell towers.
                // so you may experience spikes in location data (in small time intervals)
                // due to 3G tower triangulation.
                
                
                MKMapRect updateRect = [self.crumbs addCoordinate:newLocation.coordinate];
                
                if (!MKMapRectIsNull(updateRect))
                {
                    // There is a non null update rect.
                    // Compute the currently visible map zoom scale
                    MKZoomScale currentZoomScale = (CGFloat)(self.map.bounds.size.width / self.map.visibleMapRect.size.width);
                    // Find out the line width at this zoom scale and outset the updateRect by that amount
                    CGFloat lineWidth = MKRoadWidthAtZoomScale(currentZoomScale);
                    updateRect = MKMapRectInset(updateRect, -lineWidth, -lineWidth);
                    // Ask the overlay view to update just the changed area.
                    [self.crumbView setNeedsDisplayInMapRect:updateRect];
                }
            }
        }
    }
}


- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    if (!self.crumbView)
    {
        _crumbView = [[CrumbPathView alloc] initWithOverlay:overlay];
    }
    return self.crumbView;
}



@end
