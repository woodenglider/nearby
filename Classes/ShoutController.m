//
//  ShoutController.m
//  NearBy
//
//  Created by 任春宁 on 11-5-7.
//  Copyright 2011年 sursen. All rights reserved.
//

#import "ShoutController.h"
#import <CoreLocation/CoreLocation.h>


@implementation ShoutController
@synthesize shoutText,resData,eleName,messageLabel,con;

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
    [messageLabel release];
    [eleName release];
    [resData release];
    [shoutText release];
    [con cancel];
    [con release];
    [super dealloc];
}

-(IBAction)Shout:(id)sender
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];  
    NSString *email = [ud objectForKey:@"email"]; 
    
    NSLog(@"email is :%@", email);
    
    NSURL * url = [[[NSURL alloc] initWithString:@"http://124.127.101.56:9996/shout"] autorelease];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
    
    //获取当前位置
    NSString * strLatitude = [ud objectForKey:@"curLatitude"];
    NSString * strLongitude = [ud objectForKey:@"curLongitude"];
    
    NSLog(@" Shout The Latitude is:%@", strLatitude);
    NSLog(@" Shout The Longitude is:%@", strLongitude);
    
    
    [request setHTTPMethod:@"POST"];
    NSString *strPost = [NSString stringWithFormat:@"data=<shout user=\"%@\" lat=\"%@\" lon=\"%@\"><text>%@</text><pic></pic><vedio></vedio></shout>", email, strLatitude, strLongitude, self.shoutText.text];
    
    NSLog(@"post data is:%@", strPost);
    
    NSData *postData = [strPost dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];  
    
    [request setHTTPBody:(NSData*)postData];
    
    self.con = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
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
    [self dismissModalViewControllerAnimated:YES];
   
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
            messageLabel.text = @"发送成功";
        }
    }
      
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
    [self.resData appendData:data];
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
    
    [self startParse:self.resData];

}



-(IBAction)Cancel:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
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
    
    shoutText.layer.cornerRadius = 6;
    shoutText.layer.masksToBounds = YES;
    
    // Do any additional setup after loading the view from its nib.
    self.resData = [[NSMutableData alloc] init ];
    self.title = @"发言";
    
    [shoutText becomeFirstResponder];
    
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

@end
