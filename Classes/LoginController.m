//
//  LoginController.m
//  NearBy
//
//  Created by 任春宁 on 11-5-12.
//  Copyright 2011年 sursen. All rights reserved.
//

#import "LoginController.h"


@implementation LoginController
@synthesize userName, userPwd, con;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [eleName release];
    [resData release];
    [con cancel];
    [con release];
    [userPwd release];
    [userName release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    self.title = @"登录";
    resData = [[NSMutableData alloc] init ];
    
    //初始化用户名
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];  
    NSString *email = [ud objectForKey:@"email"]; 
    if (email != nil) {
        self.userName.text = email;
        NSString * password = [SFHFKeychainUtils getPasswordForUsername:email andServiceName:@"Nearby" error:nil];
        if (password != nil) {
            self.userPwd.text = password;
        }
        
        [self.userPwd becomeFirstResponder];
    }
    else{
        [self.userName becomeFirstResponder];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark 登录

-(IBAction)Login:(id)sender
{
    //判断是否有用户名和密码
    if (self.userName.text == nil) {
        //
        return;
    }
    
    if (self.userPwd.text == nil) {
        //
        return;
    }
    [resData release];
    resData = nil;
    resData = [[NSMutableData alloc] init ];
    
    //缓存用户名
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults]; 
    [ud setObject:self.userName.text forKey:@"email"];
    
    NSString *ee1 = [ud objectForKey:@"email"];
    
    NSLog(@"The Login Email is : %@", self.userName.text );
    NSLog(@"The Login Email is : %@", ee1 );
    
    
    NSURL * url = [[[NSURL alloc] initWithString:@"http://124.127.101.56:9996/login"] autorelease];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
       
    [request setHTTPMethod:@"POST"];
    NSString *strPost = [NSString stringWithFormat:@"username=%@&password=%@", self.userName.text, self.userPwd.text];
    
    NSData *postData = [strPost dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];  
    
    [request setHTTPBody:(NSData*)postData];
    
    self.con = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
}

#pragma mark -
#pragma mark NSUrlConnectionDelegate

- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"start url connection");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)data
{
    [resData appendData:data];
}

- (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    NSLog(@"error:%@", error);
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    //判断返回值
    
    [self startParse:resData];
    
}


#pragma mark -
#pragma mark NSXMlParserDelegate

-(void)startParse:(NSData*)data
{
    NSString * strRet = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSLog(@"the return xml is:%@", strRet);
    [strRet release];
    
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    [parser setDelegate:self];
    [parser setShouldProcessNamespaces:NO];
    [parser setShouldReportNamespacePrefixes:NO];
    [parser setShouldResolveExternalEntities:NO];
    [parser parse];
    
    NSError *parseError = [parser parserError];
    NSLog(@"parse error:%@", parseError);
    
    [parser release];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    //[self dismissModalViewControllerAnimated:YES];
    
}

- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validError
{
    NSLog(@"error:%@",validError);
}

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    NSLog(@"parserDidStartDocument");
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    NSLog(@"didStartElement-----------------------");
    NSLog(@"elementName:%@",elementName);
    NSLog(@"namespaceURI:%@",namespaceURI);
    NSLog(@"qName:%@",qName);
    
    eleName = elementName;
    
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    eleName = nil;
    
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    NSLog(@"foundCharacters:%@",string);
    
    
    //检查发言是否成功
    if ([eleName isEqualToString:@"state"]) {
        if ([string isEqualToString:@"true"]) {
            
            [SFHFKeychainUtils storeUsername:self.userName.text andPassword:self.userPwd.text forServiceName:@"Nearby" updateExisting:YES error:nil];
            
            [self dismissModalViewControllerAnimated:YES];
        }
        else{
            UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"登录" 
                                                                 message:@"登录失败"
                                                                delegate:nil 
                                                       cancelButtonTitle:@"确认" 
                                                       otherButtonTitles:nil];
            [alertView show];
            [alertView release];
        }
    }
    else if( [eleName isEqualToString:@"picture"] ){
        //缓存用户名
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults]; 
        [ud setObject:string forKey:@"picture"];
    }
    
}

@end
