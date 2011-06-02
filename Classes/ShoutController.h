//
//  ShoutController.h
//  NearBy
//
//  Created by 任春宁 on 11-5-7.
//  Copyright 2011年 sursen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface ShoutController : UIViewController<NSXMLParserDelegate> {
    IBOutlet UITextView * shoutText;
    NSMutableData * resData;
    
    NSString * eleName;
    IBOutlet UILabel * messageLabel;
    NSURLConnection * con;
}

@property (retain, nonatomic) IBOutlet UITextView * shoutText;
@property (retain, nonatomic) NSMutableData * resData;
@property (retain, nonatomic) NSString * eleName;
@property (retain, nonatomic) UILabel * messageLabel;
@property (retain, nonatomic) NSURLConnection * con;

-(IBAction)Shout:(id)sender;
-(IBAction)Cancel:(id)sender;

@end
