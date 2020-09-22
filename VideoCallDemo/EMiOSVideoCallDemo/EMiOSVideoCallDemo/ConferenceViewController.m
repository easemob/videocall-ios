//
//  ConferenceViewController.m
//  EMiOSVideoCallDemo
//
//  Created by lixiaoming on 2020/2/10.
//  Copyright © 2020 easemob. All rights reserved.
//

#import "ConferenceViewController.h"
#import "RoomSettingViewController.h"
#import "SpeakerListViewController.h"
#import "EMDemoOption.h"
#import "EMAlertController.h"
#import "KickSpeakerViewController.h"
#import "ChangeRoleView.h"
#import "BroadcastSetupViewController.h"
#import "WhiteBoardViewController.h"
#import "SharedDesktopViewController.h"
#import "AppDelegate.h"
#import "MoreOptionViewController.h"
#import "ConfrTopViewController.h"

@interface ConferenceViewController ()<UIScrollViewDelegate,UIPopoverPresentationControllerDelegate>
@property (nonatomic) UIButton* recordButton;
@property (nonatomic) RPBroadcastActivityViewController* broadVC;
@property (nonatomic) NSUserDefaults *sharedDefaults;
@property (nonatomic) RPBroadcastController*broadcastController;
@property (nonatomic) RPSystemBroadcastPickerView *picker;
@property (nonatomic) EMWhiteboard *whiteBoard;
@property (nonatomic) NSString* wbCreator;
@property (nonatomic) WKWebView *wkWebView;
@property (nonatomic) AVAudioSessionCategory category;
@property (nonatomic) AVAudioSessionCategoryOptions option;
@property (nonatomic) UISwipeGestureRecognizer * recognizer;
@property (nonatomic) EMStreamView *remoteDesktopView;
@property (nonatomic) SharedDesktopViewController* sharedDesktopVC;
@property (nonatomic) NSString* remoteDesktopStreamId;
@property (nonatomic) ConfrTopViewController* topVC;
@property (nonatomic) NSMutableDictionary* showStreamViewInScrollView;
@end

@implementation ConferenceViewController
static int gZorder = 1;
static bool gCanSharedDesktop = YES;
static int gSmallVideoSize = 100;
static int gBottomMenuHeight = 60;

- (instancetype)initWithConfence:(EMCallConference*)call role:(EMConferenceRole)role
{
    self = [super init];
    if (self) {
        self.streamItemDict = [NSMutableDictionary dictionary];
        self.membersDict = [NSMutableDictionary dictionary];
        self.role = role;
        __weak typeof(self) weakself = self;
        [[[EMClient sharedClient] conferenceManager] getConference:call.confId password:[EMDemoOption sharedOptions].roomPswd completion:^(EMCallConference *aCall, EMError *aError) {
            [EMDemoOption sharedOptions].conference.adminIds = [aCall.adminIds copy];
            [EMDemoOption sharedOptions].conference.memberCount = aCall.memberCount;
            [EMDemoOption sharedOptions].conference.speakerIds = [aCall.speakerIds copy];
            [EMDemoOption sharedOptions].conference.audiencesCount = aCall.audiencesCount;
            [weakself updateAdminView];
        }];
        
        EMCallOptions *options = [[EMClient sharedClient].callManager getCallOptions];
        options.isClarityFirst = [EMDemoOption sharedOptions].isClarityFirst;
        //options.minVideoKbps = 600;
        
        EMConferenceRole currole = call.role;
        if (currole != EMConferenceRoleAudience) {
            [weakself pubLocalStreamWithEnableVideo:[EMDemoOption sharedOptions].openCamera completion:^(NSString *aPubStreamId, EMError *aError) {
                [weakself updateAdminView];
            }];
        } else {
            weakself.microphoneButton.enabled = NO;
            weakself.videoButton.enabled = NO;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself playWithSpeaker];
        });
    }
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    return self;
}

-(void)keyWindowActive:(NSNotification*)param
{
    gCanSharedDesktop = YES;
}

-(void)audioInterruption:(NSNotification*)param
{
    if(param && param.userInfo) {
        NSNumber* state = [param.userInfo objectForKey:AVAudioSessionInterruptionTypeKey];
        if([state intValue] == AVAudioSessionInterruptionTypeBegan) {
            AVAudioSession *audioSession = [AVAudioSession sharedInstance];
            self.category = audioSession.category;
            self.option = audioSession.categoryOptions;
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategorySoloAmbient error:nil];
        }else if([state intValue] == AVAudioSessionInterruptionTypeEnded){
            AVAudioSession *audioSession = [AVAudioSession sharedInstance];
            [audioSession setCategory:self.category withOptions: self.option error:nil];
            [audioSession setActive:YES error:nil];
        }
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view
    _myStreamIds = [NSMutableDictionary dictionary];
    _desktopStreamId = nil;
    [self setupSubViews];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyWindowActive:) name:UIWindowDidBecomeVisibleNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioInterruption:) name:AVAudioSessionInterruptionNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];

    [[[EMClient sharedClient] conferenceManager] addDelegate:self delegateQueue:nil];
    [[[EMClient sharedClient] conferenceManager] startMonitorSpeaker:[EMDemoOption sharedOptions].conference timeInterval:2 completion:^(EMError *aError) {
        
    }];
    if (@available(iOS 13.0, *)) {
        _picker.showsMicrophoneButton = NO;
        _picker = [[RPSystemBroadcastPickerView alloc] initWithFrame:CGRectMake(10, 60, 100, 40)];
        //你的app对用upload extension的 bundle id， 必须要填写对
        _picker.preferredExtension = @"com.easemob.EMiOSVideoCallDemo.SharedDesktop";
        _picker.center = self.view.center;
        
        self.sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.easemob"];
        [self.sharedDefaults setObject:nil forKey:@"data"];
        [self.sharedDefaults setObject:nil forKey:@"width"];
        [self.sharedDefaults setObject:nil forKey:@"height"];
        [self.sharedDefaults setObject:nil forKey:@"status"];
    }
    self.recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [self.recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft | UISwipeGestureRecognizerDirectionRight)];
    [self.view addGestureRecognizer:self.recognizer];
//    if([EMDemoOption sharedOptions].conference.role == EMConferenceRoleAdmin) {
//        [self _addLive:@""];
//    }
}

-(void)dealloc
{
    [[EMClient sharedClient].conferenceManager removeDelegate:self];
}

-(void)viewDidAppear:(BOOL)animated
{
    gCanSharedDesktop = YES;
}

- (void)_addLive:(NSString*)url
{
    LiveConfig* liveconfig = [[LiveConfig alloc] init];
    LiveCanvas* canvas = [[LiveCanvas alloc] init];
    canvas.fps = 18;
    canvas.kbps = 900;
    canvas.codec = @"H264";
    canvas.bgclr = 0x0000ff;
    if([EMDemoOption sharedOptions].livePureAudio) {
        canvas.width = 0;
        canvas.height = 0;
    }else{
        canvas.width = 1280;
        canvas.height = 768;
    }
    liveconfig.canvas = canvas;
    liveconfig.cdnUrl = url;
    liveconfig.layoutStyle = CUSTOM;
    liveconfig.record = YES;
    AudioConfig* audioConfig = [[AudioConfig alloc] init];
    audioConfig.bps = LiveAudioBps_8K;
    audioConfig.channels = 1;
    audioConfig.samples = LiveAudioSampleRate_32K;
    liveconfig.audioCfg = audioConfig;
    liveconfig.recordExt = [EMDemoOption sharedOptions].recordExt;
    [[[EMClient sharedClient] conferenceManager] addConferenceLive:[EMDemoOption sharedOptions].conference  LiveCfg:liveconfig completion:^(EMError *aError) {
        if(aError){
        }
    }];
}

-(ConfrTopViewController*)topVC
{
    if(_topVC == nil){
        _topVC = [[ConfrTopViewController alloc] initWithConfVC:self];
    }
    return _topVC;
}

-(void) setupSubViews
{
    self.isSetMute = YES;
    [self addChildViewController:self.topVC];
    [self.view addSubview:self.topVC.view];
    [self.topVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view);
        make.height.equalTo(self.view).multipliedBy(0.1);
        make.left.equalTo(self.view);
        make.top.equalTo(self.view);
    }];
    [self.view bringSubviewToFront:self.topVC.view];
    
    [self startTimer];
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 180, self.view.bounds.size.width, gSmallVideoSize)];
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.contentSize = CGSizeMake(gSmallVideoSize*8, gSmallVideoSize);
    self.scrollView.delegate = self;
    [self.view addSubview:self.scrollView];
    
    /*
    self.startRecordButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.startRecordButton.frame = CGRectMake(self.view.bounds.size.width - 100, 150, 40, 40);
    [self.startRecordButton setTitle:@"开始" forState:UIControlStateNormal];
    [self.startRecordButton addTarget:self action:@selector(startRecordAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.startRecordButton];
    
    self.stopRecordButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.stopRecordButton.frame = CGRectMake(self.view.bounds.size.width - 100, 200, 40, 40);
    [self.stopRecordButton setTitle:@"停止" forState:UIControlStateNormal];
    [self.stopRecordButton addTarget:self action:@selector(stopRecordAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.stopRecordButton];
    */
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-gBottomMenuHeight, self.view.bounds.size.width, gBottomMenuHeight) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(gBottomMenuHeight));
        make.width.equalTo(self.view);
        make.left.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view);
        make.height.equalTo(@(gSmallVideoSize));
        make.left.equalTo(self.view);
        make.bottom.equalTo(self.view).with.offset(-gBottomMenuHeight);
    }];
    self.view.backgroundColor = [UIColor grayColor];
}
- (void)inviteAction
{
    if(self.presentedViewController)
       [self.presentedViewController dismissViewControllerAnimated:YES completion:^{
           
       }];
    // 1、设置分享的内容，并将内容添加到数组中
    NSArray *activityItemsArray = @[[NSString stringWithFormat:@"https://rtc-turn4-hsb.easemob.com/rtc-ws/meeting-share-loading-page/index.html?roomName=%@&invitees=%@",[EMDemoOption sharedOptions].roomName,[EMDemoOption sharedOptions].nickName]];
    NSArray *activityArray = @[];
    
    // 2、初始化控制器，添加分享内容至控制器
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems:activityItemsArray applicationActivities:activityArray];
    activityVC.modalInPopover = YES;
    // 3、设置回调
    UIActivityViewControllerCompletionWithItemsHandler itemsBlock = ^(UIActivityType __nullable activityType, BOOL completed, NSArray * __nullable returnedItems, NSError * __nullable activityError){
        NSLog(@"activityType == %@",activityType);
        if (completed == YES) {
            NSLog(@"completed");
        }else{
            NSLog(@"cancel");
        }
    };
    activityVC.completionWithItemsHandler = itemsBlock;
    // 4、调用控制器
    [self presentViewController:activityVC animated:YES completion:nil];
}
/*
-(void)startRecordAction
{
    __weak typeof(self) weakself = self;
    if([[EMDemoOption sharedOptions].conference.liveCfgs count] > 0){
        NSArray* allKeys = [[EMDemoOption sharedOptions].conference.liveCfgs allKeys];
        for(NSString* liveId in allKeys) {
            [[[EMClient sharedClient] conferenceManager] enableRecordLiveStream:[EMDemoOption sharedOptions].conference liveId:liveId enabled:YES completion:^(EMError *aError) {
                if(aError){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakself showHint:[NSString stringWithFormat:@"开启失败 %@",aError.description]];
                    });
                }else
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakself showHint:@"开启成功"];
                    });
            }];
        }
    }else{
        [[[EMClient sharedClient] conferenceManager] enableRecordLiveStream:[EMDemoOption sharedOptions].conference liveId:[EMDemoOption sharedOptions].conference.liveId enabled:YES completion:^(EMError *aError) {
            if(aError){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakself showHint:[NSString stringWithFormat:@"开启失败 %@",aError.description]];
                });
            }else
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakself showHint:@"开启成功"];
                });
        }];
    }
}

-(void)stopRecordAction
{
    __weak typeof(self) weakself = self;
    if([[EMDemoOption sharedOptions].conference.liveCfgs count] > 0){
        NSArray* allKeys = [[EMDemoOption sharedOptions].conference.liveCfgs allKeys];
        for(NSString* liveId in allKeys) {
            [[[EMClient sharedClient] conferenceManager] enableRecordLiveStream:[EMDemoOption sharedOptions].conference liveId:liveId enabled:NO completion:^(EMError *aError) {
                if(aError){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakself showHint:[NSString stringWithFormat:@"停止失败 %@",aError.description]];
                    });
                }else
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakself showHint:@"停止成功"];
                    });
                    
            }];
        }
    }else{
        [[[EMClient sharedClient] conferenceManager] enableRecordLiveStream:[EMDemoOption sharedOptions].conference liveId:[EMDemoOption sharedOptions].conference.liveId enabled:NO completion:^(EMError *aError) {
            if(aError){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakself showHint:[NSString stringWithFormat:@"停止失败 %@",aError.description]];
                });
                
            }else
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakself showHint:@"停止成功"];
                });
        }];
    }
}
*/
- (void)joinWBAction
{
    if(self.presentedViewController)
        [self.presentedViewController dismissViewControllerAnimated:YES completion:^{
        }];
    if([self.desktopStreamId length] > 0 || self.sharedDesktopVC){
        [EMAlertController showInfoAlert:@"正在进行共享任务，不能共享白板"];
        return;
    }
    if(self.whiteBoard && self.wkWebView) {
        WhiteBoardViewController* wbVC = [[WhiteBoardViewController alloc] initWithWBUrl:self.whiteBoard];
        [self.navigationController pushViewController:wbVC animated:NO];
    }else
        [self _joinWhiteBoardWithName:[EMDemoOption sharedOptions].roomName password:[EMDemoOption sharedOptions].roomPswd];
}

