//
//  SharedDesktopViewController.h
//  EMiOSVideoCallDemo
//
//  Created by lixiaoming on 2020/9/9.
//  Copyright © 2020 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SharedDesktopViewController : UIViewController
@property (nonatomic) UIActivityIndicatorView * activity;
-(instancetype)initWithSharedDesktopView:(UIView*)view;
@end

NS_ASSUME_NONNULL_END
