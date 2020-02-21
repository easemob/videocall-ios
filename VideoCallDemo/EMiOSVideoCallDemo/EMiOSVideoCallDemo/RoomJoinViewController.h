//
//  RoomJoinViewController.h
//  EMiOSVideoCallDemo
//
//  Created by lixiaoming on 2020/2/10.
//  Copyright © 2020 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RoomJoinViewController : UIViewController<UITextFieldDelegate>
@property(nonatomic,strong) UIImageView* conferencelogo;
@property(nonatomic,strong) UITextField* nameField;
@property(nonatomic,strong) UITextField* pswdField;
@property(nonatomic,strong) UIButton* joinAsSpeaker;
@property(nonatomic,strong) UIButton* joinAsAudience;
@property(nonatomic,strong) UILabel* errorLable;

@end

NS_ASSUME_NONNULL_END