-(void)_joinWhiteBoardWithName:(NSString*)whiteBoardName password:(NSString*)password
{
    __weak typeof(self) weakself = self;
    [[EMClient sharedClient].conferenceManager joinWhiteboardRoomWithName:whiteBoardName username:[EMClient sharedClient].currentUsername userToken:[EMClient sharedClient].accessUserToken roomPassword:password completion:^(EMWhiteboard *aWhiteboard, EMError *aError) {
        if (!aError) {
            weakself.whiteBoard = aWhiteboard;
            WhiteBoardViewController* wbVC = [[WhiteBoardViewController alloc] initWithWBUrl:weakself.whiteBoard];
            [weakself.navigationController pushViewController:wbVC animated:NO];
        } else {
            if (aError.code == EMErrorCallRoomNotExist) {
                if([EMDemoOption sharedOptions].conference.role == EMConferenceRoleAudience) {
                    [EMAlertController showErrorAlert:@"观众不能创建白板"];
                    return;
                }
                [[EMClient sharedClient].conferenceManager createWhiteboardRoomWithUsername:[EMClient sharedClient].currentUsername userToken:[EMClient sharedClient].accessUserToken roomName:whiteBoardName roomPassword:password interact:YES completion:^(EMWhiteboard *aWhiteboard, EMError *aError) {
                    if (!aError) {
                        weakself.whiteBoard = aWhiteboard;
                        NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0]; // 获取当前时间0秒后的时间
                        NSTimeInterval time = [date timeIntervalSince1970]*1000;// *1000 是精确到毫秒(13位)
                        NSDictionary* dic = @{@"creator":[EMClient sharedClient].currentUsername,@"roomName":whiteBoardName,@"roomPswd":password,@"timestamp":[NSNumber numberWithInteger:time]};
                        NSError *jsonError = nil;
                        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&jsonError];
                        NSString *jsonStr = @"";
                        if (jsonData && !jsonError) {
                            jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                        }
                        [[[EMClient sharedClient] conferenceManager] setConferenceAttribute:@"whiteBoard" value:jsonStr completion:^(EMError *aError) {
                            
                        }];
                        WhiteBoardViewController* wbVC = [[WhiteBoardViewController alloc] initWithWBUrl:weakself.whiteBoard];
                        [self.navigationController pushViewController:wbVC animated:NO];
                    } else {
                        [weakself showHint:aError.errorDescription];
                    }
                }];
            } else {
                [weakself showHint:aError.errorDescription];
            }
        }
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return gBottomMenuHeight;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

// Default is 1 if not implemented
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger section = indexPath.section;
    static NSString *cellIdentifier = @"cellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
    cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:
        UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    if(section == 0){
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor colorWithRed:20/255.0 green:20/255.0 blue:20/255.0 alpha:1.0];
        int padding = 10;
        int top = 5;
        int size = (self.view.bounds.size.width - 20*6)/5;
        int iconsize = 30;
        int offset = (size-iconsize)/2;
        self.microphoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.microphoneButton.frame = CGRectMake(padding+offset, top, iconsize, iconsize);
        //[self.microphoneButton setTitle:@"" forState:UIControlStateNormal];
        [self.microphoneButton addTarget:self action:@selector(microphoneButtonAction) forControlEvents:UIControlEventTouchUpInside];
        //[self.microphoneButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.microphoneButton setImage:[UIImage imageNamed:@"microphoneselect"] forState:UIControlStateSelected];
        [self.microphoneButton setImage:[UIImage imageNamed:@"microphonenclose"] forState:UIControlStateNormal];
        self.microphoneLable = [[UILabel alloc] initWithFrame:CGRectMake(padding, top+iconsize+2, size, 20)];
        self.microphoneLable.text = @"解除静音";
        self.microphoneLable.textAlignment = NSTextAlignmentCenter;
        [self.microphoneLable setFont:[UIFont fontWithName:@"Arial" size:10]];
        self.microphoneLable.textColor = [UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1.0];
        [cell addSubview:self.microphoneButton];
        [cell addSubview:self.microphoneLable];
        [self.microphoneButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(cell).multipliedBy(0.2);
            make.width.equalTo(@(iconsize));
            make.top.equalTo(@5);
            make.height.equalTo(@(iconsize));
        }];
        [self.microphoneLable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(cell).multipliedBy(0.2);
            make.width.equalTo(cell).multipliedBy(0.2);
            make.top.equalTo(@30);
            make.height.equalTo(@30);
        }];
        
        self.videoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.videoButton.frame = CGRectMake(padding + (padding+size) + offset, top, iconsize, iconsize);
        [self.videoButton setTitle:@"" forState:UIControlStateNormal];
        [self.videoButton addTarget:self action:@selector(videoButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [self.videoButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self.videoButton setImage:[UIImage imageNamed:@"videoopen"] forState:UIControlStateSelected];
        [self.videoButton setImage:[UIImage imageNamed:@"videoclose"] forState:UIControlStateNormal];
        self.videoLable = [[UILabel alloc] initWithFrame:CGRectMake(padding + (padding+size), top+iconsize+2, size, 20)];
        self.videoLable.text = @"打开视频";
        self.videoLable.textAlignment = NSTextAlignmentCenter;
        [self.videoLable setFont:[UIFont fontWithName:@"Arial" size:10]];
        self.videoLable.textColor = [UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1.0];
        [cell addSubview:self.videoButton];
        [cell addSubview:self.videoLable];
        [self.videoButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(cell).multipliedBy(0.6);
            make.width.equalTo(@(iconsize));
            make.top.equalTo(@5);
            make.height.equalTo(@(iconsize));
        }];
        [self.videoLable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(cell).multipliedBy(0.6);
            make.width.equalTo(cell).multipliedBy(0.2);
            make.top.equalTo(@30);
            make.height.equalTo(@30);
        }];
        
        self.sharedButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.sharedButton.frame = CGRectMake(padding + (padding+size) * 2 + offset, top, iconsize, iconsize);
        //[self.hangupButton setTitle:@"挂断" forState:UIControlStateNormal];
        self.sharedButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.sharedButton setImage:[UIImage imageNamed:@"call_screenshare"] forState:UIControlStateNormal];
        [self.sharedButton setTintColor:[UIColor whiteColor]];
        [self.sharedButton addTarget:self action:@selector(sharedAction) forControlEvents:UIControlEventTouchUpInside];
        self.sharedLable = [[UILabel alloc] initWithFrame:CGRectMake(padding + (padding+size)*2, top+iconsize+2, size, 20)];
        self.sharedLable.text = @"共享";
        self.sharedLable.textAlignment = NSTextAlignmentCenter;
        self.sharedLable.textColor = [UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1.0];
        [self.sharedLable setFont:[UIFont fontWithName:@"Arial" size:10]];
        [cell addSubview:self.sharedButton];
        [cell addSubview:self.sharedLable];
        [self.sharedButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(cell);
            make.width.equalTo(@(iconsize));
            make.top.equalTo(@5);
            make.height.equalTo(@(iconsize));
        }];
        [self.sharedLable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(cell);
            make.width.equalTo(cell).multipliedBy(0.2);
            make.top.equalTo(@30);
            make.height.equalTo(@30);
        }];
        
        self.membersButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.membersButton.frame = CGRectMake(padding + (padding+size) * 3 + offset, top, iconsize, iconsize);
        //[self.membersButton setTitle:@"成员" forState:UIControlStateNormal];
        [self.membersButton setImage:[UIImage imageNamed:@"成员"] forState:UIControlStateNormal];
        [self.membersButton setTintColor:[UIColor whiteColor]];
        //self.membersButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        //[self.membersButton setImage:[UIImage imageNamed:@"成员"] forState:UIControlStateNormal];
        [self.membersButton addTarget:self action:@selector(membersAction) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:self.membersButton];
        self.membersLable = [[UILabel alloc] initWithFrame:CGRectMake(padding + (padding+size)*3, top+iconsize+2, size, 20)];
        self.membersLable.text = @"成员";
        self.membersLable.textColor = [UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1.0];
        self.membersLable.textAlignment = NSTextAlignmentCenter;
        [self.membersLable setFont:[UIFont fontWithName:@"Arial" size:10]];
        [cell addSubview:self.membersLable];
        [self.membersButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(cell).multipliedBy(1.4);
            make.width.equalTo(@(iconsize));
            make.top.equalTo(@5);
            make.height.equalTo(@(iconsize));
        }];
        [self.membersLable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(cell).multipliedBy(1.4);
            make.width.equalTo(cell).multipliedBy(0.2);
            make.top.equalTo(@30);
            make.height.equalTo(@30);
        }];
        
        self.moreOptionButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [cell addSubview:self.moreOptionButton];
        [self.moreOptionButton setImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];
        [self.moreOptionButton setTintColor:[UIColor whiteColor]];
        [self.moreOptionButton addTarget:self action:@selector(moreOptionAction) forControlEvents:UIControlEventTouchUpInside];
        [self.moreOptionButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(cell).multipliedBy(1.8);
            make.width.equalTo(@40);
            make.top.equalTo(@5);
            make.height.equalTo(@(iconsize));
        }];
        self.moreOptionLable = [[UILabel alloc] initWithFrame:CGRectMake(padding + (padding+size)*4, top+iconsize+2, size, 20)];
        self.moreOptionLable.text = @"更多";
        self.moreOptionLable.textColor = [UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1.0];
        self.moreOptionLable.textAlignment = NSTextAlignmentCenter;
        [self.moreOptionLable setFont:[UIFont fontWithName:@"Arial" size:10]];
        [cell addSubview:self.moreOptionLable];
        [self.moreOptionLable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(cell).multipliedBy(1.8);
            make.width.equalTo(cell).multipliedBy(0.2);
            make.top.equalTo(@30);
            make.height.equalTo(@30);
        }];
        
        if([EMDemoOption sharedOptions].conference.role == EMConferenceRoleAudience)
        {
            self.microphoneButton.enabled = NO;
            self.videoButton.enabled = NO;
        }
        else
        {
            self.microphoneButton.enabled = YES;
            self.videoButton.enabled = YES;
        }
    }
    return cell;
}
     
-(void)microphoneButtonAction
{
    self.isSetMute = self.microphoneButton.isSelected;
    [[EMClient sharedClient].conferenceManager updateConference:[EMDemoOption sharedOptions].conference isMute:self.isSetMute];
    [self muteUI:self.isSetMute];
}

- (void)playWithSpeaker
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord withOptions: AVAudioSessionCategoryOptionDefaultToSpeaker
                        error:nil];
    [audioSession setActive:YES error:nil];
}

