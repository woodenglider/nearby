//
//  SendPosition.m
//  NearBy
//
//  Created by 任春宁 on 11-5-14.
//  Copyright 2011年 sursen. All rights reserved.
//

#import "SendPosition.h"


@implementation SendPosition
@synthesize con, resData;

-(id)initWithParm:(NSString *)email Latitude:(NSString*)latitude Longitude:(NSString *)longitude{
    
    self = [super init];
    if (self) {
        userName = email;
        lat = latitude;
        lon = longitude;
    }

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
    
    //临时缓存节点名称
    eleName = elementName;
    
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    eleName = nil;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    NSLog(@"foundCharacters:%@",string);
    
    if ([eleName isEqualToString:@"state"]) {
        if ([string isEqualToString:@"true"]) {
            NSLog(@"Send Position success!!!!!!");
        }
        else{
            NSLog(@"Send Position failed!!!!!!");
        }
    }
    
    
}   

-(void)start
{
    //初始化数据
    self.resData = [[NSMutableData alloc] init ];
    
    NSURL * url = [[[NSURL alloc] initWithString:@"http://124.127.101.56:9996/sendposition"] autorelease];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPMethod:@"POST"];
    NSString *strPost = [NSString stringWithFormat:@"username=%@&latitude=%@&longitude=%@", userName, lat, lon ];
    
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


-(void)dealloc{

    [resData release];
    [con cancel];
    [con release];
    [super dealloc];
}

@end
