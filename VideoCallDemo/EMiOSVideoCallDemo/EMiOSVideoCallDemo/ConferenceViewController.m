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

@interface ConferenceViewController ()

@end

@implementation ConferenceViewController

- (instancetype)initWithConfence:(EMCallConference*)call role:(EMConferenceRole)role
{
    self = [super init];
    if (self) {
        self.streamItemDict = [NSMutableDictionary dictionary];
        self.role = role;
        [[[EMClient sharedClient] conferenceManager] getConference:call.confId password:[EMDemoOption sharedOptions].roomPswd completion:^(EMCallConference *aCall, EMError *aError) {
            [EMDemoOption sharedOptions].conference.adminIds = [aCall.adminIds copy];
            [EMDemoOption sharedOptions].conference.memberCount = aCall.memberCount;
            [EMDemoOption sharedOptions].conference.speakerIds = [aCall.speakerIds copy];
        }];
        __weak typeof(self) weakself = self;
        EMConferenceRole currole = call.role;
        if (currole != EMConferenceRoleAudience) {
            [weakself pubLocalStreamWithEnableVideo:[EMDemoOption sharedOptions].openCamera completion:^(NSString *aPubStreamId, EMError *aError) {
            }];
        } else {
            weakself.microphoneButton.enabled = NO;
            weakself.videoButton.enabled = NO;
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationController setNavigationBarHidden:YES];
    [self setupSubViews];
    [[[EMClient sharedClient] conferenceManager] addDelegate:self delegateQueue:nil];
    [[[EMClient sharedClient] conferenceManager] startMonitorSpeaker:[EMDemoOption sharedOptions].conference timeInterval:2 completion:^(EMError *aError) {
        
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES];
}

-(void)dealloc
{
    if (_timeTimer) {
        [_timeTimer invalidate];
        _timeTimer = nil;
    }
    [[EMClient sharedClient].conferenceManager removeDelegate:self];
}

-(void) setupSubViews
{
    self.roomNameLable = [[UILabel alloc] initWithFrame:CGRectMake(20,50, 100, 30)];
    self.roomNameLable.text = [EMDemoOption sharedOptions].roomName;
    [self.view addSubview:self.roomNameLable];
    
    self.settingButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.settingButton.frame = CGRectMake(self.view.bounds.size.width - 100, 50, 40, 40);
    //[self.settingButton setTitle:@"设置" forState:UIControlStateNormal];
    [self.settingButton setImage:[UIImage imageNamed:@"形状"] forState:UIControlStateNormal];
    [self.settingButton addTarget:self action:@selector(settingAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.settingButton];
    
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 80, 100, 30)];
    [self.view addSubview:self.timeLabel];
    [self startTimer];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 240, self.view.bounds.size.width, 150)];
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.contentSize = CGSizeMake(150*9, 150);
    [self.view addSubview:self.scrollView];
    
    self.switchCameraButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.switchCameraButton.frame = CGRectMake(self.view.bounds.size.width - 50, 50, 40, 40);
    self.switchCameraButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.switchCameraButton setTitle:@"" forState:UIControlStateNormal];
    [self.switchCameraButton setImage:[UIImage imageNamed:@"形状结合"] forState:UIControlStateNormal];
    [self.switchCameraButton setImage:[UIImage imageNamed:@"形状结合"] forState:UIControlStateDisabled];
    [self.switchCameraButton setImage:[UIImage imageNamed:@"形状结合"] forState:UIControlStateSelected];
    [self.switchCameraButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.switchCameraButton setTintColor:[UIColor redColor]];
    [self.switchCameraButton addTarget:self action:@selector(switchCamaraAction) forControlEvents:UIControlEventTouchUpInside];
    //设置按下状态的颜色
    [self.switchCameraButton setTitleColor:[UIColor orangeColor] forState:UIControlStateHighlighted];
    //设置按钮的风格颜色
    [self.switchCameraButton setTintColor:[UIColor whiteColor]];
    [self.switchCameraButton setTitleColor:[UIColor blackColor] forState:UIControlStateDisabled];
    [self.switchCameraButton setEnabled:NO];
    [self.view addSubview:_switchCameraButton];
    
    int padding = 20;
    int top = self.view.bounds.size.height - 80;
    int size = (self.view.bounds.size.width - 20*6)/5;
    self.microphoneButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.microphoneButton.frame = CGRectMake(padding, top, size, size);
    [self.microphoneButton setTitle:@"" forState:UIControlStateNormal];
    [self.microphoneButton addTarget:self action:@selector(microphoneButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.microphoneButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.microphoneButton setImage:[UIImage imageNamed:@"编组 6"] forState:UIControlStateNormal];
    [self.microphoneButton setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
    [self.microphoneButton setImage:[UIImage imageNamed:@"编组 6"] forState:UIControlStateSelected];
    [self.view addSubview:self.microphoneButton];
    
    self.videoButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.videoButton.frame = CGRectMake(padding + (padding+size), top, size, size);
    [self.videoButton setTitle:@"" forState:UIControlStateNormal];
    [self.videoButton addTarget:self action:@selector(videoButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.videoButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.videoButton setImage:[UIImage imageNamed:@"视频"] forState:UIControlStateNormal];
    [self.videoButton setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
    [self.videoButton setImage:[UIImage imageNamed:@"视频"] forState:UIControlStateSelected];
    [self.view addSubview:self.videoButton];
    
    self.hangupButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.hangupButton.frame = CGRectMake(padding + (padding+size) * 2, top, size, size);
    //[self.hangupButton setTitle:@"挂断" forState:UIControlStateNormal];
    self.hangupButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.hangupButton setImage:[UIImage imageNamed:@"视频备份"] forState:UIControlStateNormal];
    [self.hangupButton setTintColor:[UIColor redColor]];
    [self.hangupButton addTarget:self action:@selector(hangupAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.hangupButton];
    
    self.membersButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.membersButton.frame = CGRectMake(padding + (padding+size) * 3, top, size, size);
    //[self.membersButton setTitle:@"成员" forState:UIControlStateNormal];
    [self.membersButton setImage:[UIImage imageNamed:@"成员"] forState:UIControlStateNormal];
    //self.membersButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    //[self.membersButton setImage:[UIImage imageNamed:@"成员"] forState:UIControlStateNormal];
    [self.membersButton addTarget:self action:@selector(membersAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.membersButton];
    
    self.roleButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.roleButton.frame = CGRectMake(padding + (padding+size) * 4, top, size, size);
    EMConferenceRole currole = [EMDemoOption sharedOptions].conference.role;
    if(currole == EMConferenceRoleAudience)
    {
        [self.roleButton setImage:[UIImage imageNamed:@"上麦"] forState:UIControlStateNormal];
        [self.roleButton setTintColor:[UIColor blueColor]];
    }
    else
    {
        [self.roleButton setImage:[UIImage imageNamed:@"下麦"] forState:UIControlStateNormal];
        [self.roleButton setTintColor:[UIColor redColor]];
    }
    self.roleButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    //[self.roleButton setImage:[UIImage imageNamed:@"上麦"] forState:UIControlStateNormal];
    [self.roleButton addTarget:self action:@selector(roleChangeAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.roleButton];
}
     
-(void)microphoneButtonAction
{
    self.microphoneButton.selected = !self.microphoneButton.isSelected;
    
    [[EMClient sharedClient].conferenceManager updateConference:[EMDemoOption sharedOptions].conference isMute:!self.microphoneButton.isSelected];
    
    if ([self.pubStreamId length] > 0) {
        EMStreamItem *videoItem = [self.streamItemDict objectForKey:self.pubStreamId];
        if (videoItem) {
            videoItem.videoView.enableVoice = self.microphoneButton.isSelected;
        }
    }
     
    
    if (!self.microphoneButton.isSelected && self.videoButton.isSelected) {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
        [audioSession setActive:YES error:nil];
    }
}

- (void)videoButtonAction
{
    self.videoButton.selected = !self.videoButton.isSelected;
    
    [[[EMClient sharedClient] conferenceManager] updateConference:[EMDemoOption sharedOptions].conference enableVideo:self.videoButton.selected];
    if([self.pubStreamId length] > 0){
        EMStreamItem* localItem = [self.streamItemDict objectForKey:self.pubStreamId];
        if(localItem){
            localItem.videoView.enableVideo = self.videoButton.isSelected;
            self.switchCameraButton.enabled = self.videoButton.isSelected;
        }
    }
}

- (void)switchCamaraAction
{
    [[[EMClient sharedClient] conferenceManager] updateConferenceWithSwitchCamera:[EMDemoOption sharedOptions].conference];
}

#pragma mark - timer

- (void)startTimer
{
    _timeLength = 0;
    _timeTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timeTimerAction:) userInfo:nil repeats:YES];
}

- (void)timeTimerAction:(id)sender
{
    _timeLength += 1;
    int hour = _timeLength / 3600;
    int m = (_timeLength - hour * 3600) / 60;
    int s = _timeLength - hour * 3600 - m * 60;
    
    if (hour > 0) {
        _timeLabel.text = [NSString stringWithFormat:@"%i:%i:%i", hour, m, s];
    }
    else if(m > 0){
        _timeLabel.text = [NSString stringWithFormat:@"%i:%i", m, s];
    }
    else{
        _timeLabel.text = [NSString stringWithFormat:@"00:%i", s];
    }
}

#pragma mark - button action
-(void)membersAction
{
    SpeakerListViewController* speakerListVC = [[SpeakerListViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [self.navigationController pushViewController:speakerListVC animated:YES];
    
}

- (void)hangupAction
{
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    
   AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
    [audioSession setActive:YES error:nil];
    if([EMDemoOption sharedOptions].conference) {
        [[EMClient sharedClient].conferenceManager stopMonitorSpeaker:[EMDemoOption sharedOptions].conference];
        [[EMClient sharedClient].conferenceManager leaveConference:[EMDemoOption sharedOptions].conference completion:nil];
    }
    [self clearResource];

    [self dismissViewControllerAnimated:NO completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
    [self.navigationController setNavigationBarHidden:NO];
}

-(void) clearResource
{
    for (UIView *subview in self.scrollView.subviews) {
        [subview removeFromSuperview];
    }
    [EMDemoOption sharedOptions].conference = nil;
    [[[EMClient sharedClient] conferenceManager] removeDelegate:self];
}

-(void) roleChangeAction
{
    if([EMDemoOption sharedOptions].conference.role >= EMConferenceRoleSpeaker) {
        [[[EMClient sharedClient] conferenceManager] setConferenceAttribute:[EMDemoOption sharedOptions].userid value:@"request_tobe_audience" completion:^(EMError *aError) {
            if(!aError){
                __weak typeof(self) weakself = self;
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"下麦申请已提交" preferredStyle:UIAlertControllerStyleAlert];
                    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        
                    }]];
                    [weakself presentViewController:alert animated:YES completion:nil];
                });
            }
        }];
    }else{
        [[[EMClient sharedClient] conferenceManager] setConferenceAttribute:[EMDemoOption sharedOptions].userid value:@"request_tobe_speaker" completion:^(EMError *aError) {
            if(!aError){
                __weak typeof(self) weakself = self;
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"上麦申请已提交，请等待管理员审核" preferredStyle:UIAlertControllerStyleAlert];
                    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        
                    }]];
                    [weakself presentViewController:alert animated:YES completion:nil];
                });
            }
        }];
    }
}

