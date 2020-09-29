//
//  AppDelegate.m
//  EMiOSVideoCallDemo
//
//  Created by lixiaoming on 2020/2/10.
//  Copyright © 2020 easemob. All rights reserved.
//

#import "AppDelegate.h"
#import "RoomJoinViewController.h"
#import "EMDemoOption.h"

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

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options
{
    // 接受传过来的参数
    NSString* params = [url query];
    params = params.stringByRemovingPercentEncoding;
    NSRange range = [params rangeOfString:@"="];
    if(range.location == NSNotFound){
        return YES;
    }
    NSString* roomName = [params substringFromIndex:(range.location+1)];
    if([EMDemoOption sharedOptions].conference){
        if(![roomName isEqualToString:[EMDemoOption sharedOptions].roomName]){
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"正在进行会议，不能自动加入会议" message:nil preferredStyle:UIAlertControllerStyleAlert];
                
            UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    
                }];
            [alertController addAction:OKAction];
                
            [self.window.rootViewController presentViewController:alertController animated:YES completion:nil];
            return YES;
        }
    }else{
        NSUserDefaults* sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.easemob"];
        [sharedDefaults setObject:roomName forKey:@"autoJoinRoomName"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"autojoin" object:roomName];
    }
    return YES;
}

@end
