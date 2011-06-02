//
//  Message.m
//  NearBy
//
//  Created by 任春宁 on 11-5-8.
//  Copyright 2011年 sursen. All rights reserved.
//

#import "Message.h"

@implementation Message
@synthesize email, aliasName, latitude, longitude, text, time;
@synthesize image, imageUrl;


-(void) dealloc
{
    [image release];
    [time release];
    [email release];
    [aliasName release];
    [latitude release];
    [longitude release];
    [text release];
    [super dealloc];
}

@end
