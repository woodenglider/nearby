//
//  PrivateInfo.h
//  NearBy
//
//  Created by 任春宁 on 11-5-14.
//  Copyright 2011年 sursen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "People.h"


@interface PrivateInfo : UIViewController<NSXMLParserDelegate>{
    
    
    IBOutlet UITextView * textView;
    IBOutlet MKMapView * mapView;
    
    NSURLConnection * con;
    
    NSMutableData * resData;
    NSString * eleName;
    
    People * people;
    
    IBOutlet UILabel * userName;

    
}

@property (nonatomic, retain ) IBOutlet UITextView * textView;
@property (nonatomic, retain ) IBOutlet MKMapView * mapView;
@property (nonatomic, retain ) NSURLConnection * con;

@property (retain, nonatomic ) NSMutableData * resData;
@property (retain, nonatomic ) NSString * eleName;
@property (retain, nonatomic ) People * people;

@property (retain, nonatomic ) IBOutlet UILabel * userName;

-(void)startParse:(NSData*)data;

@end
