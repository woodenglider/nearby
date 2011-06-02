//
//  UserMessageController.m
//  NearBy
//
//  Created by 任春宁 on 11-3-27.
//  Copyright 2011 sursen. All rights reserved.
//

#import "UserMessageController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "MessageDetailController.h"
#import "PrivateInfo.h"


#define NAME_TAG 1
#define TIME_TAG 2
#define IMAGE_TAG 3
#define TEXT_TAG 4
#define ROW_HEIGHT 64

#define IMAGE_SIDE 48
#define BORDER_WIDTH 5
#define TEXT_OFFSET_X (BORDER_WIDTH * 2 + IMAGE_SIDE)
#define LABEL_HEIGHT 20
#define LABEL_WIDTH 130
#define TEXT_WIDTH (320 - TEXT_OFFSET_X - BORDER_WIDTH)
#define TEXT_OFFSET_Y (BORDER_WIDTH * 2 + LABEL_HEIGHT)
#define TEXT_HEIGHT (ROW_HEIGHT - TEXT_OFFSET_Y - BORDER_WIDTH)



@implementation UserMessageController
//@synthesize editingTableViewCell;
@synthesize tableView, con, userMail, resData, mesList;
@synthesize userView, userNameLabel, aliasName;
@synthesize defaultImage, imageDownloadsInProgress;
@synthesize myImage, myImageTmp;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    myImage.layer.cornerRadius = 6;
    myImage.layer.masksToBounds = YES;
    
    defaultImage = [UIImage imageNamed:@"Placeholder.png"]; 
    
    self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
    
    self.tableView.rowHeight = ROW_HEIGHT;
    
    self.title = @"用户资料";
    
    self.userNameLabel.text = self.aliasName;
    
    [((TISwipeableTableView*) self.tableView) setSwipeDelegate:self];
    
    resData = [[NSMutableData alloc] init ];
     self.mesList = [[NSMutableArray alloc] initWithCapacity:100];
    
    NSURL * url = [[[NSURL alloc] initWithString:@"http://124.127.101.56:9996/getmessageofuser"] autorelease];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPMethod:@"POST"];
    NSString *strPost = [NSString stringWithFormat:@"username=%@&starttime=&endtime=&msgcount=", userMail];
    
    NSLog(@"post data is:%@", strPost);
    
    NSData *postData = [strPost dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];  
    
    [request setHTTPBody:(NSData*)postData];
    
    self.con = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	
}

#pragma mark -
#pragma mark 显示用户详细资料

-(IBAction)userButton:(id)sender{
    
    PrivateInfo * personInfo = [[PrivateInfo alloc] init];
    
    [self.navigationController pushViewController:personInfo animated:YES];
    
    [personInfo release];

}


#pragma mark -
#pragma mark 横向滑动菜单

static void completionCallback(SystemSoundID soundID, void * clientData) {
	AudioServicesRemoveSystemSoundCompletion(soundID);
}

- (void)cellBackButtonWasTapped:(ExampleCell *)cell {
	NSLog(@"%@", cell);
}


#pragma mark -
#pragma mark 网络连接代理


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
    [self.tableView reloadData];
    
}

#pragma mark -
#pragma mark XML数据解析代理

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

}

- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validError
{
    NSLog(@"validationErrorOccurred error:%@",validError);
}

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    [mesList removeAllObjects]; 
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    eleName = elementName;
    
    if( [elementName isEqualToString:@"shout"] )
    {
        msg = [[Message alloc] init];
        msg.aliasName = self.aliasName;
        
        //缓存用户名
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults]; 
        NSString * imageUrl = [ud objectForKey: @"picture"];
        
        msg.imageUrl = [NSString stringWithFormat:@"http://124.127.101.56:9996%@", imageUrl];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if (msg && [elementName isEqualToString:@"shout"])
    {
        [mesList addObject:msg];
        [msg release];
        msg = nil;
        eleName = nil;
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    NSLog(@"foundCharacters:%@",string);
    
    if (!msg) 
    {
        return;
    }
    
    //检查发言是否成功
    if ([eleName isEqualToString:@"alias"]) {
        msg.aliasName = string;
    }
    else if ([eleName isEqualToString:@"user"]) {
        msg.email = string;
    }
    else if ([eleName isEqualToString:@"text"]) {
        if (msg.text == nil) {
            msg.text = string;
        }
        else{
            msg.text = [NSString stringWithFormat:@"%@%@", msg.text, string ];
        }
        //msg.text = [msg.text stringByAppendingFormat:@"%@",string];
    }
    else if ([eleName isEqualToString:@"longitude"]) {
        msg.longitude = string;
    }
    else if ([eleName isEqualToString:@"latitude"]) {
        msg.latitude = string;
    }
    else if ([eleName isEqualToString:@"time"]) {
        NSDate * date = [[NSDate alloc] initWithTimeIntervalSince1970:[string doubleValue]];
        
        NSDateFormatter* dateFormater = [[NSDateFormatter alloc] init]; 
        
        [dateFormater setDateFormat:@"MM-dd HH:mm"]; 
        dateFormater.locale = [[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"] autorelease];
        msg.time = [dateFormater stringFromDate:date];
        
        [dateFormater release];
        [date release];
           
    }
    else if ([eleName isEqualToString:@"picture"]) {
        

        
    }
    
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{		
    [(TISwipeableTableView*)self.tableView hideVisibleBackView:NO];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	
}


#pragma mark -
#pragma mark 表格代理

- (void)tableView:(UITableView *)tableView didSwipeCellAtIndexPath:(NSIndexPath *)indexPath {
	
	NSString * path = [[NSBundle mainBundle] pathForResource:@"tick" ofType:@"wav"];
	NSURL * fileURL = [NSURL fileURLWithPath:path isDirectory:NO];
	
	SystemSoundID soundID;
	AudioServicesCreateSystemSoundID((CFURLRef)fileURL, &soundID);
	AudioServicesPlaySystemSound(soundID);
	AudioServicesAddSystemSoundCompletion (soundID, NULL, NULL, completionCallback, NULL);
}

- (UITableViewCell *)tableviewCellWithReuseIdentifier:(NSString *)identifier 
{
    
	CGRect rect;
    
    rect = CGRectMake(0.0, 0.0, 320.0, ROW_HEIGHT);
    
    ExampleCell *cell = [[[ExampleCell alloc] initWithFrame:rect reuseIdentifier:identifier] autorelease];
    
    [cell setDelegate:self];
    
    //Userpic view
    rect = CGRectMake(BORDER_WIDTH, (ROW_HEIGHT - IMAGE_SIDE) / 2.0, IMAGE_SIDE, IMAGE_SIDE);
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:rect];
    imageView.tag = IMAGE_TAG;
    [cell.contentView addSubview:imageView];
    [imageView release];
    
    
    UILabel *label;
    
    //Username
    rect = CGRectMake(TEXT_OFFSET_X, BORDER_WIDTH, LABEL_WIDTH, LABEL_HEIGHT);
    label = [[UILabel alloc] initWithFrame: rect];
    label.tag = NAME_TAG;
    label.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
    label.highlightedTextColor = [UIColor whiteColor];
    [cell.contentView addSubview:label];
    label.opaque = NO;
    label.backgroundColor = [UIColor clearColor];
    
    [label release];
    
    //Message creation time
    rect = CGRectMake(TEXT_OFFSET_X + LABEL_WIDTH, BORDER_WIDTH, LABEL_WIDTH, LABEL_HEIGHT);
    label = [[UILabel alloc] initWithFrame:rect];
    label.tag = TIME_TAG;
    label.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
    label.textAlignment = UITextAlignmentRight;
    label.highlightedTextColor = [UIColor whiteColor];
    label.textColor = [UIColor lightGrayColor];
    [cell.contentView addSubview:label];
    label.opaque = NO;
    label.backgroundColor = [UIColor clearColor];
    
    [label release];
    
    //Message body
    rect = CGRectMake(TEXT_OFFSET_X, TEXT_OFFSET_Y, TEXT_WIDTH, TEXT_HEIGHT);
    label = [[UILabel alloc] initWithFrame:rect];
    label.tag = TEXT_TAG;
    label.lineBreakMode = UILineBreakModeWordWrap;
    label.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    label.highlightedTextColor = [UIColor whiteColor];
    label.numberOfLines = 0;
    [cell.contentView addSubview:label];
    label.opaque = NO;
    label.backgroundColor = [UIColor clearColor];
    
    [label release];
    
    return cell;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"MesList count :%d", self.mesList.count);
    return self.mesList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"UserMessageCell";
	
	ExampleCell *cell = (ExampleCell*)[self.tableView
							 dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) 
    {
		//cell = [[[UITableViewCell alloc]
		//		 initWithStyle:UITableViewCellStyleSubtitle
		//		 reuseIdentifier:CellIdentifier] autorelease];
        
        cell = (ExampleCell*)[self tableviewCellWithReuseIdentifier:CellIdentifier];
	}	
	
    Message * mess = [self.mesList objectAtIndex:indexPath.row];
    
    //Set userpic
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:IMAGE_TAG];
    imageView.layer.cornerRadius = 6;
    imageView.layer.masksToBounds = YES;
    
    CGRect cellFrame = [cell frame];
    //Set message text
    UILabel *label;
    label = (UILabel *)[cell viewWithTag:NAME_TAG];
    label.text = mess.aliasName;
    label = (UILabel *)[cell viewWithTag:TIME_TAG];
    label.text = mess.time;
    label = (UILabel *)[cell viewWithTag:TEXT_TAG];
    label.text = mess.text;
    
    
    [label setFrame:CGRectMake(TEXT_OFFSET_X, TEXT_OFFSET_Y, TEXT_WIDTH, TEXT_HEIGHT)];
    [label sizeToFit];
    if(label.frame.size.height > TEXT_HEIGHT)
    {
        cellFrame.size.height = ROW_HEIGHT + label.frame.size.height - TEXT_HEIGHT;
    }
    else
    {
        cellFrame.size.height = ROW_HEIGHT;
    }
    
    [cell setFrame:cellFrame];
    
    cell.contentView.backgroundColor = indexPath.row % 2? [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1]: [UIColor whiteColor];
    
    // Only load cached images; defer new downloads until scrolling ends
    if (!mess.image)
    {
        if (self.tableView.dragging == NO && self.tableView.decelerating == NO)
        {
            [self startIconDownload:mess forIndexPath:indexPath];
        }
        // if a download is deferred or in progress, return a placeholder image
        
        imageView.image = defaultImage;
    }
    else
    {
        imageView.image = mess.image;
    }
    
	return cell;
	
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [self tableView:self.tableView cellForRowAtIndexPath:indexPath];
    
	return cell.frame.size.height;
    
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	[self.navigationController setToolbarHidden:YES animated:NO];
	
	Message *message = (Message *)[self.mesList objectAtIndex:indexPath.row];
	
    MessageDetailController * ctrl = [[MessageDetailController alloc] initWithMessage:message];
    
	[self.navigationController pushViewController:ctrl animated:YES];
    
    [ctrl release];
	
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	
	//return [NSString stringWithFormat:@"Section %i", section];
	return @"";
	
}

