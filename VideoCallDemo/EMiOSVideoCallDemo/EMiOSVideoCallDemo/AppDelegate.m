//
//  AppDelegate.m
//  EMiOSVideoCallDemo
//
//  Created by lixiaoming on 2020/2/10.
//  Copyright © 2020 easemob. All rights reserved.
//

#import "AppDelegate.h"
#import "RoomJoinViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    RoomJoinViewController* roomJoin = [[RoomJoinViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:roomJoin];
    navigationController.navigationBar.backgroundColor = [UIColor blueColor];
    [navigationController.navigationBar.layer setMasksToBounds:YES];
    navigationController.view.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
    return YES;
}

-(UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    if (self.allowRotation == YES) {
        //横屏
        return UIInterfaceOrientationMaskAll;
    }
    return self.curOrientationMask;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[EMClient sharedClient] applicationDidEnterBackground:application];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[EMClient sharedClient] applicationWillEnterForeground:application];
}


- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL*)url
{
    // 接受传过来的参数
    NSString* params = [url query];
    return YES;
}

@end