- (void)videoButtonAction
{
    self.videoButton.selected = !self.videoButton.isSelected;
    
    [[[EMClient sharedClient] conferenceManager] updateConference:[EMDemoOption sharedOptions].conference enableVideo:self.videoButton.selected];
    if([self.pubStreamId length] > 0){
        EMStreamItem* localItem = [self.streamItemDict objectForKey:self.pubStreamId];
        if(localItem){
            localItem.videoView.enableVideo = self.videoButton.isSelected;
            self.topVC.switchCameraButton.enabled = self.videoButton.isSelected;
        }
    }
    [self updateVidelLable];
}

-(void)updateMicrophoneLable
{
    if(!self.microphoneButton.selected){
        self.microphoneLable.text = @"解除静音";
    }else{
        self.microphoneLable.text = @"静音";
    }
}

-(void)updateVidelLable
{
    if(!self.videoButton.selected){
        self.videoLable.text = @"打开视频";
    }else
        self.videoLable.text = @"关闭视频";
}

- (void)switchCamaraAction
{
    [[[EMClient sharedClient] conferenceManager] updateConferenceWithSwitchCamera:[EMDemoOption sharedOptions].conference];
}

#pragma mark - timer

- (void)startTimer
{
    _timeLength = 0;
    _timeTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeTimerAction:) userInfo:nil repeats:YES];
}

- (void)timeTimerAction:(id)sender
{
    _timeLength += 1;
    int hour = _timeLength / 3600;
    int m = (_timeLength - hour * 3600) / 60;
    int s = _timeLength - hour * 3600 - m * 60;
    
    self.topVC.timeLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d", hour, m, s];
}

#pragma mark - button action
-(void)membersAction
{
    SpeakerListViewController* speakerListVC = [[SpeakerListViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [self.navigationController pushViewController:speakerListVC animated:YES];
    [[[EMClient sharedClient] conferenceManager] getConference:[EMDemoOption sharedOptions].conference.confId password:[EMDemoOption sharedOptions].roomPswd completion:^(EMCallConference *aCall, EMError *aError) {
        [EMDemoOption sharedOptions].conference.adminIds = [aCall.adminIds copy];
        [EMDemoOption sharedOptions].conference.memberCount = aCall.memberCount;
        [EMDemoOption sharedOptions].conference.speakerIds = [aCall.speakerIds copy];
        [EMDemoOption sharedOptions].conference.audiencesCount = aCall.audiencesCount;
        dispatch_async(dispatch_get_main_queue(), ^{
            [speakerListVC.tableView reloadData];
        });
        
    }];
    
}

-(BOOL)isCreator
{
    if(self.whiteBoard && [self.whiteBoard.roomURL length] > 0) {
        NSArray* array = [self.whiteBoard.roomURL componentsSeparatedByString:@"?"];
        if([array count] > 1) {
            NSString* params = [array objectAtIndex:1];
            NSArray* paramsArray = [params componentsSeparatedByString:@"&"];
            for(NSString* param in paramsArray) {
                NSArray* paramArray = [param componentsSeparatedByString:@"="];
                NSString* key = [paramArray objectAtIndex:0];
                if([key isEqualToString:@"isCreater"]) {
                    NSString* value = [paramArray objectAtIndex:1];
                    if([value isEqualToString:@"true"]) {
                        return YES;
                    }
                    break;
                }
            }
        }
    }
    return NO;
}

- (void)_hangup:(BOOL)isDestroy
{
    if(self.whiteBoard && [self isCreator]) {
        [[[EMClient sharedClient] conferenceManager] destroyWhiteboardRoomWithUsername:[EMClient sharedClient].currentUsername userToken:[EMClient sharedClient].accessUserToken roomId:self.whiteBoard.roomId completion:^(EMError *aError) {
            if(!aError) {
            }
        }];
        [[[EMClient sharedClient] conferenceManager] deleteAttributeWithKey:@"whiteBoard" completion:^(EMError *aError) {
            if(!aError) {
            }
        }];
    }
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
    [audioSession setActive:YES error:nil];
    for(NSString* streamId in self.streamItemDict) {
        EMStreamItem* item = [self.streamItemDict objectForKey:streamId];
        if(item && item.stream && [item.stream.streamId length] > 0) {
            [[[EMClient sharedClient] conferenceManager] unsubscribeConference:[EMDemoOption sharedOptions].conference streamId:item.stream.streamId completion:^(EMError *aError) {
                
            }];
        }
    }
    if([self.pubStreamId length] > 0)
       [[[EMClient sharedClient] conferenceManager] unpublishConference:[EMDemoOption sharedOptions].conference streamId:self.pubStreamId completion:^(EMError *aError) {
        
    }];
    if([self.desktopStreamId length] > 0)
       [[[EMClient sharedClient] conferenceManager] unpublishConference:[EMDemoOption sharedOptions].conference streamId:self.desktopStreamId completion:^(EMError *aError) {
        
    }];
    __weak typeof(self) weakself = self;
    void(^block)(EMError*err) = ^(EMError*err){
        [weakself clearResource];
        [weakself dismissViewControllerAnimated:NO completion:nil];
        while (![weakself.navigationController.topViewController isKindOfClass:[self class]]) {
            [weakself.navigationController popViewControllerAnimated:NO];
        }
        [weakself.navigationController popViewControllerAnimated:NO];
    };
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC*0.1), dispatch_get_main_queue(), ^{
        if([EMDemoOption sharedOptions].conference) {
            [[EMClient sharedClient].conferenceManager stopMonitorSpeaker:[EMDemoOption sharedOptions].conference];
            if(isDestroy)
                [[EMClient sharedClient].conferenceManager destroyConferenceWithId:[EMDemoOption sharedOptions].conference.confId completion:block];
            else
                [[EMClient sharedClient].conferenceManager leaveConference:[EMDemoOption sharedOptions].conference completion:block];
        }
    });
    
}

- (void)hangupAction
{
    if([EMDemoOption sharedOptions].conference.role == EMConferenceRoleAdmin){
        __weak typeof(self) weakself = self;
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"如果您不想结束会议，请在离开前指定新的主持人" message:nil preferredStyle:UIAlertControllerStyleActionSheet];

        UIAlertAction *destroyAction = [UIAlertAction actionWithTitle:@"离开会议" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakself _hangup:NO];
        }];
        [alertController addAction:destroyAction];

        UIAlertAction *leaveAction = [UIAlertAction actionWithTitle:@"结束会议" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakself _hangup:YES];
        }];
        [alertController addAction:leaveAction];

        [alertController addAction: [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", @"Cancel") style: UIAlertActionStyleCancel handler:nil]];

        [self presentViewController:alertController animated:YES completion:nil];
    }else
        [self _hangup:NO];
}

- (void)sharedAction
{
    __weak typeof(self) weakself = self;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *desktopSharedAction = [UIAlertAction actionWithTitle:@"共享屏幕" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakself recordAction];
    }];
    [alertController addAction:desktopSharedAction];

    UIAlertAction *wbAction = [UIAlertAction actionWithTitle:@"互动白板" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakself joinWBAction];
    }];
    [alertController addAction:wbAction];

    [alertController addAction: [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", @"Cancel") style: UIAlertActionStyleCancel handler:nil]];

    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)clearResource
{
    [self.topVC willMoveToParentViewController:nil];
    [self.topVC.view removeFromSuperview];
    [self.topVC removeFromParentViewController];
    if (_timeTimer) {
        [_timeTimer invalidate];
        _timeTimer = nil;
    }
    if (_timeRecord) {
        [_timeRecord invalidate];
        _timeRecord = nil;
    }
    for (UIView *subview in self.scrollView.subviews) {
        [subview removeFromSuperview];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [EMDemoOption sharedOptions].conference = nil;
    [[[EMClient sharedClient] conferenceManager] removeDelegate:self];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    gZorder = 1;
}

- (void)moreOptionAction
{
    MoreOptionViewController* vc = [[MoreOptionViewController alloc] initWithConfVC:self];
    vc.modalPresentationStyle = UIModalPresentationPopover;
    //rect参数是以view的左上角为坐标原点（0，0）
    vc.popoverPresentationController.sourceView = self.moreOptionButton;
    //指定箭头所指区域的矩形框范围（位置和尺寸），以view的左上角为坐标原点
    vc.popoverPresentationController.sourceRect = CGRectZero;
    //箭头方向
    vc.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionDown;
    vc.popoverPresentationController.delegate = self;
    vc.preferredContentSize = CGSizeMake(200, 80);
    [self presentViewController:vc animated:YES completion:nil];
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller{
    return UIModalPresentationNone;
}

- (void)roleChangeAction
{
    if(self.presentedViewController)
        [self.presentedViewController dismissViewControllerAnimated:YES completion:^{
            
        }];
    if([EMDemoOption sharedOptions].conference.role >= EMConferenceRoleSpeaker) {
        if(self.streamItemDict.count == 1 && [self.pubStreamId length] > 0){
            [EMAlertController showInfoAlert:@"您是唯一主播，当前禁止下播"];
            return;
        }
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"下麦后将不能发布语音视频" message:nil preferredStyle:UIAlertControllerStyleActionSheet];

        UIAlertAction *downAction = [UIAlertAction actionWithTitle:@"确认下麦" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[[EMClient sharedClient] conferenceManager] changeMemberRoleWithConfId:[EMDemoOption sharedOptions].conference.confId memberName:[NSString stringWithFormat:@"%@_%@",[EMDemoOption sharedOptions].appkey,[EMDemoOption sharedOptions].userid] role:EMConferenceRoleAudience completion:^(EMError *aError) {
                if(!aError) {
                    [EMAlertController showInfoAlert:@"下麦成功"];
                }
            }];
        }];
        [alertController addAction:downAction];

        [alertController addAction: [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", @"Cancel") style: UIAlertActionStyleCancel handler:nil]];

        [self presentViewController:alertController animated:YES completion:nil];
        
    }else{
        [[[EMClient sharedClient] conferenceManager] getConference:[EMDemoOption sharedOptions].conference.confId password:[EMDemoOption sharedOptions].roomPswd completion:^(EMCallConference *aCall, EMError *aError) {
            [EMDemoOption sharedOptions].conference.adminIds = [aCall.adminIds copy];
            [EMDemoOption sharedOptions].conference.audiencesCount = aCall.audiencesCount;
            if( [[EMDemoOption sharedOptions].conference.adminIds count] > 0) {
                NSString * adminName = [[EMDemoOption sharedOptions].conference.adminIds objectAtIndex:0];
                if([adminName length] > 0) {
                    EMCallMember* member = [self.membersDict objectForKey:adminName];
                    if(member) {
                        [[[EMClient sharedClient] conferenceManager] requestTobeSpeaker:[EMDemoOption sharedOptions].conference adminId:member.memberId completion:^(EMError *aError) {
                            if(!aError){
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [EMAlertController showInfoAlert:@"上麦申请已提交，请等待主持人审核"];
                                });
                            }
                        }];
                    }
                }
            }else {
                [EMAlertController showInfoAlert:@"当前没有主持人"];
            }
            
        }];
        
    }
}

