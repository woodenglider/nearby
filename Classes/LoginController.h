//
//  LoginController.h
//  NearBy
//
//  Created by 任春宁 on 11-5-12.
//  Copyright 2011年 sursen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFHFKeychainUtils.h"


@interface LoginController : UIViewController <NSXMLParserDelegate>{
    
    IBOutlet UITextField * userName;
    IBOutlet UITextField * userPwd;
    NSURLConnection * con;
    
    NSString * eleName;
    
    NSMutableData * resData;
}
@property (nonatomic, retain ) IBOutlet UITextField * userName;
@property (nonatomic, retain ) IBOutlet UITextField * userPwd;
@property (nonatomic, retain) NSURLConnection * con;

- (IBAction)Login:(id)sender;
-(void)startParse:(NSData*)data;

@end
