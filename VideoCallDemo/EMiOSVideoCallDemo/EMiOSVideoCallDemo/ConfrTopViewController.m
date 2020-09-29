//
//  ConfrTopViewController.m
//  EMiOSVideoCallDemo
//
//  Created by lixiaoming on 2020/9/16.
//  Copyright © 2020 easemob. All rights reserved.
//

#import "ConfrTopViewController.h"
#import "ConferenceViewController.h"
#import "EMDemoOption.h"

@interface ConfrTopViewController ()

@end

@implementation ConfrTopViewController

- (instancetype)initWithConfVC:(UIViewController*)confVC
{
    self = [super init];
    if(self) {
        self.confVC = confVC;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupSubviews];
}

- (void)setupSubviews
{
    [self.view setBackgroundColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1]];
    
    self.roomNameLable = [[UILabel alloc] initWithFrame:CGRectMake(59,50, 48, 25)];
    self.roomNameLable.text = [EMDemoOption sharedOptions].roomName;
    self.roomNameLable.textColor = [UIColor whiteColor];
    [self.roomNameLable setFont:[UIFont systemFontOfSize:20]];
    [self.view addSubview:self.roomNameLable];
    self.roomNameLable.textAlignment = NSTextAlignmentCenter;
    
    self.selectDevice = [UIButton buttonWithType:UIButtonTypeCustom];
    self.selectDevice.frame = CGRectMake(self.view.bounds.size.width - 50, 150, 40, 40);
    [self.selectDevice setImage:[UIImage imageNamed:@"扬声器"] forState:UIControlStateNormal];
    [self.selectDevice setImage:[UIImage imageNamed:@"听筒"] forState:UIControlStateSelected];
    [self.selectDevice addTarget:self action:@selector(selectDeviceAction) forControlEvents:UIControlEventTouchUpInside];
    [self.selectDevice setTintColor:[UIColor whiteColor]];
    [self.view addSubview:self.selectDevice];
    [self.selectDevice mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@40);
        make.height.equalTo(@40);
        make.bottom.equalTo(self.view);
        make.left.equalTo(@20);
    }];
    
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(59, 73, 40, 10)];
    self.timeLabel.textColor = [UIColor whiteColor];
    self.timeLabel.textAlignment = NSTextAlignmentCenter;
    [self.timeLabel setFont:[UIFont fontWithName:@"Arial" size:10]];
    [self.view addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view).with.multipliedBy(0.5);
        make.height.equalTo(@18);
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    [self.roomNameLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view).with.multipliedBy(0.5);
        make.height.equalTo(@20);
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.timeLabel.mas_top);
    }];
    
    self.switchCameraButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.switchCameraButton.frame = CGRectMake(self.view.bounds.size.width - 50, 200, 40, 40);
    self.switchCameraButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.switchCameraButton setTitle:@"" forState:UIControlStateNormal];
    [self.switchCameraButton setImage:[UIImage imageNamed:@"翻转镜头"] forState:UIControlStateNormal];
    [self.switchCameraButton setImage:[UIImage imageNamed:@"翻转镜头"] forState:UIControlStateDisabled];
    //[self.switchCameraButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    //[self.switchCameraButton setTintColor:[UIColor redColor]];
    [self.switchCameraButton addTarget:self.confVC action:@selector(switchCamaraAction) forControlEvents:UIControlEventTouchUpInside];
    //设置按下状态的颜色
    [self.switchCameraButton setTitleColor:[UIColor orangeColor] forState:UIControlStateHighlighted];
    //设置按钮的风格颜色
    //[self.switchCameraButton setTintColor:[UIColor blueColor]];
    [self.switchCameraButton setTitleColor:[UIColor blackColor] forState:UIControlStateDisabled];
    [self.switchCameraButton setTintColor:[UIColor whiteColor] ];
    [self.view addSubview:_switchCameraButton];
    [self.switchCameraButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@40);
        make.height.equalTo(@40);
        make.bottom.equalTo(self.view);
        make.left.equalTo(self.selectDevice.mas_right).with.offset(10);
    }];
    
    self.leaveConfrButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.leaveConfrButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.leaveConfrButton setImage:[UIImage imageNamed:@"离开"] forState:UIControlStateNormal];
    //[self.leaveConfrButton setTitle:@"离开会议" forState:UIControlStateNormal];
    //[self.leaveConfrButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.leaveConfrButton setTintColor:[UIColor redColor]];
    [self.leaveConfrButton addTarget:self.confVC action:@selector(hangupAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.leaveConfrButton];
    [self.leaveConfrButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@40);
        make.height.equalTo(@40);
        make.bottom.equalTo(self.view);
        make.right.equalTo(self.view).with.offset(-20);
    }];
}

-(void)selectDeviceAction
{
    __weak typeof(self) weakself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if(weakself.selectDevice.isSelected){
            AVAudioSession *audioSession = [AVAudioSession sharedInstance];
            //[audioSession setCategory:AVAudioSessionCategoryPlayAndRecord withOptions: AVAudioSessionCategoryOptionDefaultToSpeaker error:nil];
            NSError* error = nil;
            [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
            if(error != nil)
                return;
            [audioSession setActive:YES error:&error];
            if(error != nil)
                return;
            weakself.selectDevice.selected = NO;
        }else{
            AVAudioSession *audioSession = [AVAudioSession sharedInstance];
            NSError* error = nil;
            [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord withOptions: AVAudioSessionCategoryOptionAllowBluetooth error:&error];
            if(error != nil)
                return;
            //[audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
            [audioSession setActive:YES error:&error];
            if(error != nil)
                return;
            weakself.selectDevice.selected = YES;
        }
    });
    
    return;
//    __weak typeof(self) weakself = self;
//    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"切换音频设备" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
//
//    UIAlertAction *SpeakerAction = [UIAlertAction actionWithTitle:@"扬声器" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        [weakself switchBluetooth:NO];
//        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
//        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord withOptions: AVAudioSessionCategoryOptionDefaultToSpeaker
//                            error:nil];
//        [audioSession setActive:YES error:nil];
//        weakself.selectDevice.selected = NO;
//    }];
//    [alertController addAction:SpeakerAction];
//
//    UIAlertAction *IphoneAction = [UIAlertAction actionWithTitle:@"iPhone内置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        [weakself switchBluetooth:NO];
//
//        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
//        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord withOptions: AVAudioSessionCategoryOptionAllowBluetooth
//                            error:nil];
//        [audioSession setActive:YES error:nil];
//        weakself.selectDevice.selected = YES;
//
//    }];
//    [alertController addAction:IphoneAction];
//
//    if([weakself bluetoothAudioDevice] != nil) {
//        UIAlertAction *BlueToothAction = [UIAlertAction actionWithTitle:@"蓝牙耳机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            [weakself switchBluetooth:YES];
//            weakself.selectDevice.selected = YES;
//        }];
//        [alertController addAction:BlueToothAction];
//    }
//
//    [alertController addAction: [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", @"Cancel") style: UIAlertActionStyleCancel handler:nil]];
//
//    [self presentViewController:alertController animated:YES completion:nil];
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
