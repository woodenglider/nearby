//
//  SendPosition.h
//  NearBy
//
//  Created by 任春宁 on 11-5-14.
//  Copyright 2011年 sursen. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SendPosition : NSOperation<NSXMLParserDelegate> {
    
    NSString * userName;
    NSString * lat;
    NSString * lon;
    
    NSURLConnection * con;
    NSMutableData * resData;
    
    NSString * eleName;
}

@property (nonatomic, retain) NSURLConnection * con;
@property (nonatomic, retain) NSMutableData * resData;


-(void)startParse:(NSData*)data;

-(id)initWithParm:(NSString *)email Latitude:(NSString*)latitude Longitude:(NSString *)longitude;

@end
