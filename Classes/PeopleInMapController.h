//
//  PeopleInMap.h
//  地图上显示用户位置
//
//  Created by 任春宁 on 11-3-26.
//  Copyright 2011 sursen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "DisplayMap.h"
#import "PeopleAroundMe.h"

#import "UserMessageController.h"
#import "ShoutController.h"


@interface PeopleInMapController : UIViewController<CLLocationManagerDelegate,MKMapViewDelegate,PeopleAroundMeDelegate> {

	IBOutlet MKMapView * mapView;
	CLLocationManager * localManager;
	//IBOutlet UserMessageController * userMessageController;
    NSOperationQueue * queue;
    NSMutableArray * annoList;
	
}

@property (retain, nonatomic) IBOutlet MKMapView * mapView;
@property (retain, nonatomic) CLLocationManager * localManager;
//@property (retain, nonatomic) IBOutlet UserMessageController * userMessageController;
@property (retain, nonatomic) NSOperationQueue * queue;
@property (retain, nonatomic) NSMutableArray * annoList;

- (IBAction)LoadPeopleAround:(id)sender;

- (IBAction)Shout:(id)sender;
@end
