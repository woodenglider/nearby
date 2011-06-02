//
//  PeopleInMap.m
//  NearBy
//
//  Created by 任春宁 on 11-3-26.
//  Copyright 2011 sursen. All rights reserved.
//

#import "PeopleInMapController.h"
#import "DisplayMap.h"
#import "People.h"
#import "SendPosition.h"

@implementation PeopleInMapController
@synthesize mapView;
@synthesize localManager;
//@synthesize userMessageController;
@synthesize queue;
@synthesize annoList;



/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    self.queue = [[NSOperationQueue alloc] init];
    [self.queue setMaxConcurrentOperationCount:10];
    self.annoList = [[NSMutableArray alloc] initWithCapacity:200];
	
	self.mapView.showsUserLocation = YES;
	[mapView setZoomEnabled:YES];
	[mapView setScrollEnabled:YES];
	
	self.localManager = [[[CLLocationManager alloc] init] autorelease];
	localManager.delegate = self;
	localManager.desiredAccuracy = kCLLocationAccuracyKilometer;
	localManager.distanceFilter = 1000.0f;
	
	[localManager startUpdatingLocation];
    
}

#pragma mark -
#pragma mark 喊话
- (IBAction)Shout:(id)sender
{
    ShoutController *shoutCtrl = [[ShoutController alloc] initWithNibName:@"ShoutController" bundle:[NSBundle mainBundle]];
    [self setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self presentModalViewController:shoutCtrl animated:YES];
}

#pragma mark -
#pragma mark 获取周边用户数据

- (IBAction)LoadPeopleAround:(id)sender
{
    
    [self.mapView removeAnnotations:self.annoList];
    self.mapView.delegate = self;
    [self.annoList removeAllObjects];
    
    //获取位置信息
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];  
    NSString *email = [ud objectForKey:@"email"];
    NSString * strLatitude = [ud objectForKey:@"curLatitude"];
    NSString * strLongitude = [ud objectForKey:@"curLongitude"];
    
    PeopleAroundMe * pa = [[PeopleAroundMe alloc] initWithData:email latitude:[strLatitude doubleValue] longitude:[strLongitude doubleValue]];
    
    pa.delegate = self;
    [queue addOperation:pa];
    [pa release];
    
}

#pragma -
#pragma PeopleAroundMeDelegate
-(void)OnePeopleFound:(People*)people
{
    CLLocationCoordinate2D the2dFlag;
	the2dFlag.latitude = [people.latitude doubleValue];
	the2dFlag.longitude = [people.longitude doubleValue];
	
	DisplayMap *ann = [[DisplayMap alloc] init]; 
	ann.title = people.aliasName; 
	ann.coordinate = the2dFlag;
    ann.email = people.email;
	
	[mapView addAnnotation:ann]; 
    [self.annoList addObject:ann];
	[ann release];
}

#pragma mark -
#pragma mark 地图中的人们点击事件

- (void)showDetails:(DisplayMap*)sender
{
    UserMessageController * userMessageController = [[UserMessageController alloc] init];
    [self.navigationController setToolbarHidden:YES animated:YES];
    userMessageController.userMail = ((DisplayMap*)sender).email;   
    userMessageController.aliasName = sender.title;
    [self.navigationController pushViewController: userMessageController animated:YES];
    
    [userMessageController release];
    
}

- (MKAnnotationView *)mapView:(MKMapView *)theMapView 
			viewForAnnotation:(id <MKAnnotation>)annotation{
    
    NSString * strTitle = [annotation title];
    
    if ([strTitle isEqualToString:@"Current Location"]
        || [strTitle isEqualToString:@"当前位置"]) {
        return nil;
    }
	
	static NSString* BridgeAnnotationIdentifier = @"bridgeAnnotationIdentifier";
	MKPinAnnotationView* pinView = (MKPinAnnotationView *)
	[mapView dequeueReusableAnnotationViewWithIdentifier:BridgeAnnotationIdentifier];
	
	
	if (!pinView)
	{
		// if an existing pin view was not available, create one
		MKPinAnnotationView* customPinView = [[[MKPinAnnotationView alloc]
											   initWithAnnotation:annotation reuseIdentifier:BridgeAnnotationIdentifier] autorelease];
        
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];  
        NSString *email = [ud objectForKey:@"email"];
        
        if ([((DisplayMap*)annotation).email isEqualToString:email]) {
            customPinView.pinColor = MKPinAnnotationColorRed;
        } else {
            customPinView.pinColor = MKPinAnnotationColorGreen;
        }
		
		customPinView.animatesDrop = YES;
		customPinView.canShowCallout = YES;
        
        customPinView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        customPinView.annotation = annotation;
        
		return customPinView;
	}
	else
	{
		pinView.annotation = annotation;
	}
	return pinView;	
	
}

-(void)mapView:(MKMapView*)sender annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
    
    DisplayMap * ann = (DisplayMap*)view.annotation;
    
    [self showDetails:ann];
    
}


#pragma mark -
#pragma mark CoreLocation Delegate Methods

- (void)locationManager:(CLLocationManager *)manager 
	didUpdateToLocation:(CLLocation *)newLocation 
		   fromLocation:(CLLocation *)oldLocation{
	
	MKCoordinateRegion theRegion = { {0.0, 0.0 }, { 0.0, 0.0 } };
	theRegion.center = newLocation.coordinate;

	theRegion.span.longitudeDelta = 0.2f;
	theRegion.span.latitudeDelta = 0.2f;
	[mapView setRegion:theRegion animated:YES];
	[mapView regionThatFits:theRegion];
    
    //缓存当前位置信息
    NSString * strLatitude = [NSString stringWithFormat:@"%6f", newLocation.coordinate.latitude];
    NSString * strLongitude = [NSString stringWithFormat:@"%6f", newLocation.coordinate.longitude];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];  
    [ud setObject:strLatitude forKey:@"curLatitude"];
    [ud setObject:strLongitude forKey:@"curLongitude"];
    
    //加载用户信息
    [self LoadPeopleAround:nil];
    
    //记录用户位置
    NSString *email = [ud objectForKey:@"email"];
    SendPosition * sp = [[SendPosition alloc] initWithParm:email Latitude:strLatitude Longitude:strLongitude];
    
    [queue addOperation:sp];
    [sp release];
    
}

- (void)locationManager:(CLLocationManager *)manager 
	   didFailWithError:(NSError *)error{
	
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [self.annoList release];
	[localManager release];
    [queue cancelAllOperations];
    [queue release];
	
    [super dealloc];
}


@end
