//
//  ViewController.m
//  Geofencing
//
//  Created by Brian Lee on 2/24/15.
//  Copyright (c) 2015 Brian Lee. All rights reserved.
//

#import "ViewController.h"

//import necessary framework header files
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>


//To receive updates from the location manager, class is required to conform to CLLocationManagerDelegate protocol
@interface ViewController ()<CLLocationManagerDelegate> {
    BOOL _didStartMonitoringRegion;
    
}

//Reference to the location manager
@property (strong, nonatomic) CLLocationManager *locationManager;

//Mutable array used to store the geofences
@property (strong, nonatomic) NSMutableArray *geofences;

@end

@implementation ViewController

@synthesize locationManager, geofences;
static NSString *GeofenceCellIdentifier = @"GeofenceCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
    
}

- (void) viewDidUnload {
    [geofences removeAllObjects];
}

- (void)setupView {
    // Create Add Button
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addCurrentLocation:)];
    
    // Create Edit Button
    self.navigationItem.rightBarButtonItem  = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Edit", nil) style:UIBarButtonItemStylePlain target:self action:@selector(editTableView:)];
}

//awakeFromNib is called when everything from the .nib is loaded and ready
- (void)awakeFromNib {
    [super awakeFromNib];
    
    // Initialize Location Manager
    self.locationManager = [[CLLocationManager alloc] init];
    
    // Configure Location Manager
    [self.locationManager setDelegate:self];
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
    
    // Load Geofences
    self.geofences = [NSMutableArray arrayWithArray:[[self.locationManager monitoredRegions] allObjects]];
//    self.locationManager = [[CLLocationManager alloc] init];
//    self.locationManager.delegate = self;
    // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addCurrentLocation:(id)sender {
    // Update Helper
    _didStartMonitoringRegion = NO;
    
    // Start Updating Location
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
    {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    NSLog(@"FDASFD");
    //if (locations && [locations count] && !_didStartMonitoringRegion) {
        // Update Helper
        //_didStartMonitoringRegion = YES;
        
        // Fetch Current Location
        CLLocation *location = [locations objectAtIndex:0];
        
        // Initialize Region to Monitor
        CLRegion *region = [[CLRegion alloc] initCircularRegionWithCenter:[location coordinate] radius:250.0 identifier:[[NSUUID UUID] UUIDString]];
        
        // Start Monitoring Region
        [self.locationManager startMonitoringForRegion:region];
        [self.locationManager stopUpdatingLocation];
        NSLog(@"!@!@!");
        // Update Table View
        [self.geofences addObject:region];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:([self.geofences count] - 1) inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
        
        // Update View
        [self updateView];
    //}
}

- (void)updateView {
    if (![self.geofences count]) {
        // Update Table View
        [self.tableView setEditing:NO animated:YES];
        
        // Update Edit Button
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
        [self.navigationItem.rightBarButtonItem setTitle:NSLocalizedString(@"Edit", nil)];
        
    } else {
        // Update Edit Button
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
    }
    
    // Update Add Button
    if ([self.geofences count] < 20) {
        [self.navigationItem.leftBarButtonItem setEnabled:YES];
    } else {
        [self.navigationItem.leftBarButtonItem setEnabled:NO];
    }
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}


- (void)editTableView:(id)sender {
    // Update Table View
    [self.tableView setEditing:![self.tableView isEditing] animated:YES];
    
    // Update Edit Button
    if ([self.tableView isEditing]) {
        [self.navigationItem.rightBarButtonItem setTitle:NSLocalizedString(@"Done", nil)];
    } else {
        [self.navigationItem.rightBarButtonItem setTitle:NSLocalizedString(@"Edit", nil)];
    }
}







- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.geofences ? 1 : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.geofences count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:GeofenceCellIdentifier];
    
    // Fetch Geofence
    CLRegion *geofence = [self.geofences objectAtIndex:[indexPath row]];
    
    // Configure Cell
    CLLocationCoordinate2D center = [geofence center];
    NSString *text = [NSString stringWithFormat:@"%.1f | %.1f", center.latitude, center.longitude];
    [cell.textLabel setText:text];
    [cell.detailTextLabel setText:[geofence identifier]];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

@end