- (void) settingAction:(UIButton*)button
{
    if(self.presentedViewController)
        [self.presentedViewController dismissViewControllerAnimated:YES completion:^{
            
        }];
    [button setEnabled:NO];
    RoomSettingViewController* roomSettingViewControler = [[RoomSettingViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [self.navigationController pushViewController:roomSettingViewControler animated:YES];
    [button setEnabled:YES];
    [[[EMClient sharedClient] conferenceManager] getConference:[EMDemoOption sharedOptions].conference.confId password:[EMDemoOption sharedOptions].roomPswd completion:^(EMCallConference *aCall, EMError *aError) {
        [EMDemoOption sharedOptions].conference.adminIds = [aCall.adminIds copy];
        [EMDemoOption sharedOptions].conference.memberCount = aCall.memberCount;
        [EMDemoOption sharedOptions].conference.speakerIds = [aCall.speakerIds copy];
        [EMDemoOption sharedOptions].conference.audiencesCount = aCall.audiencesCount;
        dispatch_async(dispatch_get_main_queue(), ^{
            [roomSettingViewControler.tableView reloadData];
        });
    }];
}

- (AVAudioSessionPortDescription*)bluetoothAudioDevice
{
    NSArray* bluetoothRoutes = @[AVAudioSessionPortBluetoothA2DP, AVAudioSessionPortBluetoothLE, AVAudioSessionPortBluetoothHFP];
    return [self audioDeviceFromTypes:bluetoothRoutes];
}

- (AVAudioSessionPortDescription*)builtinAudioDevice
{
    NSArray* builtinRoutes = @[AVAudioSessionPortBuiltInMic];
    return [self audioDeviceFromTypes:builtinRoutes];
}

- (AVAudioSessionPortDescription*)speakerAudioDevice
{
    NSArray* builtinRoutes = @[AVAudioSessionPortBuiltInSpeaker];
    return [self audioDeviceFromTypes:builtinRoutes];
}

- (AVAudioSessionPortDescription*)audioDeviceFromTypes:(NSArray*)types
{
    NSArray* routes = [[AVAudioSession sharedInstance] availableInputs];
    for(AVAudioSessionPortDescription* route in routes)
    {
        if ([types containsObject:route.portType])
        {
            return route;
        }
        
    }
    return nil;
}

- (BOOL)switchBluetooth:(BOOL)onOrOff
{
    NSError* audioError = nil;
    BOOL changeResult = NO;
    if(onOrOff)
    {
        AVAudioSessionPortDescription* _bluetoothPort = [self bluetoothAudioDevice];
        if(_bluetoothPort)
            changeResult = [[AVAudioSession sharedInstance] setPreferredInput:_bluetoothPort error:&audioError];
    }
    else
    {
        AVAudioSessionPortDescription* builtinPort = [self builtinAudioDevice];
        if(builtinPort)
            changeResult = [[AVAudioSession sharedInstance] setPreferredInput:builtinPort error:&audioError];
    }
    return changeResult;
}

-(void)selectDeviceAction
{
    __weak typeof(self) weakself = self;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"切换音频设备" message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *SpeakerAction = [UIAlertAction actionWithTitle:@"扬声器" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self switchBluetooth:NO];
        [weakself playWithSpeaker];
    }];
    [alertController addAction:SpeakerAction];

    UIAlertAction *IphoneAction = [UIAlertAction actionWithTitle:@"iPhone内置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self switchBluetooth:NO];
        
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord withOptions: AVAudioSessionCategoryOptionAllowBluetooth
                            error:nil];
        [audioSession setActive:YES error:nil];
    }];
    [alertController addAction:IphoneAction];
    
    if([self bluetoothAudioDevice] != nil) {
        UIAlertAction *BlueToothAction = [UIAlertAction actionWithTitle:@"蓝牙耳机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self switchBluetooth:YES];
        }];
        [alertController addAction:BlueToothAction];
    }

    [alertController addAction: [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", @"Cancel") style: UIAlertActionStyleCancel handler:nil]];

    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)showHint:(NSString *)hint
{
    UIView *view = [[UIApplication sharedApplication].delegate window];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.userInteractionEnabled = NO;
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.label.text = hint;
    hud.margin = 10.f;
    static int sHubCount = 0;
    hud.completionBlock = ^{
        sHubCount --;
    };
    hud.yOffset = sHubCount * 45;
    hud.removeFromSuperViewOnHide = YES;
    [hud hideAnimated:YES afterDelay:2];
    sHubCount++;
}

- (CGRect)getNewVideoViewFrame
{
    NSInteger count = [self.streamItemDict count];
    CGRect frame = CGRectMake(self.scrollView.bounds.origin.x + gSmallVideoSize*(count-1), self.scrollView.bounds.origin.y, gSmallVideoSize, gSmallVideoSize);
    
    return frame;
}
//设置视频界面
- (EMStreamItem *)setupNewStreamItemWithName:(NSString *)aName
                                 displayView:(UIView *)aDisplayView
                                      stream:(EMCallStream *)aStream
{
    CGRect frame;
    if([self.streamItemDict count] == 0 || !self.curBigView){
        frame = self.view.bounds;
    }
    else
        frame = [self getNewVideoViewFrame];
    
    EMStreamView *videoView = [[EMStreamView alloc] initWithFrame:frame];
    videoView.delegate = self;
    videoView.nameLabel.text = aName;
    if(aStream) {
        EMCallMember* member = [self.membersDict objectForKey:aStream.memberName];
        if(member && [member.nickname length] > 0)
        {
            if([member.nickname hasPrefix:[EMDemoOption sharedOptions].appkey])
                videoView.nickNameLabel.text = [member.nickname substringFromIndex:[[EMDemoOption sharedOptions].appkey length]+1];
            else
                videoView.nickNameLabel.text = member.nickname;
            NSData*jsonData = [member.ext dataUsingEncoding:NSUTF8StringEncoding];
            NSError *jsonError = nil;
            NSDictionary* extDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&jsonError];
            if(extDic) {
                NSString* headImage = [extDic objectForKey:@"headImage"];
                if([headImage length] > 0) {
                    NSString* imageurl = [NSString stringWithFormat:@"https://download-sdk.oss-cn-beijing.aliyuncs.com/downloads/RtcDemo/headImage/%@" ,headImage];
                    [videoView.bgView sd_setImageWithURL:[NSURL URLWithString:imageurl]];
                }
            }
        }else
        {
            videoView.nickNameLabel.text = aName;
        }
    }else {
        if([[EMDemoOption sharedOptions].nickName length] > 0)
            videoView.nickNameLabel.text = [EMDemoOption sharedOptions].nickName;
        else
            videoView.nickNameLabel.text = aName;
        if([[EMDemoOption sharedOptions].headImage length] > 0) {
            NSString* imageurl = [NSString stringWithFormat:@"https://download-sdk.oss-cn-beijing.aliyuncs.com/downloads/RtcDemo/headImage/%@" ,[EMDemoOption sharedOptions].headImage];
            [videoView.bgView sd_setImageWithURL:[NSURL URLWithString:imageurl]];
        }
    }
    videoView.displayView = aDisplayView;
    [videoView addSubview:aDisplayView];
    [videoView sendSubviewToBack:aDisplayView];
    
    [aDisplayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(videoView);
    }];
    if([self.streamItemDict count] == 0 || !self.curBigView)
    {
        self.curBigView = videoView;
        
        [self.view addSubview:self.curBigView];
        [self.view sendSubviewToBack:self.curBigView];
        [self updateCurBigViewFrame];
    }else
        [self.scrollView addSubview:videoView];
    
//    if (CGRectGetMaxY(frame) > self.scrollView.contentSize.height) {
//        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, CGRectGetMaxY(frame));
//    }
    
    EMStreamItem *retItem = [[EMStreamItem alloc] init];
    retItem.videoView = videoView;
    retItem.stream = aStream;
    if ([aStream.streamId length] > 0) {
        [self.streamItemDict setObject:retItem forKey:aStream.streamId];
        [self.streamIds addObject:aStream.streamId];
    }
    
    return retItem;
}
#pragma mark - Stream
//摄像头上传视频设置
- (void)pubLocalStreamWithEnableVideo:(BOOL)aEnableVideo
                           completion:(void (^)(NSString *aPubStreamId, EMError *aError))aCompletionBlock
{
    //上传流的过程中，不允许操作视频按钮
    self.videoButton.enabled = NO;
    self.topVC.switchCameraButton.enabled = NO;
    
    EMStreamParam *pubConfig = [[EMStreamParam alloc] init];
    pubConfig.streamName = [EMClient sharedClient].currentUsername;
    pubConfig.enableVideo = NO;
    pubConfig.isMute = ![EMDemoOption sharedOptions].openMicrophone;
    
    EMCallOptions *options = [[EMClient sharedClient].callManager getCallOptions];
    pubConfig.maxAudioKbps = (int)options.maxAudioKbps;
    switch ([EMDemoOption sharedOptions].resolutionrate) {
        case ResolutionRate_720p:
            pubConfig.videoResolution = EMCallVideoResolution1280_720;
            break;
        case ResolutionRate_360p:
            pubConfig.videoResolution = EMCallVideoResolution352_288;
            break;
        case ResolutionRate_480p:
            pubConfig.videoResolution = EMCallVideoResolution640_480;
            break;
        default:
            pubConfig.videoResolution = options.videoResolution;
            break;
    }

    pubConfig.isBackCamera = [EMDemoOption sharedOptions].isBackCamera;

    EMCallLocalView *localView = [[EMCallLocalView alloc] init];
    //视频通话页面缩放方式
    localView.scaleMode = EMCallViewScaleModeAspectFit;
    //显示本地视频的页面
    pubConfig.localView = localView;
    
    __weak typeof(self) weakself = self;
    void(^block)(NSString *aPubStreamId, EMError *aError) = ^(NSString *aPubStreamId, EMError *aError){
        if (aError) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"错误" message:@"上传本地视频流失败，请重试" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                        [alertView show];
                        
                        if (aCompletionBlock) {
                            aCompletionBlock(nil, aError);
                        }
                        
                        return ;
                        
                        //TODO: 后续处理是怎么样的
                    }
                    
                    if(aEnableVideo) {
                        [[EMClient sharedClient].conferenceManager updateConference:[EMDemoOption sharedOptions].conference enableVideo:aEnableVideo];
                    }
                    weakself.videoButton.enabled = YES;
                    weakself.videoButton.selected = aEnableVideo;
                    weakself.microphoneButton.selected = [EMDemoOption sharedOptions].openMicrophone;
                    weakself.isSetMute = pubConfig.isMute;
                    [weakself updateMicrophoneLable];
                    [weakself updateVidelLable];
            weakself.topVC.switchCameraButton.enabled = aEnableVideo;
            
                    weakself.pubStreamId = aPubStreamId;
                    //设置视频界面
                    EMStreamItem *videoItem = [self setupNewStreamItemWithName:pubConfig.streamName displayView:localView stream:nil];
                    videoItem.videoView.enableVideo = aEnableVideo;
                    videoItem.videoView.enableVoice = [EMDemoOption sharedOptions].openMicrophone;
                    [weakself.streamItemDict setObject:videoItem forKey:aPubStreamId];
                    [weakself.streamIds addObject:aPubStreamId];
            
                    if (aCompletionBlock) {
                        aCompletionBlock(aPubStreamId, nil);
                    }
    };
    //上传本地摄像头的数据流
    [[EMClient sharedClient].conferenceManager publishConference:[EMDemoOption sharedOptions].conference streamParam:pubConfig completion:block];
}
//
- (void)_subStream:(EMCallStream *)aStream
{
    EMCallRemoteView *remoteView = [[EMCallRemoteView alloc] init];
    remoteView.scaleMode = EMCallViewScaleModeAspectFit;
    EMStreamItem *videoItem = nil;
    if(aStream.type != EMStreamTypeDesktop) {
        videoItem = [self setupNewStreamItemWithName:aStream.userName displayView:remoteView stream:aStream];
        videoItem.videoView.enableVideo = aStream.enableVideo;
    }
    
    
    __weak typeof(self) weakSelf = self;
    //订阅其他人的数据流，，即订阅当前会议上麦主播的数据流
    [[EMClient sharedClient].conferenceManager subscribeConference:[EMDemoOption sharedOptions].conference streamId:aStream.streamId remoteVideoView:remoteView completion:^(EMError *aError) {
        if (aError) {
            NSString *message = [NSString stringWithFormat:NSLocalizedString(@"alert.conference.subFail", @"Sub stream-%@ failed!"), aStream.userName];
            [weakSelf showHint:message];
            [weakSelf.streamItemDict removeObjectForKey:aStream.streamId];
            return ;
        }
        if(aStream.type == EMStreamTypeDesktop){
            self.remoteDesktopStreamId = aStream.streamId;
            self.remoteDesktopView = [[EMStreamView alloc] init];
            self.remoteDesktopView.displayView = remoteView;
            [self.remoteDesktopView addSubview:remoteView];
            [remoteView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.remoteDesktopView);
            }];
            self.remoteDesktopView.enableVideo = YES;
            self.sharedDesktopVC = [[SharedDesktopViewController alloc] initWithSharedDesktopView:self.remoteDesktopView];
            [self.navigationController pushViewController:self.sharedDesktopVC animated:NO];
            return;
        }
        if(videoItem) {
            videoItem.videoView.enableVoice = aStream.enableVoice;
            [weakSelf updateAdminView];
        }
    }];
}

