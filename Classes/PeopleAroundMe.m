//
//  PeopleAroundMe.m
//  NearBy
//
//  Created by 任春宁 on 11-5-6.
//  Copyright 2011年 sursen. All rights reserved.
//

#import "PeopleAroundMe.h"

@implementation PeopleAroundMe
@synthesize userName, resData, latitude, longitude, con, people;
@synthesize eleName;
@synthesize delegate;

//初始化
-(id)initWithData:(NSString*)username latitude:(float)lt longitude:(float)ld
{
    self = [super init];
    if (self) 
    {
        self.userName = username;
        self.latitude = lt;
        self.longitude = ld;
    }
    
    self.people = nil;
    
    return self;
}

#pragma -
#pragma NSUrlConnectionDelegate

- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"start url connection");
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
    
    [self startParse:self.resData];
    
    [self.con release];
    self.con = nil;
}

#pragma -
#pragma NSXMlParserDelegate

-(void)startParse:(NSData*)data
{
    NSString * strRet = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    
    NSLog(@"the return xml is:%@", strRet);
    
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
    NSLog(@"elementName:%@", elementName);
    NSLog(@"namespaceURI:%@", namespaceURI);
    NSLog(@"qName:%@",qName);
    
    if ([elementName isEqualToString:@"people"])
    {
        self.people = [[People alloc] init];
    }
    
    //临时缓存节点名称
    self.eleName = elementName;
    
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    NSLog(@"didEndElement-----------------------");
    NSLog(@"elementName:%@",elementName);
    NSLog(@"namespaceURI:%@",namespaceURI);
    NSLog(@"qName:%@",qName);
    
    if ([elementName isEqualToString:@"people"])
    {
        [delegate OnePeopleFound:self.people];
        [self.people release];
        self.people = nil;
    }
    
    self.eleName = nil;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    NSLog(@"foundCharacters:%@",string);
    
    if (self.people == nil) {
        return;
    }
    
    if ([self.eleName isEqualToString:@"user"])
    {
        people.email = string;
    }
    else if ([self.eleName isEqualToString:@"latitude"]) 
    {
        people.latitude = string;
    }
    else if ([self.eleName isEqualToString:@"longitude"]) 
    {
        people.longitude = string;
    }
    else if ([self.eleName isEqualToString:@"alias"]) 
    {
        people.aliasName = string;
    } 
}


-(void)start
{
    //初始化数据
    self.resData = [[NSMutableData alloc] init ];
    
    NSURL * url = [[[NSURL alloc] initWithString:@"http://124.127.101.56:9996/getpeoplearoundme"] autorelease];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPMethod:@"POST"];
    NSString *strPost = [NSString stringWithFormat:@"username=%@&latitude=%f&longitude=%f&radius=3000000&mins=50", self.userName, self.latitude, self.longitude ];
    
    NSData *postData = [strPost dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];  
    
    [request setHTTPBody:(NSData*)postData];
    
    self.con = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    
    //因为start执行完成后便会释放，因此self不存在，NSUrlConnection代理事件无法响应
    while(self.con != nil) {
        
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];   
    }
}

- (BOOL)isConcurrent 
{
    return YES;//返回yes表示支持异步调用，否则为支持同步调用
}

-(void)dealloc
{
    [eleName release];
    [people release];
    [delegate release];
    [userName release];
    [resData release];
    [super dealloc];
}
@end
