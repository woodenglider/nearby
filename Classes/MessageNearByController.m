//
//  MessageNearBy.m
//  NearBy
//
//  Created by 任春宁 on 11-3-26.
//  Copyright 2011 sursen. All rights reserved.
//

#import "MessageNearByController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "MessageDetailController.h"



@implementation MessageNearByController

@synthesize userMessageDetailController;
@synthesize mesList,queue,con,resData,eleName;
@synthesize imageDownloadsInProgress, defaultImage;


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


/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

-(IBAction)Refresh:(id)sender
{
    [self.tableView reloadData];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    defaultImage = [UIImage imageNamed:@"Placeholder.png"]; 
    
    self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
    
    self.tableView.rowHeight = ROW_HEIGHT;
	
    self.mesList = [[NSMutableArray alloc] initWithCapacity:100];
    
    [((TISwipeableTableView*) self.tableView) setSwipeDelegate:self];
	
	if (_refreshHeaderView == nil) {
		
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height,self.view.frame.size.width, self.tableView.bounds.size.height)];
		view.delegate = self;
		[self.tableView addSubview:view];
		_refreshHeaderView = view;
		[view release];
        
	}
	
	//  update the last update date
	[_refreshHeaderView refreshLastUpdatedDate];
	
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
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
#pragma mark 表格代理

- (void)tableView:(UITableView *)tableView didSwipeCellAtIndexPath:(NSIndexPath *)indexPath {
	
	NSString * path = [[NSBundle mainBundle] pathForResource:@"tick" ofType:@"wav"];
	NSURL * fileURL = [NSURL fileURLWithPath:path isDirectory:NO];
	
	SystemSoundID soundID;
	AudioServicesCreateSystemSoundID((CFURLRef)fileURL, &soundID);
	AudioServicesPlaySystemSound(soundID);
	AudioServicesAddSystemSoundCompletion (soundID, NULL, NULL, completionCallback, NULL);
}

- (ExampleCell *)tableviewCellWithReuseIdentifier:(NSString *)identifier 
{

	CGRect rect;
    
    rect = CGRectMake(0.0, 0.0, 320.0, ROW_HEIGHT);
    
    ExampleCell *cell = [[[ExampleCell alloc] initWithFrame:rect reuseIdentifier:identifier] autorelease];
    
    
    [cell setDelegate:self];
    
    //Userpic view
    rect = CGRectMake(BORDER_WIDTH, (ROW_HEIGHT - IMAGE_SIDE) / 2.0, IMAGE_SIDE, IMAGE_SIDE);
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:rect];
    imageView.layer.cornerRadius = 6;
    imageView.layer.masksToBounds = YES;
    imageView.tag = IMAGE_TAG;
    //imageView.image = defaultImage;
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    NSLog(@"row count:%d",self.mesList.count);
    return self.mesList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    
   static NSString *CellIdentifier = @"Cell";
	
	ExampleCell *cell = (ExampleCell*)[tableView
							 dequeueReusableCellWithIdentifier:CellIdentifier];
    
	if (cell == nil) 
    {
        cell = (ExampleCell*)[self tableviewCellWithReuseIdentifier:CellIdentifier];
	}
    cell.accessoryType = UITableViewCellAccessoryCheckmark;

    Message * mess = [self.mesList objectAtIndex:indexPath.row];
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
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:IMAGE_TAG];
    if (!mess.image)
    {
        if (self.tableView.dragging == NO && self.tableView.decelerating == NO)
        {
            [self startIconDownload:mess forIndexPath:indexPath];
        }
        // if a download is deferred or in progress, return a placeholder image
        
        imageView.image = [UIImage imageNamed:@"Placeholder.png"];
    }
    else
    {
        imageView.image = mess.image;
    }
    
    
	return cell;

}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    
	return cell.frame.size.height;

}


// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	[self.navigationController setToolbarHidden:YES animated:NO];
	
	Message *message = (Message *)[self.mesList objectAtIndex:indexPath.row];
	
    MessageDetailController * ctrl = [[MessageDetailController alloc] initWithMessage:message];
    
    UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:indexPath];
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:IMAGE_TAG];
    ctrl.userPicture = imageView.image;
 
	[self.navigationController pushViewController:ctrl animated:YES];
    
    [ctrl release];
	
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
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
    }
}



#pragma mark -
#pragma mark NSUrlConnectionDelegate


- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response
{
    self.resData = [[NSMutableData alloc] init ];
    [imageDownloadsInProgress removeAllObjects];
    
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
    
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark XML解析

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
    //[self.tableView reloadData];
    [self doneLoadingTableViewData];
}

- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validError
{
    NSLog(@"validationErrorOccurred error:%@",validError);
}

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    //[self.mesList removeAllObjects]; 
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    eleName = elementName;
    
    if( [elementName isEqualToString:@"shout"] )
    {
        msg = [[Message alloc] init];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if (msg && [elementName isEqualToString:@"shout"])
    {
        [mesList insertObject:msg atIndex:0];
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
        msg.imageUrl = [NSString stringWithFormat:@"http://124.127.101.56:9996%@", string];
        
        NSLog(@"Image Url is:%@", msg.imageUrl);
    }
    
}

#pragma mark -
#pragma mark 重新加载数据

//刷新消息列表
- (void)reloadTableViewDataSource
{
	
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];  
    NSString *email = [ud objectForKey:@"email"];
    NSLog(@"Email is:%@", email);
    //获取当前位置
    NSString * strLatitude = [ud objectForKey:@"curLatitude"];
    NSString * strLongitude = [ud objectForKey:@"curLongitude"];
    
    
    NSURL * url = [[[NSURL alloc] initWithString:@"http://124.127.101.56:9996/Getaroundmsg"] autorelease];
    
    NSMutableURLRequest *request = [[[ NSMutableURLRequest alloc] initWithURL:url] autorelease];
    
//    //获取当前系统时间戳
//    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
//    NSTimeInterval a=[dat timeIntervalSince1970];
////    NSString *timeString = [NSString stringWithFormat:@"%d", a];
//    
//    long aa = (long)a;
    
    NSString * strStartTime = @"";
    //获取starttime
    if ([self.mesList count] > 0) {
        Message * ms = [self.mesList objectAtIndex:0];
        strStartTime = [[NSString alloc] initWithString:ms.time];
    }
    
    [request setHTTPMethod:@"POST"];
    NSString *strPost = [NSString stringWithFormat:@"username=%@&latitude=%@&longitude=%@&radius=3000000&starttime=%@&endtime=", email, strLatitude, strLongitude, strStartTime];
    
    NSLog(@"strPost is :%@",strPost);
    
    NSData *postData = [strPost dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];  
    
    [request setHTTPBody:(NSData*)postData];
    
    self.con = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	
	_reloading = YES;
	
}

- (void)doneLoadingTableViewData{
	
	//  model should call this when its done loading
	_reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];	
}


#pragma mark -
#pragma mark 喊话
- (IBAction)Shout:(id)sender
{
    ShoutController *shoutCtrl = [[ShoutController alloc] initWithNibName:@"ShoutController" bundle:[NSBundle mainBundle]];
    [self setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self presentModalViewController:shoutCtrl animated:YES];
}


#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{	
	
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    [(TISwipeableTableView*)self.tableView hideVisibleBackView:NO];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    if (!decelerate)
	{
        [self loadImagesForOnscreenRows];
    }
	
}

#pragma mark -
#pragma mark 下拉刷新 Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
	
	[self reloadTableViewDataSource];
	//[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];
	
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
	
	return _reloading; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view
{	
	return [NSDate date]; // should return date data source was last changed
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning 
{
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{

}

- (void)dealloc {
    [defaultImage release];
    [imageDownloadsInProgress release];
    [userMessageDetailController release];
    [mesList release];
    [queue cancelAllOperations];
    [queue release];
    [con cancel];
    [con release];
    [resData release];
    [eleName release];
    //[msg release];
    [super dealloc];
}

@end