- (void)updateCurBigViewFrame
{
    if(self.curBigView != nil){
        if([self.curBigView.displayView isKindOfClass:[EMCallRemoteView class]])
        {
            EMCallRemoteView*view = (EMCallRemoteView*)self.curBigView.displayView;
            view.scaleMode = EMCallViewScaleModeAspectFit;
        }
        if([self.curBigView.displayView isKindOfClass:[EMCallLocalView class]])
        {
            EMCallLocalView*view = (EMCallLocalView*)self.curBigView.displayView;
            view.scaleMode = EMCallViewScaleModeAspectFill;
        }
        [self.curBigView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self.view);
            make.height.equalTo(self.view);
        }];
    }
}

- (void)removeStreamWithId:(NSString *)aStreamId
{
    NSInteger index = [self.streamIds indexOfObject:aStreamId];
    
    EMStreamItem *removeItem = [self.streamItemDict objectForKey:aStreamId];
    CGRect prevFrame = removeItem.videoView.frame;
    [removeItem.videoView.displayView removeFromSuperview];
    [removeItem.videoView removeFromSuperview];
    if(removeItem.videoView == self.curBigView){
        self.curBigView = nil;
    }
    
    for (NSInteger i = index + 1; i < [self.streamIds count]; i++) {
        NSString *streamId = [self.streamIds objectAtIndex:i];
        EMStreamItem *item = [self.streamItemDict objectForKey:streamId];
        if (self.curBigView == item.videoView) {
            self.curBigView = nil;
        } else {
            CGRect frame = item.videoView.frame;
            item.videoView.frame = prevFrame;
            prevFrame = frame;
        }
    }
    
    [self.streamIds removeObjectAtIndex:index];
    [self.streamItemDict removeObjectForKey:aStreamId];
}

#pragma mark - EMStreamViewDelegate

- (void)streamViewDidTap:(EMStreamView *)aVideoView
{
    if (aVideoView == _curBigView) {
        return;
    }
    
    EMStreamView* curbigview = self.curBigView;
    if(curbigview)
    {
        [curbigview removeFromSuperview];
        //curbigview.frame = aVideoView.frame;
        
        curbigview.frame = CGRectMake(aVideoView.frame.origin.x, aVideoView.frame.origin.y, gSmallVideoSize, gSmallVideoSize);
        //curbigview.displayView.frame = aVideoView.displayView.frame;
        [self.scrollView addSubview:curbigview];
    }
    
    [aVideoView removeFromSuperview];
    self.curBigView = aVideoView;
    [self.view addSubview:self.curBigView];
    [self.view sendSubviewToBack:self.curBigView];
//    [aVideoView.displayView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(self.view);
//    }];
    self.curBigView.frame = self.view.frame;
    self.curBigView.displayView.frame = self.view.frame;
//    if([self.curBigView.displayView isKindOfClass:[EMCallRemoteView class]]){
//        EMCallRemoteView*view = (EMCallRemoteView*)self.curBigView.displayView;
//        view.scaleMode = EMCallViewScaleModeAspectFit;
//    }
    [self updateScrollView];
    [self updateCurBigViewFrame];
}

-(void)updateScrollViewPos
{
    if(_tableView.hidden){
        if(_scrollView.bounds.size.height == gSmallVideoSize) {
            [_scrollView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(self.view);
                make.height.equalTo(@(gSmallVideoSize));
                make.left.equalTo(self.view);
                make.bottom.equalTo(self.view);
            }];
        }else{
            [_scrollView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.height.equalTo(self.view);
                make.width.equalTo(@(gSmallVideoSize));
                make.right.equalTo(self.view);
                make.bottom.equalTo(self.view);
            }];
        }
        
    }else{
        if(_scrollView.bounds.size.height == gSmallVideoSize) {
            [_scrollView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(self.view);
                make.height.equalTo(@(gSmallVideoSize));
                make.left.equalTo(self.view);
                make.bottom.equalTo(self.view).with.offset(-gBottomMenuHeight);
            }];
        }else{
            [_scrollView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.height.equalTo(self.view);
                make.width.equalTo(@(gSmallVideoSize));
                make.right.equalTo(self.view);
                make.bottom.equalTo(self.view);
            }];
        }
    }
}

#pragma mark - EMConferenceManagerDelegate

- (void)memberDidJoin:(EMCallConference *)aConference
               member:(EMCallMember *)aMember
{
    if ([aConference.callId isEqualToString: [EMDemoOption sharedOptions].conference.callId]) {
        [self.membersDict setObject:aMember forKey:aMember.memberName];
        NSString *message = [NSString stringWithFormat:@"%@ 加入会议", aMember.nickname];
        [self showHint:message];
    }
}

- (void)memberDidLeave:(EMCallConference *)aConference
                member:(EMCallMember *)aMember
{
    if ([aConference.callId isEqualToString:[EMDemoOption sharedOptions].conference.callId]) {
        [self.membersDict removeObjectForKey:aMember.memberName];
        NSString *message = [NSString stringWithFormat:@"%@ 离开会议", aMember.nickname];
        [self showHint:message];
    }
}
//有新的数据流上传
- (void)streamDidUpdate:(EMCallConference *)aConference
              addStream:(EMCallStream *)aStream
{
    if ([aConference.callId isEqualToString:[EMDemoOption sharedOptions].conference.callId]) {
        [self _subStream:aStream];
        __weak typeof(self) weakself = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself updateScrollView];
            [weakself updateVideoSub];
        });
    }
}

- (void)streamDidUpdate:(EMCallConference *)aConference
           removeStream:(EMCallStream *)aStream
{
    if ([aConference.callId isEqualToString:[EMDemoOption sharedOptions].conference.callId]) {
        [[[EMClient sharedClient] conferenceManager] unsubscribeConference:[EMDemoOption sharedOptions].conference streamId:aStream.streamId completion:^(EMError *aError) {
            
        }];
        if(aStream.type == EMStreamTypeDesktop){
            UIViewController* curVC = [self.navigationController topViewController];
            if(self.sharedDesktopVC){
                [self.sharedDesktopVC dismissViewControllerAnimated:NO completion:^{
                    
                }];
                if([curVC isKindOfClass:[SharedDesktopViewController class]]){
                    [self.navigationController popViewControllerAnimated:NO];
                }
            }
            
            self.remoteDesktopView = nil;
            return;
        }
        [self removeStreamWithId:aStream.streamId];
        __weak typeof(self) weakself = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself updateScrollView];
            [weakself updateVideoSub];
        });
        if([EMDemoOption sharedOptions].conference.isCreator && [EMDemoOption sharedOptions].openCDN)
            [weakself _upadteLiveRegions];
    }
}

- (void)adminDidChanged:(EMCallConference *)aConference
               newAdmin:(NSString*)adminmemid
{
    if ([aConference.callId isEqualToString:[EMDemoOption sharedOptions].conference.callId]) {
        NSString* showName = adminmemid;
        NSString* adminName = nil;
        for(NSString* memName in self.membersDict) {
            EMCallMember* member = [self.membersDict objectForKey:memName];
            if(member && [member.memberId isEqualToString:adminmemid]) {
                if([member.nickname length] > 0)
                    showName = member.nickname;
                else
                    showName = member.memberName;
                adminName = memName;
                break;
            }
        }
        
//        if([adminName length] > 0)
//        {
//            [EMDemoOption sharedOptions].conference.adminIds = [[EMDemoOption sharedOptions].conference.adminIds arrayByAddingObject:adminName];
//        }
        
        NSString* msg = [NSString stringWithFormat:@"%@ 成为主持人",showName ];
        [EMAlertController showInfoAlert:msg];
        
        UIViewController* topVC = self.navigationController.topViewController;
        __weak typeof(self) weakself = self;
        if(topVC && ([topVC isKindOfClass:[RoomSettingViewController class]] || [topVC isKindOfClass:[SpeakerListViewController class]])) {
            [[[EMClient sharedClient] conferenceManager] getConference:[EMDemoOption sharedOptions].conference.confId password:[EMDemoOption sharedOptions].roomPswd completion:^(EMCallConference *aCall, EMError *aError) {
                [EMDemoOption sharedOptions].conference.adminIds = [aCall.adminIds copy];
                [EMDemoOption sharedOptions].conference.memberCount = aCall.memberCount;
                [EMDemoOption sharedOptions].conference.speakerIds = [aCall.speakerIds copy];
                [EMDemoOption sharedOptions].conference.audiencesCount = aCall.audiencesCount;
                [weakself updateAdminView];
                UITableViewController* tableVC = (UITableViewController*)topVC;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [tableVC.tableView reloadData];
                });
            }];
            
        }
    }
}

- (void)adminDidChanged:(EMCallConference *)aConference
            removeAdmin:(NSString*)adminmemid
{
    if ([aConference.callId isEqualToString:[EMDemoOption sharedOptions].conference.callId]) {
        NSString* showName = adminmemid;
        NSString* adminName = nil;
        for(NSString* memName in self.membersDict) {
            EMCallMember* member = [self.membersDict objectForKey:memName];
            if(member && [member.memberId isEqualToString:adminmemid]) {
                if([member.nickname length] > 0)
                    showName = member.nickname;
                else
                    showName = member.memberName;
                adminName = memName;
                break;
            }
        }
        
        NSMutableArray* adminIds = [[EMDemoOption sharedOptions].conference.adminIds mutableCopy];
        [adminIds removeObject:adminName];
        [EMDemoOption sharedOptions].conference.adminIds = [adminIds copy];
        NSString* msg = [NSString stringWithFormat:@"%@ 放弃主持人",showName ];
        [EMAlertController showInfoAlert:msg];
        [self updateAdminView];
        UIViewController* topVC = self.navigationController.topViewController;
        if(topVC && ([topVC isKindOfClass:[RoomSettingViewController class]] || [topVC isKindOfClass:[SpeakerListViewController class]])) {
            UITableViewController* tableVC = (UITableViewController*)topVC;
            dispatch_async(dispatch_get_main_queue(), ^{
                [tableVC.tableView reloadData];
            });
        }
    }
}

- (void)streamPubDidFailed:(EMCallConference *)aConference error:(EMError*)aError
{
    if ([aConference.callId isEqualToString:[EMDemoOption sharedOptions].conference.callId]) {
        self.topVC.switchCameraButton.enabled = NO;
        self.microphoneButton.enabled = NO;
        self.videoButton.enabled = NO;
        
        [self removeStreamWithId:self.pubStreamId];
        self.pubStreamId = nil;
        [self updateScrollView];
        NSString* msg = [NSString stringWithFormat:@"Pub流失败：%@",aError.errorDescription ];
        [EMAlertController showInfoAlert:msg];
        if(aError.code == EMErrorCallVideoFull) {
            [self pubLocalStreamWithEnableVideo:NO completion:^(NSString *aPubStreamId, EMError *aError) {
                self.pubStreamId = aPubStreamId;
            }];
        }
    }
}

- (void)DesktopStreamDidPubFailed:(EMCallConference *)aConference error:(EMError*)aError
{
    if ([aConference.callId isEqualToString:[EMDemoOption sharedOptions].conference.callId]) {
        NSString* msg = [NSString stringWithFormat:@"Pub共享桌面失败：%@",aError.errorDescription ];
        [_timeRecord invalidate];
        _timeRecord = nil;
        __weak typeof(self) weakself = self;
        [[[EMClient sharedClient] conferenceManager] unpublishConference:[EMDemoOption sharedOptions].conference streamId:weakself.desktopStreamId completion:^(EMError *aError) {
            if(weakself.desktopStreamId != nil)
                [weakself.myStreamIds removeObjectForKey:weakself.desktopStreamId];
            weakself.desktopStreamId = nil;
        }
        ];
        [EMAlertController showInfoAlert:msg];
    }
}
- (void)streamUpdateDidFailed:(EMCallConference *)aConference error:(EMError *)aError
{
    if ([aConference.callId isEqualToString:[EMDemoOption sharedOptions].conference.callId]) {
        if(aError.code == EMErrorCallVideoFull) {
            [self videoButtonAction];
            NSString* msg = [NSString stringWithFormat:@"打开视频流失败：%@",aError.errorDescription ];
            [EMAlertController showInfoAlert:msg];
        }
    }
}

