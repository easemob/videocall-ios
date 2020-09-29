//
//  MoreOptionViewController.h
//  EMiOSVideoCallDemo
//
//  Created by lixiaoming on 2020/9/15.
//  Copyright © 2020 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MoreOptionViewController : UIViewController
@property (nonatomic,strong) UIButton* settingButton;
@property (nonatomic) UIButton* inviteButton;
@property (nonatomic, strong) UILabel *inviteLable;
@property (nonatomic, strong) UILabel *roleLable;
@property (nonatomic, strong) UILabel *settingLable;
@property (nonatomic) UIViewController* confVC;
@property (nonatomic, strong) UIButton *roleButton;
- (instancetype)initWithConfVC:(UIViewController*)confVC;
@end

NS_ASSUME_NONNULL_END
