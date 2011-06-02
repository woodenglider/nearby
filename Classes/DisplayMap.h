//
//  DisplayMap.h
//  NearBy
//
//  Created by 任春宁 on 11-3-26.
//  Copyright 2011 sursen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MKAnnotation.h>
@interface DisplayMap : NSObject
<MKAnnotation>{
	CLLocationCoordinate2D coordinate;
	NSString *title;
	NSString *subtitle;
    NSString *email;
}
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, retain) NSString * email;
@end

