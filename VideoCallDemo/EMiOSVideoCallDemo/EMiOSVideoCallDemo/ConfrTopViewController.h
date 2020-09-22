//
//  ConfrTopViewController.h
//  EMiOSVideoCallDemo
//
//  Created by lixiaoming on 2020/9/16.
//  Copyright © 2020 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ConfrTopViewController : UIViewController
@property(nonatomic,strong) UILabel* roomNameLable;
@property(nonatomic,strong) UILabel* timeLabel;
@property (nonatomic) UIButton* switchCameraButton;
@property (nonatomic) UIButton* selectDevice;
@property (nonatomic) UIViewController* confVC;
@property (nonatomic, strong) UIButton *leaveConfrButton;
- (instancetype)initWithConfVC:(UIViewController*)confVC;
@end

NS_ASSUME_NONNULL_END