- (void)conferenceDidEnd:(EMCallConference *)aConference
                  reason:(EMCallEndReason)aReason
                   error:(EMError *)aError
{
    if ([aConference.callId isEqualToString:[EMDemoOption sharedOptions].conference.callId]) {
        __weak typeof(self) weakself = self;
        dispatch_async(dispatch_get_main_queue(), ^{
//            NSString* msg = @"会议已关闭";
//            if(aReason == EMCallEndReasonBeenkicked)
//                msg = @"你被踢出会议";
//            [EMAlertController showInfoAlert:msg];
            
            [weakself _hangup:NO];
        });
        
    }
}
//数据流有更新（是否静音，视频是否可用）(有人静音自己/关闭视频)
- (void)streamDidUpdate:(EMCallConference *)aConference
                 stream:(EMCallStream *)aStream
{
    if (![aConference.callId isEqualToString:[EMDemoOption sharedOptions].conference.callId] || aStream == nil) {
        return;
    }
    
    EMStreamItem *videoItem = [self.streamItemDict objectForKey:aStream.streamId];
    if (!videoItem.stream) {
        return;
    }
    
    if (videoItem.stream.enableVideo != aStream.enableVideo) {
        videoItem.videoView.enableVideo = aStream.enableVideo;
        if([self _isVideoViewShow:videoItem.videoView]){
            if(aStream.enableVideo) {
                [self.showStreamViewInScrollView setObject:videoItem forKey:aStream.streamId];
            }else
                if([self.showStreamViewInScrollView objectForKey:aStream.streamId]) {
                    [self.showStreamViewInScrollView removeObjectForKey:aStream.streamId];
                }
            
        }
        
    }
    
    if (videoItem.stream.enableVoice != aStream.enableVoice) {
        videoItem.videoView.enableVoice = aStream.enableVoice;
    }
    
    videoItem.stream = aStream;
    if([self.navigationController.topViewController isKindOfClass:[SpeakerListViewController class]]) {
        SpeakerListViewController*sVC = (SpeakerListViewController*)self.navigationController.topViewController;
        [sVC.tableView reloadData];
    }
}
//数据流已经开始传输数据
- (void)streamStartTransmitting:(EMCallConference *)aConference
                       streamId:(NSString *)aStreamId
{
    if ([aConference.callId isEqualToString:[EMDemoOption sharedOptions].conference.callId]) {
        EMStreamItem *videoItem = [self.streamItemDict objectForKey:aStreamId];
        if (videoItem && videoItem.videoView) {
            videoItem.videoView.status = StreamStatusConnected;
        }
        if([EMDemoOption sharedOptions].conference.isCreator && [EMDemoOption sharedOptions].openCDN)
            [self _upadteLiveRegions];
        if ([aStreamId isEqualToString:self.remoteDesktopStreamId] && self.sharedDesktopVC) {
            self.remoteDesktopView.status = StreamStatusConnected;
        }
        
//        if (!self.microphoneButton.isSelected && self.videoButton.isSelected && !self.isSetSpeaker) {
//            self.isSetSpeaker = YES;
//            [self playWithSpeaker];
//        }
    }
}

- (void)conferenceNetworkDidChange:(EMCallConference *)aSession
                            status:(EMCallNetworkStatus)aStatus
{
    NSString *str = @"";
    switch (aStatus) {
        case EMCallNetworkStatusNormal:
            
            break;
        case EMCallNetworkStatusUnstable:
            
            break;
        case EMCallNetworkStatusNoData:
            
            break;
            
        default:
            break;
    }
    if ([str length] > 0) {
        [self showHint:str];
    }
}
- (void)streamIdDidUpdate:(EMCallConference*)aConference rtcId:(NSString*)rtcId streamId:(NSString*)streamId
{
    if (![aConference.callId isEqualToString:[EMDemoOption sharedOptions].conference.callId]) {
        return;
    }
    
    [self.myStreamIds setObject:streamId forKey:rtcId];
}

- (void)streamStateUpdated:(EMCallConference*)aConference type:(EMMediaType)aType state:(EMMediaState)state streamId:(NSString*)streamId
{
    if (![aConference.callId isEqualToString:[EMDemoOption sharedOptions].conference.callId]) {
        return;
    }
    NSString* type = @"音频";
    if(aType == EMMediaTypeVideo)
        type = @"视频";
    NSString* dataState = @"无数据";
    if(state == EMMediaStateNormal) {
        dataState = @"正常";
    }
    NSString* aStream = streamId;
    if([streamId length] > 0) {
        EMStreamItem* stream = [self.streamItemDict objectForKey:streamId];
        if(stream) {
            NSString* memberName = stream.stream.memberName;
            EMCallMember* member = [self.membersDict objectForKey:memberName];
            if(member) {
                if([member.nickname length] > 0) {
                    aStream = member.nickname;
                }
            }else{
                aStream = memberName;
            }
        }
    }
    NSString *message = [NSString stringWithFormat:@"流%@ %@通信%@", aStream,type,dataState];
    [self showHint:message];
}

- (void)confrenceDidUpdated:(EMCallConference*)aConference state:(EMConferenceState)aState
{
}

//用户A用户B在同一个会议中，用户A开始说话时，用户B会收到该回调
- (void)conferenceSpeakerDidChange:(EMCallConference *)aConference
                 speakingStreamIds:(NSArray *)aStreamIds
{
    if (![aConference.callId isEqualToString:[EMDemoOption sharedOptions].conference.callId]) {
        return;
    }
    
    for (NSString *streamId in aStreamIds) {
        EMStreamItem *videoItem = [self.streamItemDict objectForKey:streamId];
        if (videoItem && videoItem.videoView) {
            videoItem.videoView.status = StreamStatusTalking;
        }
        
        [self.talkingStreamIds removeObject:streamId];
    }
    
    for (NSString *streamId in self.talkingStreamIds) {
        EMStreamItem *videoItem = [self.streamItemDict objectForKey:streamId];
        if (videoItem && videoItem.videoView) {
            videoItem.videoView.status = StreamStatusNormal;
        }
    }
    [self.talkingStreamIds removeAllObjects];
    if(aStreamIds)
        self.talkingStreamIds = [aStreamIds mutableCopy];
}

- (void)conferenceDidUpdated:(EMCallConference *)aConference
                     muteAll:(BOOL)aMuteAll
{
    if([EMDemoOption sharedOptions].conference.role == EMConferenceRoleSpeaker) {
        __weak typeof(self) weakself = self;
        [EMDemoOption sharedOptions].muteAll = aMuteAll;
           dispatch_async(dispatch_get_main_queue(), ^{
               [weakself muteUI:aMuteAll];
           });
    }
}

- (void)conferenceReqSpeaker:(EMCallConference*)aConference
                       memId:(NSString*)aMemId
                    nickName:(NSString*)nickName
                     memName:(NSString*)aMemName
{
    __weak typeof(self) weakself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString * message = [nickName stringByAppendingString:@" 申请主播"];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[[EMClient sharedClient] conferenceManager] changeMemberRoleWithConfId:[EMDemoOption sharedOptions].conference.confId memberName:aMemName role:EMConferenceRoleSpeaker completion:^(EMError *aError) {
                if(aError){
                    if(aError.code == EMErrorCallSpeakerFull) {
                        UIAlertController* alert2 = [UIAlertController alertControllerWithTitle:@"" message:@"主播已满，选人下麦？" preferredStyle:UIAlertControllerStyleAlert];
                        [alert2 addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                            //弹出ViewController
                            KickSpeakerViewController *xVC = [[KickSpeakerViewController alloc] init];
                            xVC.view.frame = CGRectMake(0, 200, self.view.bounds.size.width, self.view.bounds.size.height-200);
                            [xVC setNewSpeaker:aMemName memId:aMemId];
                            [weakself presentViewController:xVC animated:YES completion:^{
                                }];
                        }]];
                        [alert2 addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                            [[[EMClient sharedClient] conferenceManager] responseReqAdmin:aConference memId:aMemId result:1 completion:^(EMError *aError) {
                                if(aError) {
                                    [EMAlertController showErrorAlert:@"操作失败"];
                                }
                            }];
                        }]];
                        [weakself presentViewController:alert2 animated:YES completion:nil];
                    }else
                        [EMAlertController showErrorAlert:@"操作失败"];
                }else{
                    [[[EMClient sharedClient] conferenceManager] responseReqSpeaker:aConference memId:aMemId result:0 completion:^(EMError *aError) {
                        if(aError) {
                            [EMAlertController showErrorAlert:@"操作失败"];
                        }
                    }];
                }
            }];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [[[EMClient sharedClient] conferenceManager] responseReqAdmin:aConference memId:aMemId result:1 completion:^(EMError *aError) {
                if(aError) {
                    [EMAlertController showErrorAlert:@"操作失败"];
                }
            }];
        }]];
        [weakself presentViewController:alert animated:YES completion:nil];
    });
}

- (void)conferenceReqAdmin:(EMCallConference*)aConference
                     memId:(NSString*)aMemId
                  nickName:(NSString*)nickName
                   memName:(NSString*)aMemName
{
    __weak typeof(self) weakself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString * message = [nickName stringByAppendingString:@" 申请主持人"];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[[EMClient sharedClient] conferenceManager] changeMemberRoleWithConfId:[EMDemoOption sharedOptions].conference.confId memberName:aMemName role:EMConferenceRoleAdmin completion:^(EMError *aError) {
                if(aError){
                    [EMAlertController showErrorAlert:@"操作失败"];
                }else{
                    [[[EMClient sharedClient] conferenceManager] responseReqAdmin:aConference memId:aMemId result:0 completion:^(EMError *aError) {
                        if(aError) {
                            [EMAlertController showErrorAlert:@"操作失败"];
                        }
                    }];
                }
            }];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [[[EMClient sharedClient] conferenceManager] responseReqAdmin:aConference memId:aMemId result:1 completion:^(EMError *aError) {
                if(aError) {
                    [EMAlertController showErrorAlert:@"操作失败"];
                }
            }];
        }]];
        [weakself presentViewController:alert animated:YES completion:nil];
    });
}

- (void)conferenceDidUpdated:(EMCallConference*)aConference liveCfg:(NSDictionary*) aLiveConfig
{
    
}

- (void)muteUI:(BOOL)aMute
{
    self.microphoneButton.selected = !aMute;
    if ([self.pubStreamId length] > 0) {
        EMStreamItem *videoItem = [self.streamItemDict objectForKey:self.pubStreamId];
        if (videoItem) {
            videoItem.videoView.enableVoice = self.microphoneButton.isSelected;
        }
    }
     
    
    if (!self.microphoneButton.isSelected && self.videoButton.isSelected) {
        [self playWithSpeaker];
    }
    [self updateMicrophoneLable];
    UIViewController* view = [self.navigationController topViewController];
    if([view isKindOfClass:[SpeakerListViewController class]]) {
        SpeakerListViewController* speakerVC = (SpeakerListViewController*)view;
        [speakerVC.tableView reloadData];
    }
}

- (void)conferenceDidUpdated:(EMCallConference *)aConference mute:(BOOL)aMute
{
    if([EMDemoOption sharedOptions].conference.role > EMConferenceRoleAudience){
        __weak typeof(self) weakself = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself muteUI:aMute];
        });
    }
}

- (void)conferenceReqSpeakerRefused:(EMCallConference*)aConference adminId:(NSString*)aAdminId
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [EMAlertController showErrorAlert:@"上麦申请被拒绝"];
    });
}

- (void)conferenceReqAdminRefused:(EMCallConference*)aConference adminId:(NSString*)aAdminId
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [EMAlertController showErrorAlert:@"主持人申请被拒绝"];
    });
}

