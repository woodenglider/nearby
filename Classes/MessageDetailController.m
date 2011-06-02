//
//  MessageDetailController.m
//  NearBy
//
//  Created by 任春宁 on 11-5-21.
//  Copyright 2011年 sursen. All rights reserved.
//

#import "MessageDetailController.h"
#import <QuartzCore/QuartzCore.h>


@implementation MessageDetailController
@synthesize  userView, mapView, textView, msg, userName;
@synthesize userImage, userPicture;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)initWithMessage:(Message*)message
{
    self = [super init ];
    if (self) {
        self.msg = message;
    }
    
    return self;
}

- (void)dealloc
{

    [userPicture release];
    [userImage release];
    [userName release];
    [textView release];
    [mapView release];
    [msg release];

    [userView release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.textView.text = msg.text;
    self.userName.text = msg.aliasName;
    
    
    userImage.layer.cornerRadius = 6;
    userImage.layer.masksToBounds = YES;
    
    mapView.layer.cornerRadius = 9;
    mapView.layer.masksToBounds = YES;
    
    self.userImage.image = userPicture;
    
    MKCoordinateRegion theRegion = { {[msg.latitude doubleValue], [msg.longitude doubleValue] }, { 0.0, 0.0 } };
    
	theRegion.span.longitudeDelta = 0.2f;
	theRegion.span.latitudeDelta = 0.2f;
	[mapView setRegion:theRegion animated:YES];
	[mapView regionThatFits:theRegion];
    
    DisplayMap *ann = [[DisplayMap alloc] init]; 
	ann.coordinate = theRegion.center;
	
	[mapView addAnnotation:ann]; 
    [ann release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