-(void) settingAction
{
    __weak typeof(self) weakself = self;
    [[[EMClient sharedClient] conferenceManager] getConference:[EMDemoOption sharedOptions].conference.confId password:[EMDemoOption sharedOptions].roomPswd completion:^(EMCallConference *aCall, EMError *aError) {
        RoomSettingViewController* roomSettingViewControler = [[RoomSettingViewController alloc] initWithStyle:UITableViewStyleGrouped];
        [self.navigationController pushViewController:roomSettingViewControler animated:YES];
    }];
    
}

- (void)showHint:(NSString *)hint
{
    UIView *view = [[UIApplication sharedApplication].delegate window];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.userInteractionEnabled = NO;
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.labelText = hint;
    hud.margin = 10.f;
    hud.yOffset = 180;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:2];
}

- (CGRect)getNewVideoViewFrame
{
    NSInteger count = [self.streamItemDict count];
    int viewSize = 150;
    CGRect frame = CGRectMake(self.scrollView.bounds.origin.x + viewSize*(count-1), self.scrollView.bounds.origin.y, viewSize, viewSize);
    
    return frame;
}
//设置视频界面
- (EMStreamItem *)setupNewStreamItemWithName:(NSString *)aName
                                 displayView:(UIView *)aDisplayView
                                      stream:(EMCallStream *)aStream
{
    
    CGRect frame;
    if([self.streamItemDict count] == 0)
        frame = self.view.bounds;
    else
        frame = [self getNewVideoViewFrame];
    
    EMStreamView *videoView = [[EMStreamView alloc] initWithFrame:frame];
    videoView.delegate = self;
    videoView.nameLabel.text = aName;
    videoView.displayView = aDisplayView;
    [videoView addSubview:aDisplayView];
    [videoView sendSubviewToBack:aDisplayView];
    
    [aDisplayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(videoView);
    }];
    if([self.streamItemDict count] == 0)
    {
        self.curBigView = videoView;
        [self.view addSubview:self.curBigView];
        [self.view sendSubviewToBack:self.curBigView];
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
    self.switchCameraButton.enabled = NO;
    
    EMStreamParam *pubConfig = [[EMStreamParam alloc] init];
    pubConfig.streamName = [EMClient sharedClient].currentUsername;
    pubConfig.enableVideo = aEnableVideo;
    pubConfig.isMute = ![EMDemoOption sharedOptions].openMicrophone;
    
    EMCallOptions *options = [[EMClient sharedClient].callManager getCallOptions];
    pubConfig.maxVideoKbps = (int)options.maxVideoKbps;
    pubConfig.maxAudioKbps = (int)options.maxAudioKbps;
    switch ([EMDemoOption sharedOptions].resolutionrate) {
        case ResolutionRate_720p:
            pubConfig.videoResolution = EMCallVideoResolution1280_720;
            break;
        case ResolutionRate_360p:
            pubConfig.videoResolution = EMCallVideoResolution352_288;
            break;
        ResolutionRate_480p:
            pubConfig.videoResolution = EMCallVideoResolution640_480;
            break;
        default:
            pubConfig.videoResolution = options.videoResolution;
            break;
    }
    

    pubConfig.isBackCamera = self.switchCameraButton.isSelected;

    EMCallLocalView *localView = [[EMCallLocalView alloc] init];
    //视频通话页面缩放方式
    localView.scaleMode = EMCallViewScaleModeAspectFill;
    //显示本地视频的页面
    pubConfig.localView = localView;
    
    __weak typeof(self) weakself = self;
    //上传本地摄像头的数据流
    [[EMClient sharedClient].conferenceManager publishConference:[EMDemoOption sharedOptions].conference streamParam:pubConfig completion:^(NSString *aPubStreamId, EMError *aError) {
        if (aError) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"错误" message:@"上传本地视频流失败，请重试" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
            
            if (aCompletionBlock) {
                aCompletionBlock(nil, aError);
            }
            
            return ;
            
            //TODO: 后续处理是怎么样的
        }
        
        weakself.videoButton.enabled = YES;
        weakself.videoButton.selected = aEnableVideo;
        weakself.microphoneButton.selected = [EMDemoOption sharedOptions].openMicrophone;
        weakself.switchCameraButton.enabled = aEnableVideo;
        
        weakself.pubStreamId = aPubStreamId;
        //设置视频界面
        EMStreamItem *videoItem = [self setupNewStreamItemWithName:pubConfig.streamName displayView:localView stream:nil];
        videoItem.videoView.enableVideo = aEnableVideo;
        [weakself.streamItemDict setObject:videoItem forKey:aPubStreamId];
        [weakself.streamIds addObject:aPubStreamId];
        
        if (aCompletionBlock) {
            aCompletionBlock(aPubStreamId, nil);
        }
    }];
}
//
- (void)_subStream:(EMCallStream *)aStream
{
    EMCallRemoteView *remoteView = [[EMCallRemoteView alloc] init];
    remoteView.scaleMode = EMCallViewScaleModeAspectFill;
    EMStreamItem *videoItem = [self setupNewStreamItemWithName:aStream.userName displayView:remoteView stream:aStream];
    videoItem.videoView.enableVideo = aStream.enableVideo;
    
    __weak typeof(self) weakSelf = self;
    //订阅其他人的数据流，，即订阅当前会议上麦主播的数据流
    [[EMClient sharedClient].conferenceManager subscribeConference:[EMDemoOption sharedOptions].conference streamId:aStream.streamId remoteVideoView:remoteView completion:^(EMError *aError) {
        if (aError) {
            NSString *message = [NSString stringWithFormat:NSLocalizedString(@"alert.conference.subFail", @"Sub stream-%@ failed!"), aStream.userName];
            [weakSelf showHint:message];
            [weakSelf.streamItemDict removeObjectForKey:aStream.streamId];
            return ;
        }
        
        videoItem.videoView.enableVoice = aStream.enableVoice;
    }];
}

