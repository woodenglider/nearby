//
//  People.m
//  NearBy
//
//  Created by 任春宁 on 11-5-7.
//  Copyright 2011年 sursen. All rights reserved.
//

#import "People.h"


@implementation People

@synthesize aliasName, email, latitude, longitude, description;


-(void)dealloc
{
    [description release];
    [email release];
    [aliasName release];
    [latitude release];
    [longitude release];
    [super dealloc];

}

@end
