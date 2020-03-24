//
//  ConferenceViewController.h
//  EMiOSVideoCallDemo
//
//  Created by lixiaoming on 2020/2/10.
//  Copyright © 2020 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EMStreamView.h"

NS_ASSUME_NONNULL_BEGIN

@interface ConferenceViewController : UIViewController<EMConferenceManagerDelegate,EMStreamViewDelegate,UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong) UILabel* roomNameLable;
@property(nonatomic,strong) UILabel* timeLabel;
@property(nonatomic,strong) UIButton* settingButton;
@property (nonatomic) UIScrollView* scrollView;
@property (nonatomic) UIButton* switchCameraButton;
@property (nonatomic, strong) UIButton *microphoneButton;
@property (nonatomic, strong) UIButton *videoButton;
@property (nonatomic, strong) UIButton *hangupButton;
@property (nonatomic, strong) UIButton *membersButton;
@property (nonatomic, strong) UIButton *roleButton;
@property (nonatomic, strong) UILabel *microphoneLable;
@property (nonatomic, strong) UILabel *videoLable;
@property (nonatomic, strong) UILabel *hangupLable;
@property (nonatomic, strong) UILabel *membersLable;
@property (nonatomic, strong) UILabel *roleLable;

@property (nonatomic, copy) NSString* roomName;

@property (nonatomic, copy) NSString *currentTime;

@property (nonatomic, strong) EMStreamView *curBigView;
@property (nonatomic, assign) int timeLength;
@property (strong, nonatomic) NSTimer *timeTimer;
@property (nonatomic, strong) NSMutableDictionary *streamItemDict;
@property (nonatomic, strong) NSMutableDictionary *membersDict;
@property (nonatomic, strong) NSString *pubStreamId;
@property (nonatomic, strong) NSMutableArray *streamIds;
@property (nonatomic, strong, readonly) NSMutableArray *talkingStreamIds;
@property (nonatomic) BOOL isSetSpeaker;
@property (nonatomic) EMConferenceRole role;
@property (nonatomic) UITableView* tableView;
@property (nonatomic) UILabel* audioVolume;

- (void)updateAdminView;

- (instancetype)initWithConfence:(EMCallConference*)call role:(EMConferenceRole)role;
@end

NS_ASSUME_NONNULL_END