- (void)removeStreamWithId:(NSString *)aStreamId
{
    NSInteger index = [self.streamIds indexOfObject:aStreamId];
    
    EMStreamItem *removeItem = [self.streamItemDict objectForKey:aStreamId];
    CGRect prevFrame = removeItem.videoView.frame;
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
        curbigview.frame = CGRectMake(aVideoView.frame.origin.x, aVideoView.frame.origin.y, 150, 150);
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
    [self updateScrollView];
}


#pragma mark - EMConferenceManagerDelegate

- (void)memberDidJoin:(EMCallConference *)aConference
               member:(EMCallMember *)aMember
{
    if ([aConference.callId isEqualToString: [EMDemoOption sharedOptions].conference.callId]) {
        NSString *message = [NSString stringWithFormat:@"%@ 加入会议", aMember.memberName];
        [self showHint:message];
    }
}

- (void)memberDidLeave:(EMCallConference *)aConference
                member:(EMCallMember *)aMember
{
    if ([aConference.callId isEqualToString:[EMDemoOption sharedOptions].conference.callId]) {
        NSString *message = [NSString stringWithFormat:@"%@ 离开会议", aMember.memberName];
        [self showHint:message];
    }
}
//有新的数据流上传
- (void)streamDidUpdate:(EMCallConference *)aConference
              addStream:(EMCallStream *)aStream
{
    if ([aConference.callId isEqualToString:[EMDemoOption sharedOptions].conference.callId]) {
        [self _subStream:aStream];
    }
}

