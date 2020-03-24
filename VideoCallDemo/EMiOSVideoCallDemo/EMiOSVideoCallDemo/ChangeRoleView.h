//
//  ChangeRoleView.h
//  EMiOSVideoCallDemo
//
//  Created by lixiaoming on 2020/3/17.
//  Copyright © 2020 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChangeRoleView : UIView
@property (nonatomic) UIImageView* imageView;

@property (nonatomic) UILabel* name;

@property (nonatomic) UILabel* desc;

@property (nonatomic) UIButton* leftButton;

@property (nonatomic) UIButton* rightButton;

@property (nonatomic) NSString* memName;

// 定义回调
typedef void(^KickMember)(NSString*);
@property (nonatomic,copy) KickMember kickMem;

@end

NS_ASSUME_NONNULL_END
