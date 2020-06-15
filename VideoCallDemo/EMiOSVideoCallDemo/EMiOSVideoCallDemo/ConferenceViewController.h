//
//  ConferenceViewController.h
//  EMiOSVideoCallDemo
//
//  Created by lixiaoming on 2020/2/10.
//  Copyright © 2020 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EMStreamView.h"
#import "EMWhiteBoardView.h"

NS_ASSUME_NONNULL_BEGIN

@interface ConferenceViewController : UIViewController<EMConferenceManagerDelegate,EMStreamViewDelegate,UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate,EMWhiteBoardViewDelegate>
@property(nonatomic,strong) UILabel* roomNameLable;
@property(nonatomic,strong) UILabel* timeLabel;
@property(nonatomic,strong) UIButton* settingButton;
@property (nonatomic) UIScrollView* scrollView;
@property (nonatomic) UIButton* switchCameraButton;
@property (nonatomic) UIButton* sharedDesktopButton;
@property (nonatomic) UIButton* whiteBoardButton;
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
@property (weak, nonatomic) NSTimer *timeRecord;
@property (nonatomic, strong) NSMutableDictionary *streamItemDict;
@property (nonatomic, strong) NSMutableDictionary *membersDict;
@property (nonatomic, strong) NSString *pubStreamId;
@property (nonatomic, strong) NSString *desktopStreamId;
@property (nonatomic, strong) NSMutableArray *streamIds;
@property (nonatomic, strong) NSMutableArray *talkingStreamIds;
@property (nonatomic) BOOL isSetMute;
@property (nonatomic) EMConferenceRole role;
@property (nonatomic) UITableView* tableView;
@property (nonatomic) UILabel* audioVolume;
@property (nonatomic) NSMutableDictionary* myStreamIds;

- (void)updateAdminView;

- (instancetype)initWithConfence:(EMCallConference*)call role:(EMConferenceRole)role;
@end

NS_ASSUME_NONNULL_END
