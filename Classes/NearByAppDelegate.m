//
//  NearByAppDelegate.m
//  NearBy
//
//  Created by 任春宁 on 11-3-26.
//  Copyright sursen 2011. All rights reserved.
//

#import "NearByAppDelegate.h"
#import "LoginController.h"


@implementation NearByAppDelegate

@synthesize window;
@synthesize tabBarController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {
    
 
    // Add the tab bar controller's current view as a subview of the window
    [window addSubview:tabBarController.view];
    
    //登录
    LoginController *login = [[[LoginController alloc] init] autorelease];
    
    //UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:login];
    
    //[self.tabBarController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    
    [self.tabBarController presentModalViewController:login animated:NO]; 
    
}


/*
// Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
}
*/

/*
// Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
}
*/


- (void)dealloc {
    [tabBarController release];
    [window release];
    [super dealloc];
}

@end

