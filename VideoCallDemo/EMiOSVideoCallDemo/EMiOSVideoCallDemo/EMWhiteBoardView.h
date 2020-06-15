//
//  EMWhiteBoardView.h
//  EMiOSVideoCallDemo
//
//  Created by lixiaoming on 2020/6/15.
//  Copyright © 2020 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol EMWhiteBoardViewDelegate <NSObject>

@optional

- (void)whiteBoardViewDidTap;

@end

@interface EMWhiteBoardView : UIView
@property (nonatomic) UILabel* nameLabel;
@property (nonatomic, weak) id<EMWhiteBoardViewDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
