//
//  PeopleAroundMe.h
//  NearBy
//
//  Created by 任春宁 on 11-5-6.
//  Copyright 2011年 sursen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "People.h"

//解析周围用户代理
@protocol PeopleAroundMeDelegate

-(void)OnePeopleFound:(People*)people;

@end

//获取周围用户类
@interface PeopleAroundMe : NSOperation<NSXMLParserDelegate> {
    NSString * userName;
    float  latitude;
    float  longitude;
    NSURLConnection * con;
    People * people;
    
    NSString * eleName;
    
    NSObject<PeopleAroundMeDelegate>* delegate;
    NSMutableData * resData;
    
}

@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSMutableData * resData;
@property (nonatomic) float latitude;
@property (nonatomic) float longitude;
@property (nonatomic, retain) NSURLConnection * con;
@property (nonatomic, retain) NSObject<PeopleAroundMeDelegate> * delegate;
@property (nonatomic, retain) People * people;
@property (nonatomic, retain) NSString * eleName;


-(id)initWithData:(NSString*)username latitude:(float)lt longitude:(float)ld;
-(void)startParse:(NSData*)data;
@end