- (void)streamDidUpdate:(EMCallConference *)aConference
           removeStream:(EMCallStream *)aStream
{
    if ([aConference.callId isEqualToString:[EMDemoOption sharedOptions].conference.callId]) {
        [self removeStreamWithId:aStream.streamId];
        [self updateScrollView];
    }
}

- (void)conferenceDidEnd:(EMCallConference *)aConference
                  reason:(EMCallEndReason)aReason
                   error:(EMError *)aError
{
    if ([aConference.callId isEqualToString:[EMDemoOption sharedOptions].conference.callId]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"会议已关闭" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        
        [self hangupAction];
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
    }
    
    if (videoItem.stream.enableVoice != aStream.enableVoice) {
        videoItem.videoView.enableVoice = aStream.enableVoice;
    }
    
    videoItem.stream = aStream;
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
        
        if (!self.microphoneButton.isSelected && self.videoButton.isSelected && !self.isSetSpeaker) {
            self.isSetSpeaker = YES;
            AVAudioSession *audioSession = [AVAudioSession sharedInstance];
            [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
            [audioSession setActive:YES error:nil];
        }
    }
}

- (void)conferenceNetworkDidChange:(EMCallConference *)aSession
                            status:(EMCallNetworkStatus)aStatus
{
    NSString *str = @"";
    switch (aStatus) {
        case EMCallNetworkStatusNormal:
            str = @"网路正常";
            break;
        case EMCallNetworkStatusUnstable:
            str = @"网路不稳定";
            break;
        case EMCallNetworkStatusNoData:
            str = @"网路已断开";
            break;
            
        default:
            break;
    }
    if ([str length] > 0) {
        [self showHint:str];
    }
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
    [self.talkingStreamIds addObjectsFromArray:aStreamIds];
}