#pragma mark -
#pragma mark Deferred image loading (UIScrollViewDelegate)


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImagesForOnscreenRows];
}

- (void)loadImagesForOnscreenRows
{
    if ([self.mesList count] > 0)
    {
        NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths)
        {
            Message *mess = [self.mesList objectAtIndex:indexPath.row];
            
            if (!mess.image) 
            {
                [self startIconDownload:mess forIndexPath:indexPath];
            }
        }
    }
}

- (void)startIconDownload:(Message *)mess forIndexPath:(NSIndexPath *)indexPath
{
    IconDownloader *iconDownloader = [imageDownloadsInProgress objectForKey:indexPath];
    if (iconDownloader == nil && mess.imageUrl != nil ) 
    {
        iconDownloader = [[IconDownloader alloc] init];
        iconDownloader.appRecord = mess;
        iconDownloader.indexPathInTableView = indexPath;
        iconDownloader.delegate = self;
        [imageDownloadsInProgress setObject:iconDownloader forKey:indexPath];
        [iconDownloader startDownload];
        [iconDownloader release];   
    }
}

- (void)appImageDidLoad:(NSIndexPath *)indexPath
{
    IconDownloader *iconDownloader = [imageDownloadsInProgress objectForKey:indexPath];
    if (iconDownloader != nil)
    {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:iconDownloader.indexPathInTableView];
        
        UIImageView *imageView = (UIImageView *)[cell viewWithTag:IMAGE_TAG];
        imageView.image = iconDownloader.appRecord.image; 
    
        if (myImageTmp == nil) {
            myImageTmp = imageView.image;
            self.myImage.image = myImageTmp;
        }
    }
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    
    [myImageTmp release];
    [myImage release];
    [imageDownloadsInProgress release];
    [defaultImage release];
    [userNameLabel release];
    [userView release];
    [msg release];
    [mesList release];
    [resData release];
    [con release];
    //[editingTableViewCell release];
    [super dealloc];
}


@end
