//
//  MessageNearBy.h
//  NearBy
//
//  Created by 任春宁 on 11-3-26.
//  Copyright 2011 sursen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import "UserMessageDetailController.h"
#import "Message.h"
#import "ShoutController.h"
#import "TISwipeableTableView.h"
#import "ExampleCell.h"
#import "IconDownloader.h"


@interface MessageNearByController : UITableViewController  
<EGORefreshTableHeaderDelegate, UITableViewDelegate, UITableViewDataSource,NSXMLParserDelegate,TISwipeableTableViewDelegate, ExampleCellDelegate,UIScrollViewDelegate,IconDownloaderDelegate> {
    
	EGORefreshTableHeaderView *_refreshHeaderView;
	BOOL _reloading;
	IBOutlet UserMessageDetailController * userMessageDetailController;
    NSOperationQueue * queue;
    NSMutableArray * mesList;
    NSURLConnection * con;
    NSMutableData * resData;
    NSString * eleName;
    Message * msg;
    
    UIImage * defaultImage;
    
    
    //头像下载
    NSMutableDictionary *imageDownloadsInProgress;
	
}

@property (nonatomic, retain) NSMutableArray * mesList;
@property (retain,nonatomic) UserMessageDetailController * userMessageDetailController;
@property (retain, nonatomic) NSOperationQueue * queue;
@property (retain, nonatomic ) NSURLConnection * con;
@property (retain, nonatomic ) NSMutableData * resData;
@property (retain, nonatomic ) NSString * eleName;
//@property (retain, nonatomic ) Message * msg;

@property (retain, nonatomic ) UIImage * defaultImage;

@property (nonatomic, retain) NSMutableDictionary *imageDownloadsInProgress;

- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;
-(void)startParse:(NSData*)data;
-(IBAction)Refresh:(id)sender;

- (IBAction)Shout:(id)sender;

- (void)loadImagesForOnscreenRows;

- (void)startIconDownload:(Message *)mess forIndexPath:(NSIndexPath *)indexPath;
- (void)appImageDidLoad:(NSIndexPath *)indexPath;

@end
