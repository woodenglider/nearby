//
//  NearByAppDelegate.h
//  NearBy
//
//  Created by 任春宁 on 11-3-26.
//  Copyright sursen 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NearByAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
    UIWindow *window;
    UITabBarController *tabBarController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

@end
