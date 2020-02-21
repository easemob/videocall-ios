//
//  RoomSettingViewController.h
//  EMiOSVideoCallDemo
//
//  Created by lixiaoming on 2020/2/11.
//  Copyright © 2020 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RoomSettingViewController : UITableViewController
@property (nonatomic,copy) NSString* roomName;
@property (nonatomic,copy) NSString* roomPswd;
@property (nonatomic,copy) NSString* adminName;
@end

NS_ASSUME_NONNULL_END
