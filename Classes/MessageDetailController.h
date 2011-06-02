//
//  MessageDetailController.h
//  NearBy
//
//  Created by 任春宁 on 11-5-21.
//  Copyright 2011年 sursen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Message.h"
#import "DisplayMap.h"

@interface MessageDetailController : UIViewController {
    
    Message * msg;
    
    IBOutlet UIView * userView;
    IBOutlet MKMapView * mapView;
    IBOutlet UITextView * textView;
    
    IBOutlet UIImageView * userImage;
    UIImage * userPicture;
    
    IBOutlet UILabel * userName;
    
}

@property (nonatomic, retain) Message * msg;
@property (nonatomic, retain) IBOutlet UILabel * userName;
@property (nonatomic, retain) IBOutlet UIView * userView;
@property (nonatomic, retain) IBOutlet MKMapView * mapView;
@property (nonatomic, retain) IBOutlet UITextView * textView;
@property (nonatomic, retain ) IBOutlet UIImageView * userImage;
@property (nonatomic, retain) UIImage * userPicture;


-(id)initWithMessage:(Message*)message;

@end