- (void)conferenceAttributeUpdated:(EMCallConference *)aConference
                        attributes:(NSArray <EMConferenceAttribute *>*)attrs
{
    for(EMConferenceAttribute * attr in attrs){
        if(attr.action == EMConferenceAttributeDelete && [attr.key isEqualToString:@"whiteBoard"]) {
            if([[self.navigationController topViewController] isKindOfClass:[WhiteBoardViewController class]]) {
                WhiteBoardViewController* vc = (WhiteBoardViewController *)[self.navigationController topViewController];
                [vc back];
            }
            self.whiteBoard = nil;
            [EMAlertController showInfoAlert:@"互动白板已结束"];
        }else{
            if([attr.key isEqualToString:@"whiteBoard"]) {
                NSError *jsonError = nil;
                NSData* data = [attr.value dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *dictFromData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
                if(dictFromData) {
                    if(!self.whiteBoard) {
                        NSString* wbName = [dictFromData objectForKey:@"roomName"];
                        NSString* wbPswd = [dictFromData objectForKey:@"roomPswd"];
                        self.wbCreator = [dictFromData objectForKey:@"creator"];
                        [self _joinWhiteBoardWithName:wbName password:wbPswd];
                    }
                }
            }
        }
    }
}

- (void)conferenceDidUpdate:(EMCallConference*)aConference
                   streamId:(NSString*)streamId
                 statReport:(EMRTCStatsReport *)aReport
{
    if(aReport) {
//        NSLog(@"video bps:%d",aReport.localVideoActualBps);
//        NSLog(@"width:%d,height:%d",aReport.localCaptureWidth,aReport.localCaptureHeight);
//        NSLog(@"encodewidth:%d,encodeheight:%d,fps:%d",aReport.localEncodedWidth,aReport.localEncodedHeight,aReport.localEncodedFps);
//        NSLog(@"target bps:%d",aReport.localVideoTargetBps);
    }
}

- (void)roleDidChanged:(EMCallConference *)aConference
{
    __weak typeof(self) weakself = self;
    if (aConference.role == EMConferenceRoleSpeaker) {
        if([self.pubStreamId length] == 0) {
            [self pubLocalStreamWithEnableVideo:[EMDemoOption sharedOptions].openCamera completion:^(NSString *aPubStreamId, EMError *aError) {
                //[weakself _updateViewsAfterPubWithEnableVideo:YES error:aError];
                //weakself.vkbpsButton.enabled = YES;
                if([weakself.presentedViewController isKindOfClass:[MoreOptionViewController class]]) {
                    MoreOptionViewController*vc = (MoreOptionViewController*)weakself.presentedViewController;
                    vc.roleLable.text = @"下麦";
                    [vc.roleButton setImage:[UIImage imageNamed:@"下麦"] forState:UIControlStateNormal];
                    [vc.roleButton setTintColor:[UIColor redColor]];
                }

                weakself.videoButton.enabled = YES;
                weakself.microphoneButton.enabled = YES;
                weakself.topVC.switchCameraButton.enabled = YES;
                [weakself updateScrollView];
                [weakself updateVideoSub];
            }];
        }
        NSMutableArray* adminIds = [[EMDemoOption sharedOptions].conference.adminIds mutableCopy];
        [adminIds removeObject:[NSString stringWithFormat:@"%@_%@",[EMDemoOption sharedOptions].appkey,[EMDemoOption sharedOptions].userid]];
        [EMDemoOption sharedOptions].conference.adminIds = [adminIds copy];
    } else if (aConference.role == EMConferenceRoleAudience) {
        self.topVC.switchCameraButton.enabled = NO;
        self.microphoneButton.enabled = NO;
        self.videoButton.enabled = NO;
        //self.vkbpsButton.enabled = NO;
//        [self.roleButton setImage:[UIImage imageNamed:@"上麦"] forState:UIControlStateNormal];
//        self.roleLable.text = @"上麦";
//        [self.roleButton setTintColor:[UIColor whiteColor]];
        if([self.pubStreamId length] > 0)
        {
            [[EMClient sharedClient].conferenceManager unpublishConference:[EMDemoOption sharedOptions].conference streamId:self.pubStreamId completion:^(EMError *aError) {
                [weakself.myStreamIds removeObjectForKey:weakself.pubStreamId];
                weakself.topVC.switchCameraButton.enabled = NO;
                weakself.microphoneButton.enabled = NO;
                weakself.videoButton.enabled = NO;
                
                [weakself removeStreamWithId:weakself.pubStreamId];
                weakself.pubStreamId = nil;
                [weakself updateScrollView];
                [weakself updateVideoSub];
                if([EMDemoOption sharedOptions].conference.isCreator && [EMDemoOption sharedOptions].openCDN)
                    [weakself _upadteLiveRegions];
            }];
        }
        if([self.desktopStreamId length] > 0){
            [[EMClient sharedClient].conferenceManager unpublishConference:[EMDemoOption sharedOptions].conference streamId:self.desktopStreamId completion:^(EMError *aError) {
                weakself.desktopStreamId = nil;
                if(weakself.timeRecord){
                    [weakself.timeRecord invalidate];
                    weakself.timeRecord = nil;
                }
                if([EMDemoOption sharedOptions].conference.isCreator && [EMDemoOption sharedOptions].openCDN)
                    [weakself _upadteLiveRegions];
            }];
        }
        NSMutableArray* adminIds = [[EMDemoOption sharedOptions].conference.adminIds mutableCopy];
        [adminIds removeObject:[NSString stringWithFormat:@"%@_%@",[EMDemoOption sharedOptions].appkey,[EMDemoOption sharedOptions].userid]];
        [EMDemoOption sharedOptions].conference.adminIds = [adminIds copy];
    }else if(aConference.role == EMConferenceRoleAdmin){
//        [[[EMClient sharedClient] conferenceManager] setConferenceAttribute:[EMDemoOption sharedOptions].userid value:@"become_admin" completion:^(EMError *aError) {
//            if(aError){
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [EMAlertController showErrorAlert:@"主持人变更广播失败"];
//                });
//            }
//        }];
        NSString* memName = [NSString stringWithFormat:@"%@_%@",[EMDemoOption sharedOptions].appkey,[EMDemoOption sharedOptions].userid ];
        if(![[EMDemoOption sharedOptions].conference.adminIds containsObject:memName]) {
            [EMDemoOption sharedOptions].conference.adminIds = [[EMDemoOption sharedOptions].conference.adminIds arrayByAddingObject:memName];
        }
        [self updateAdminView];
        UIViewController* topVC = self.navigationController.topViewController;
        if(topVC && ([topVC isKindOfClass:[RoomSettingViewController class]] || [topVC isKindOfClass:[SpeakerListViewController class]])) {
            UITableViewController* tableVC = (UITableViewController*)topVC;
            dispatch_async(dispatch_get_main_queue(), ^{
                [tableVC.tableView reloadData];
            });
        }
    }
}

-(BOOL)_isVideoViewShow:(EMStreamView*)view
{
    if(view == self.curBigView)
        return YES;
    CGRect rect = CGRectMake(self.scrollView.contentOffset.x, self.scrollView.contentOffset.y, self.scrollView.contentSize.width, self.scrollView.contentSize.height);
    if(view.frame.origin.x >= (rect.origin.x + rect.size.width) || (view.frame.origin.x + view.frame.size.width) <= rect.origin.x)
        return NO;
    if(view.frame.origin.y >= (rect.origin.y + rect.size.height) || (view.frame.origin.y + view.frame.size.height) <= rect.origin.y)
        return NO;
    return YES;
}

-(void)updateVideoSub
{
    NSMutableDictionary *curShowViews = [NSMutableDictionary dictionary];
    for(NSString* key in self.streamItemDict){
        EMStreamItem* item = [self.streamItemDict objectForKey:key];
        if(item.stream && item.stream.enableVideo) {
            if([self _isVideoViewShow:item.videoView])
                [curShowViews setObject:item forKey:item.stream.streamId];
        }
        
    }
    if(self.showStreamViewInScrollView) {
        for (NSString* streamId in curShowViews) {
            if([self.showStreamViewInScrollView objectForKey:streamId]) {
                [self.showStreamViewInScrollView removeObjectForKey:streamId];
            }else{
                EMStreamItem* item = [curShowViews objectForKey:streamId];
                [[[EMClient sharedClient] conferenceManager] updateConference:[EMDemoOption sharedOptions].conference streamId:streamId remoteVideoView:item.videoView.displayView completion:^(EMError *aError) {
                    
                }];
            }
        }
        for(NSString* streamId in self.showStreamViewInScrollView) {
            EMStreamItem* item = [curShowViews objectForKey:streamId];
            [[[EMClient sharedClient] conferenceManager] updateConference:[EMDemoOption sharedOptions].conference streamId:streamId remoteVideoView:nil completion:^(EMError *aError) {
                
            }];
        }
    }
    self.showStreamViewInScrollView = curShowViews;
}

-(void)updateScrollView
{
    int index = 0;
    //BOOL bPortrait = (orientation == UIDeviceOrientationPortrait || orientation == UIDeviceOrientationPortraitUpsideDown);
    BOOL bPortrait = (self.scrollView.frame.origin.x == 0);
    for(NSString* key in self.streamItemDict){
        EMStreamItem* item = [self.streamItemDict objectForKey:key];
        if(self.curBigView != item.videoView) {
            if([item.videoView.displayView isKindOfClass:[EMCallRemoteView class]]){
                EMCallRemoteView*view = (EMCallRemoteView*)item.videoView.displayView;
                view.scaleMode = EMCallViewScaleModeAspectFill;
            }
            if([item.videoView.displayView isKindOfClass:[EMCallLocalView class]]){
                EMCallLocalView*view = (EMCallLocalView*)item.videoView.displayView;
                view.scaleMode = EMCallViewScaleModeAspectFill;
            }
            //item.videoView.frame = CGRectMake(gSmallVideoSize*index, 0, gSmallVideoSize, gSmallVideoSize);
            [item.videoView mas_remakeConstraints:^(MASConstraintMaker *make) {
                if(bPortrait) {
                    make.left.equalTo(@(gSmallVideoSize*index));
                    make.top.equalTo(@0);
                    make.width.equalTo(@(gSmallVideoSize));
                    make.height.equalTo(@(gSmallVideoSize));
                }else{
                    make.left.equalTo(@0);
                    make.top.equalTo(@(gSmallVideoSize*index));
                    make.width.equalTo(@(gSmallVideoSize));
                    make.height.equalTo(@(gSmallVideoSize));
                }
            }];
            index++;
        }
    }
    long count = self.streamItemDict.count;
    if(count * gSmallVideoSize > bPortrait?self.view.bounds.size.width:self.view.bounds.size.height){
        self.scrollView.contentSize = bPortrait?CGSizeMake(count*gSmallVideoSize,gSmallVideoSize):CGSizeMake(gSmallVideoSize,count*gSmallVideoSize);
    }else
        self.scrollView.contentSize = bPortrait?CGSizeMake(self.view.bounds.size.width, gSmallVideoSize):CGSizeMake( gSmallVideoSize,self.view.bounds.size.height);
}

-(void)updateAdminView
{
    for(NSString* key in _streamItemDict){
        EMStreamItem* item = [_streamItemDict objectForKey:key];
        if(item && item.videoView){
            NSString* memName = [NSString stringWithFormat:@"%@_%@",[EMDemoOption sharedOptions].appkey,item.videoView.nameLabel.text];
            
            if([[EMDemoOption sharedOptions].conference.adminIds containsObject:memName]){
                item.videoView.isAdmin = YES;
            }else
                item.videoView.isAdmin = NO;
        }
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.tableView setHidden:!self.tableView.hidden];
    [self.topVC.view setHidden:!self.topVC.view.hidden];
    [self updateScrollViewPos];
}


-(CVPixelBufferRef)createCVPixelBufferRefFromNV12buffer:(unsigned char *)buffer width:(int)w height:(int)h {
    NSDictionary *pixelAttributes = @{(NSString*)kCVPixelBufferIOSurfacePropertiesKey:@{}};
    
    CVPixelBufferRef pixelBuffer = NULL;
    
    CVReturn result = CVPixelBufferCreate(kCFAllocatorDefault,
                                          w,
                                          h,
                                          kCVPixelFormatType_420YpCbCr8BiPlanarFullRange,
                                          (__bridge CFDictionaryRef)(pixelAttributes),
                                          &pixelBuffer);//kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange,
    
    CVPixelBufferLockBaseAddress(pixelBuffer,0);
    unsigned char *yDestPlane = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
    
    // Here y_ch0 is Y-Plane of YUV(NV12) data.
    unsigned char *y_ch0 = buffer;
    memcpy(yDestPlane, y_ch0, w * h);
    unsigned char *uvDestPlane = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1);
    
    // Here y_ch1 is UV-Plane of YUV(NV12) data.
    unsigned char *y_ch1 = buffer + w * h;
    memcpy(uvDestPlane, y_ch1, w * h/2);
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    
    if (result != kCVReturnSuccess) {
        NSLog(@"Unable to create cvpixelbuffer %d", result);
    }
    return pixelBuffer;
}

