//
//  PrivateInfo.m
//  NearBy
//
//  Created by 任春宁 on 11-5-14.
//  Copyright 2011年 sursen. All rights reserved.
//

#import "PrivateInfo.h"
#import <QuartzCore/QuartzCore.h>


@implementation PrivateInfo
@synthesize  textView, mapView, con, resData, eleName;
@synthesize  people, userName;

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
    [userName release];
    [people release];
    [resData release];
    [eleName release];
    [con cancel];
    [con release];
    [mapView release];
    [textView release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void)LoadData{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];  
    NSString *email = [ud objectForKey:@"email"];
    NSLog(@"Email is:%@", email);

    
    NSURL * url = [[[NSURL alloc] initWithString:@"http://124.127.101.56:9996/Getuserinfo"] autorelease];
    
    NSMutableURLRequest *request = [[[ NSMutableURLRequest alloc] initWithURL:url] autorelease];
    
    [request setHTTPMethod:@"POST"];
    NSString *strPost = [NSString stringWithFormat:@"username=%@", email];
    
    NSLog(@"strPost is :%@",strPost);
    
    NSData *postData = [strPost dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];  
    
    [request setHTTPBody:(NSData*)postData];
    
    self.con = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}


#pragma mark -
#pragma mark NSUrlConnectionDelegate


- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response
{
    self.resData = [[NSMutableData alloc] init ];
    
    NSLog(@"start url connection");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
}

- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)data
{
    [self.resData appendData:data];
    /*
     NSString * strRet = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
     
     NSLog(@"the return xml is:%@", strRet);
     */
}

- (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    NSLog(@"didFailWithError error:%@", error);
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    NSLog(@"connectionDidFinishLoading");
    //判断返回值
    [self startParse:self.resData];
    
}

#pragma mark -
#pragma mark NSXMLParserDelegate

-(void)startParse:(NSData*)data
{
    NSString * strRet = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSLog(@"the return xml is:%@", strRet);
    [strRet release];
    
    NSXMLParser *parser = [[[NSXMLParser alloc] initWithData:data] autorelease];
    [parser setDelegate:self];
    [parser setShouldProcessNamespaces:NO];
    [parser setShouldReportNamespacePrefixes:NO];
    [parser setShouldResolveExternalEntities:NO];
    [parser parse];
    
    
    NSLog(@"parser finished");
    
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    NSLog(@"parserDidEndDocument");
    
    self.textView.text = people.description;
    self.userName.text = people.aliasName;
    
}

- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validError
{
    NSLog(@"validationErrorOccurred error:%@",validError);
}

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
     
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    eleName = elementName;
    
    if( [elementName isEqualToString:@"userinfo"] )
    {
        people = [[People alloc] init];
    }
    
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    eleName = nil;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    NSLog(@"foundCharacters:%@",string);
    
    NSLog(@"the eleName is:%@", eleName);
        
    //检查发言是否成功
    if ([eleName isEqualToString:@"email"]) {
        people.email = string;
    }
    else if ([eleName isEqualToString:@"alias"]) {
        people.aliasName = string;
    }
    else if ([eleName isEqualToString:@"invitecount"]) {
        
    }
    else if ([eleName isEqualToString:@"picture"]) {
        people.aliasName = string;
    }
    else if ([eleName isEqualToString:@"introduction"]) {
        if (people.description == nil) {
            people.description = string;
        }
        else{
            people.description = [NSString stringWithFormat:@"%@%@", people.description, string ];
        }
    }
    else if ([eleName isEqualToString:@"favortext"]) {
               
        
    }
    
}



#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    textView.layer.cornerRadius = 6;
    textView.layer.masksToBounds = YES;
    
    mapView.layer.cornerRadius = 6;
    mapView.layer.masksToBounds = YES;
    
    [self LoadData];
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
