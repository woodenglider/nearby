//
//  People.h
//  NearBy
//
//  Created by 任春宁 on 11-5-7.
//  Copyright 2011年 sursen. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface People : NSObject {
    NSString * aliasName;
    NSString * email;
    NSString * latitude;
    NSString * longitude;
    NSString * description;
    
    
}

@property (nonatomic, retain) NSString* aliasName;
@property (nonatomic, retain ) NSString * email;
@property (nonatomic, retain) NSString * latitude;
@property (nonatomic, retain) NSString * longitude;
@property (nonatomic, retain) NSString * description;

@end
