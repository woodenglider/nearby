//
//  UserMessageController.h
//  地图上显示用户发言的窗体
//
//  Created by 任春宁 on 11-3-27.
//  Copyright 2011 sursen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Message.h"
@class TableCellViewMessage;
#import "TISwipeableTableView.h"
#import "ExampleCell.h"
#import "IconDownloader.h"

@interface UserMessageController : UIViewController<NSXMLParserDelegate,
UITableViewDelegate, UITableViewDataSource,TISwipeableTableViewDelegate, ExampleCellDelegate,IconDownloaderDelegate,UIScrollViewDelegate> {

	//TableCellViewMessage *editingTableViewCell;
	IBOutlet UITableView * tableView;
    
    NSString * userMail;
    NSString * aliasName;
    NSURLConnection * con;
    
    NSMutableData * resData;
    NSString * eleName;
    Message * msg;
    NSMutableArray * mesList;
    
    IBOutlet UIView * userView;
    
    IBOutlet UILabel * userNameLabel;
    
    IBOutlet UIImageView * myImage;
    
    UIImage * myImageTmp;
    
    UIImage * defaultImage;
    //头像下载
    NSMutableDictionary *imageDownloadsInProgress;

}

//@property (nonatomic, retain) IBOutlet TableCellViewMessage *editingTableViewCell;
@property (nonatomic, retain) UIImage * myImageTmp;
@property (nonatomic, retain) IBOutlet UITableView * tableView;
@property (nonatomic, retain) NSURLConnection * con;
@property (nonatomic, retain) NSString * userMail;
@property (nonatomic, retain) NSString * aliasName;
@property (nonatomic, retain) NSMutableData * resData;
@property (nonatomic, retain) NSMutableArray * mesList;
@property (nonatomic, retain) IBOutlet UIView * userView;
@property (nonatomic, retain) IBOutlet UILabel * userNameLabel;
@property (retain, nonatomic ) UIImage * defaultImage;
@property (retain, nonatomic ) IBOutlet UIImageView * myImage;
@property (nonatomic, retain) NSMutableDictionary *imageDownloadsInProgress;

-(void)startParse:(NSData*)data;
-(IBAction)userButton:(id)sender;
-(void)loadImagesForOnscreenRows;
-(void)startIconDownload:(Message *)mess forIndexPath:(NSIndexPath *)indexPath;
-(void)appImageDidLoad:(NSIndexPath *)indexPath;

@end
