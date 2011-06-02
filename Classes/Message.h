//
//  Message.h
//  NearBy
//
//  Created by 任春宁 on 11-5-8.
//  Copyright 2011年 sursen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Message : NSObject {
    NSString * email;
    NSString * aliasName;
    NSString * latitude;
    NSString * longitude;
    NSString * text;
    NSString * time;
    
    UIImage * image;
    NSString * imageUrl;
}

@property ( nonatomic, retain ) NSString * email;
@property ( nonatomic, retain ) NSString * aliasName;
@property ( nonatomic, retain ) NSString * latitude;
@property ( nonatomic, retain ) NSString * longitude;
@property ( nonatomic, retain ) NSString * text;
@property ( nonatomic, retain ) NSString * time;

@property (nonatomic, retain) UIImage * image;
@property (nonatomic, retain ) NSString * imageUrl;


@end