- (void)conferenceAttributeUpdated:(EMCallConference *)aConference
                        attributes:(NSArray <EMConferenceAttribute *>*)attrs
{
    dispatch_async(dispatch_get_main_queue(), ^{
        EMConferenceRole currole = [EMDemoOption sharedOptions].conference.role;
        if([aConference.confId isEqualToString:[EMDemoOption sharedOptions].conference.confId] && currole == EMConferenceRoleAdmin)
        {
            for(int i = 0;i<[attrs count];i++)
            {
                NSString* userid = [attrs objectAtIndex:i].key;
                NSString* action = [attrs objectAtIndex:i].value;
                if([action isEqualToString:@"request_tobe_speaker"]) {
                    NSString * message = [userid stringByAppendingString:@" 申请上麦"];
                    [[[EMClient sharedClient] conferenceManager] deleteAttributeWithKey:userid completion:^(EMError *aError) {
                        
                    }];
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
                    [alert addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        if([aConference.speakerIds count] >= 2){
                            UIAlertController* alert2 = [UIAlertController alertControllerWithTitle:@"" message:@"主播已满，选人下麦？" preferredStyle:UIAlertControllerStyleAlert];
                            [alert2 addAction:[UIAlertAction actionWithTitle:@"返回" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                // 下麦一个主播
                            }]];
                            [alert2 addAction:[UIAlertAction actionWithTitle:@"选人下麦" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                                //弹出ViewController
                                KickSpeakerViewController *xVC = [[KickSpeakerViewController alloc] init];
                                xVC.view.frame = CGRectMake(0, 200, self.view.bounds.size.width, self.view.bounds.size.height-200);
                                //设置ViewController的模态模式，即ViewController的显示方式
                                //xVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
                                //self.modalPresentationStyle = UIModalPresentationCurrentContext;
                                //加载模态视图
                                [self presentViewController:xVC animated:YES completion:^{
                                    }];
                            }]];
                            [self presentViewController:alert2 animated:YES completion:nil];
                        }else{
                            NSString* memId = [NSString stringWithFormat:@"%@_%@",[EMDemoOption sharedOptions].appkey,userid ];
                            [[[EMClient sharedClient] conferenceManager] changeMemberRoleWithConfId:aConference.confId memberNames:@[memId] role:EMConferenceRoleSpeaker completion:^(EMError *aError) {
                                if(aError){
                                    [EMAlertController showErrorAlert:@"修改用户权限失败"];
                                }
                                [EMAlertController showInfoAlert:@"修改用户权限成功"];
                            }];
                        }
                    }]];
                    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                        [[[EMClient sharedClient] conferenceManager] deleteAttributeWithKey:userid completion:^(EMError *aError) {
                            
                        }];
                    }]];
                    [self presentViewController:alert animated:YES completion:nil];
                }else
                    if([action isEqualToString:@"request_tobe_audience"]){
                        NSString* memId = [NSString stringWithFormat:@"%@_%@",[EMDemoOption sharedOptions].appkey,userid ];
                        [[[EMClient sharedClient] conferenceManager] changeMemberRoleWithConfId:aConference.confId memberNames:@[memId] role:EMConferenceRoleAudience completion:^(EMError *aError) {
                            if(aError){
                                [EMAlertController showErrorAlert:@"修改用户权限失败"];
                            }
                            [EMAlertController showInfoAlert:@"修改用户权限成功"];
                            [[[EMClient sharedClient] conferenceManager] deleteAttributeWithKey:userid completion:^(EMError *aError) {
                                
                            }];
                        }];
                    }else
                        if([action isEqualToString:@"become_admin"]){
                            [EMAlertController showInfoAlert:[NSString stringWithFormat:@"%@ 成为管理员",userid]];
                            NSString* memId = [NSString stringWithFormat:@"%@_%@",[EMDemoOption sharedOptions].appkey,userid ];
                            [EMDemoOption sharedOptions].conference.adminIds = @[memId];
                            [[[EMClient sharedClient] conferenceManager] deleteAttributeWithKey:userid completion:^(EMError *aError) {
                                
                            }];
                        }
            }
        }
    });
    
}