- (void)startRecordTimer
{
    if(_timeRecord) {
        [_timeRecord invalidate];
        _timeRecord = nil;
    }
    _timeRecord = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timeRecordAction:) userInfo:nil repeats:YES];
}

- (void)timeRecordAction:(id)sender
{
    NSNumber* status = [self.sharedDefaults objectForKey:@"status"];
    NSNumber* result = [self.sharedDefaults objectForKey:@"result"];
    if(result && result.intValue == 2) {
        [self.sharedDefaults setObject:[NSNumber numberWithInt:0] forKey:@"result"];
        [self publishSharedDesktop];
    }
    if(result && result.intValue == 1){
        [self.sharedDefaults setObject:[NSNumber numberWithInt:0] forKey:@"result"];
        [_timeRecord invalidate];
        _timeRecord = nil;
        __weak typeof(self) weakself = self;
        //[weakself removeStreamWithId:weakself.desktopStreamId];
        
        [[[EMClient sharedClient] conferenceManager] unpublishConference:[EMDemoOption sharedOptions].conference streamId:weakself.desktopStreamId completion:^(EMError *aError) {
            if(weakself.desktopStreamId != nil)
                [weakself.myStreamIds removeObjectForKey:weakself.desktopStreamId];
            weakself.desktopStreamId = nil;
            if([EMDemoOption sharedOptions].conference.isCreator && [EMDemoOption sharedOptions].openCDN)
                [weakself _upadteLiveRegions];
        }
        ];
    }
    if(status && [status intValue] == 1){
        [self.sharedDefaults setObject:[NSNumber numberWithInt:3] forKey:@"status"];
        @autoreleasepool {
            __block NSMutableData* data = [self.sharedDefaults objectForKey:@"data"];
            size_t width,height;
            CMTimeValue timevalue;
            CMTimeScale timescale;
            memcpy(&width,data.bytes,sizeof(size_t));
            memcpy(&height,data.bytes + sizeof(size_t),sizeof(size_t));
            memcpy(&timevalue,data.bytes + sizeof(size_t) * 2,sizeof(CMTimeValue));
            memcpy(&timescale,data.bytes + sizeof(size_t) * 2 + sizeof(CMTimeValue),sizeof(CMTimeScale));
            __block CVPixelBufferRef buffer = [self createCVPixelBufferRefFromNV12buffer:(data.bytes + sizeof(CMTimeValue) +  sizeof(CMTimeValue)) width:width height:height];
            CMTime t = CMTimeMake(timevalue, timescale);
            [[[EMClient sharedClient] conferenceManager] inputVideoPixelBuffer:buffer sampleBufferTime:t rotation:UIDeviceOrientationPortrait conference:[EMDemoOption sharedOptions].conference publishedStreamId:_desktopStreamId completion:^(EMError *aError) {
//                data = nil;
            }];
            CVPixelBufferRelease(buffer);
        }
    }
}

-(void)publishSharedDesktop
{
    EMStreamParam *pubConfig = [[EMStreamParam alloc] init];
    pubConfig.streamName = [EMClient sharedClient].currentUsername;
    
    pubConfig.maxAudioKbps = 200;
    pubConfig.type = EMStreamTypeDesktop;
    pubConfig.desktopView = nil;
    pubConfig.videoResolution = EMCallVideoResolution_Custom;
    CGFloat screenX = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenY = [UIScreen mainScreen].bounds.size.height;
    pubConfig.videoWidth = screenY;
    pubConfig.videoHeight = screenX;
    
    __weak typeof(self) weakself = self;
    //上传视频流
    [[EMClient sharedClient].conferenceManager publishConference:[EMDemoOption sharedOptions].conference streamParam:pubConfig completion:^(NSString *aPubStreamId, EMError *aError) {
        if (aError) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"错误" message:@"上传共享桌面流失败，请重试" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
            
            return ;
        }
        
        weakself.desktopStreamId = aPubStreamId;
    }];
}

- (void)startSharedDesktop:(void (^)())aCompletion
{
    if(aCompletion)
        aCompletion();
}

-(void)recordAction
{
    if(self.presentedViewController)
        [self.presentedViewController dismissViewControllerAnimated:YES completion:^{
        }];
    if(self.whiteBoard || [self.remoteDesktopStreamId length] > 0){
        [EMAlertController showInfoAlert:@"正在进行共享任务，不能再共享桌面"];
        return;
    }
    if (@available(iOS 13.0, *)){
        if([EMDemoOption sharedOptions].conference.role < EMConferenceRoleSpeaker) {
            return;
        }
        UIControlEvents event = UIControlEventTouchDown;
        if(@available(iOS 13.0, *)) {
            event = UIControlEventTouchUpInside;
        }
        for (UIView *view in _picker.subviews)
        {
            if ([view isKindOfClass:[UIButton class]])
            {
                if(!gCanSharedDesktop)
                    return;
                gCanSharedDesktop = NO;
                [self.sharedDefaults setObject:[NSNumber numberWithInt:0] forKey:@"result"];
                [self startRecordTimer];
                [self startSharedDesktop:^(){
                    [(UIButton*)view sendActionsForControlEvents:event];
                }];
                return;
            }
        }
    }else
    {
        [EMAlertController showInfoAlert:@"该功能需要iOS 13.0及以上版本，请升级系统"];
    }
}

- (void)stopAction:(UIButton*)button
{
    if(self.broadcastController)
        [self.broadcastController finishBroadcastWithHandler:^(NSError * _Nullable error) {
            
        }];
}

- (void)_upadteLiveRegions
{
    if([EMDemoOption sharedOptions].conference.liveCfgs) {
        NSArray* allKeys = [[EMDemoOption sharedOptions].conference.liveCfgs allKeys];
        for(NSString* key in allKeys) {
            [self _upadteLiveRegionsWithLiveId:key];
        }
    }else{
        [self _upadteLiveRegionsWithLiveId:[EMDemoOption sharedOptions].conference.liveId];
    }
}

- (void)_upadteLiveRegionsWithLiveId:(NSString*)liveId
{
    // 先计算出总共有多少个流
    long streamcounts = [self.streamItemDict count];
    if( [self.desktopStreamId length] > 0)
        streamcounts++;
    if([self.remoteDesktopStreamId length] > 0)
        streamcounts++;
    // 然后计算出需要多少行和列展示，每个流占据的宽和高
    long column = sqrt(streamcounts);
    if(column * column < streamcounts)
        column += 1;
    long row = (streamcounts + column -1)/column;
    long index = 0;
    long cellWidth = [EMDemoOption sharedOptions].liveWidth/column;
    long cellHeight = [EMDemoOption sharedOptions].liveHeight/row;
    // 计算每个流的位置
    NSMutableArray<LiveRegion*>* regionsList = [NSMutableArray array];
    for (id key in self.streamItemDict) {
        EMStreamItem* item = [self.streamItemDict objectForKey:key];
        if(item) {
            if(item.stream) {
                long curRow = index/column;
                long curColumn = index - curRow * column;
                LiveRegion* region = [[LiveRegion alloc] init];
                region.streamId = item.stream.streamId;
                if(item.stream.type == EMStreamTypeDesktop)
                    region.style = LiveRegionStyleFit;
                else
                    region.style = LiveRegionStyleFill;
                region.x = curColumn * cellWidth;
                region.y = curRow * cellHeight;
                region.w = cellWidth;
                region.h = cellHeight;
                region.z = gZorder;
                [regionsList addObject:region];
            }else {
                if([self.pubStreamId length] > 0){
                    long curRow = index/column;
                    long curColumn = index - curRow * column;
                    LiveRegion* region = [[LiveRegion alloc] init];
                    region.streamId = [self.myStreamIds objectForKey:self.pubStreamId];
                    region.style = LiveRegionStyleFill;
                    region.x = curColumn * cellWidth;
                    region.y = curRow * cellHeight;
                    region.w = cellWidth;
                    region.h = cellHeight;
                    region.z = gZorder;
                    [regionsList addObject:region];
                }
            }
        }
        index++;
    }
    if([self.desktopStreamId length] > 0 && [self.myStreamIds objectForKey:self.desktopStreamId]) {
        long curRow = index/column;
        long curColumn = index - curRow * column;
        LiveRegion* region = [[LiveRegion alloc] init];
        region.streamId = [self.myStreamIds objectForKey:self.desktopStreamId];
        region.style = LiveRegionStyleFit;
        region.x = curColumn * cellWidth;
        region.y = curRow * cellHeight;
        region.w = cellWidth;
        region.h = cellHeight;
        region.z = gZorder;
        [regionsList addObject:region];
    }
    if([self.remoteDesktopStreamId length] > 0) {
        long curRow = index/column;
        long curColumn = index - curRow * column;
        LiveRegion* region = [[LiveRegion alloc] init];
        region.streamId = self.remoteDesktopStreamId;
        region.style = LiveRegionStyleFit;
        region.x = curColumn * cellWidth;
        region.y = curRow * cellHeight;
        region.w = cellWidth;
        region.h = cellHeight;
        region.z = gZorder;
        [regionsList addObject:region];
    }
    gZorder++;
    //更新布局
    [[[EMClient sharedClient] conferenceManager] updateConference:[EMDemoOption sharedOptions].conference liveId:liveId setRegions:regionsList completion:^(EMError *aError) {
        if(aError) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [EMAlertController showErrorAlert:[NSString stringWithFormat:@"setRegions failed:%@",aError.errorDescription]];
            });
        }
    }];
}


#pragma mark - UIScrollViewDelegate
// called on finger up if the user dragged. decelerate is true if it will continue moving afterwards

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self updateVideoSub];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(!decelerate)
       [self updateVideoSub];
}
- (void)viewWillAppear:(BOOL)animated
{
    AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;//允许转成横屏
    appDelegate.allowRotation = YES;
    NSNumber *orientationTarget = [NSNumber numberWithInt:[UIDevice currentDevice].orientation];

    [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
    [UIViewController attemptRotationToDeviceOrientation];
}
#pragma mark - UIDeviceOrientationDidChangeNotification
- (void)orientationDidChange:(NSNotification *)notification {
  [self setCorrectViewOrientation];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)setCorrectViewOrientation {
    // Get current device orientation.
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if (deviceOrientation == UIInterfaceOrientationPortraitUpsideDown || deviceOrientation == UIInterfaceOrientationPortrait) {
        _scrollView.frame = CGRectMake(0, _tableView.isHidden?self.view.bounds.size.height-gSmallVideoSize:self.view.bounds.size.height-gSmallVideoSize-gBottomMenuHeight, self.view.bounds.size.width, gSmallVideoSize);
        [self.scrollView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self.view);
            make.height.equalTo(@(gSmallVideoSize));
            make.left.equalTo(self.view);
            if(_tableView.isHidden)
                make.bottom.equalTo(self.view);
            else
                make.bottom.equalTo(self.view).with.offset(-gBottomMenuHeight);
        }];
        [self updateScrollView];
        [self updateVideoSub];
    } else if (deviceOrientation == UIInterfaceOrientationLandscapeRight || deviceOrientation == UIInterfaceOrientationLandscapeLeft) {
        _scrollView.frame = CGRectMake(self.view.bounds.size.width-gSmallVideoSize, 0, gSmallVideoSize, self.view.bounds.size.height);
        [_scrollView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@100);
            make.height.equalTo(self.view);
            make.right.equalTo(self.view);
            make.bottom.equalTo(self.view);
        }];
        //[self.view sendSubviewToBack:_scrollView];
        [self.view bringSubviewToFront:self.topVC.view];
        [self updateScrollView];
        [self updateVideoSub];
    }
}

#pragma mark -

- (void)handleSwipeFrom:(UISwipeGestureRecognizer*)recognizer
{
    if(self.remoteDesktopView) {
        self.sharedDesktopVC = [[SharedDesktopViewController alloc] initWithSharedDesktopView:self.remoteDesktopView];
        [self.navigationController pushViewController:self.sharedDesktopVC animated:NO];
    }
}
@end