- (void)roleDidChanged:(EMCallConference *)aConference
{
    __weak typeof(self) weakself = self;
    if (aConference.role == EMConferenceRoleSpeaker && [self.pubStreamId length] == 0) {
        [self pubLocalStreamWithEnableVideo:YES completion:^(NSString *aPubStreamId, EMError *aError) {
            //[weakself _updateViewsAfterPubWithEnableVideo:YES error:aError];
            //weakself.vkbpsButton.enabled = YES;
            [self.roleButton setImage:[UIImage imageNamed:@"下麦"] forState:UIControlStateNormal];
            [self.roleButton setTintColor:[UIColor redColor]];
        }];
    } else if (aConference.role == EMConferenceRoleAudience && [self.pubStreamId length] > 0) {
        self.roleButton.selected = NO;
        self.switchCameraButton.enabled = NO;
        self.microphoneButton.enabled = NO;
        self.videoButton.enabled = NO;
        //self.vkbpsButton.enabled = NO;
        
        [self removeStreamWithId:self.pubStreamId];
        self.pubStreamId = nil;
        [self.roleButton setImage:[UIImage imageNamed:@"上麦"] forState:UIControlStateNormal];
        [self.roleButton setTintColor:[UIColor blueColor]];
    }else if(aConference.role == EMConferenceRoleAdmin){
        [[[EMClient sharedClient] conferenceManager] setConferenceAttribute:[EMDemoOption sharedOptions].userid value:@"become_admin" completion:^(EMError *aError) {
            if(aError){
                [EMAlertController showErrorAlert:@"管理员变更广播失败"];
            }
        }];
    }
}

-(void)updateScrollView
{
    int index = 0;
    for(NSString* key in self.streamItemDict){
        EMStreamItem* item = [self.streamItemDict objectForKey:key];
        if(self.curBigView != item.videoView) {
            item.videoView.frame = CGRectMake(150*index, 0, 150, 150);
            index++;
        }
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
