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
    [self.view setBackgroundColor:[UIColor blackColor]];
    self.roomNameLable = [[UILabel alloc] initWithFrame:CGRectMake(59,50, 48, 25)];
    self.roomNameLable.text = [EMDemoOption sharedOptions].roomName;
    self.roomNameLable.textColor = [UIColor whiteColor];
    [self.roomNameLable setFont:[UIFont systemFontOfSize:20]];
    [self.view addSubview:self.roomNameLable];
    self.roomNameLable.textAlignment = NSTextAlignmentCenter;
    
    self.selectDevice = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.selectDevice.frame = CGRectMake(self.view.bounds.size.width - 50, 150, 40, 40);
    [self.selectDevice setImage:[UIImage imageNamed:@"switchDevice"] forState:UIControlStateNormal];
    [self.selectDevice addTarget:self.confVC action:@selector(selectDeviceAction) forControlEvents:UIControlEventTouchUpInside];
    [self.selectDevice setTintColor:[UIColor whiteColor]];
    [self.view addSubview:self.selectDevice];
    [self.selectDevice mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@30);
        make.height.equalTo(@30);
        make.bottom.equalTo(self.view).with.offset(-5);
        make.left.equalTo(@10);
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
    [self.switchCameraButton setImage:[UIImage imageNamed:@"swtichcamera"] forState:UIControlStateNormal];
    [self.switchCameraButton setImage:[UIImage imageNamed:@"swtichcamera"] forState:UIControlStateDisabled];
    //[self.switchCameraButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    //[self.switchCameraButton setTintColor:[UIColor redColor]];
    [self.switchCameraButton addTarget:self.confVC action:@selector(switchCamaraAction) forControlEvents:UIControlEventTouchUpInside];
    //设置按下状态的颜色
    [self.switchCameraButton setTitleColor:[UIColor orangeColor] forState:UIControlStateHighlighted];
    //设置按钮的风格颜色
    //[self.switchCameraButton setTintColor:[UIColor blueColor]];
    [self.switchCameraButton setTitleColor:[UIColor blackColor] forState:UIControlStateDisabled];
    [self.switchCameraButton setEnabled:NO];
    [self.switchCameraButton setTintColor:[UIColor whiteColor] ];
    [self.view addSubview:_switchCameraButton];
    [self.switchCameraButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@30);
        make.height.equalTo(@30);
        make.bottom.equalTo(self.view).with.offset(-5);
        make.left.equalTo(self.selectDevice.mas_right).with.offset(10);
    }];
    
    self.leaveConfrButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.leaveConfrButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
//    [self.leaveConfrButton setImage:[UIImage imageNamed:@"leaveconfr"] forState:UIControlStateNormal];
    [self.leaveConfrButton setTitle:@"离开会议" forState:UIControlStateNormal];
    [self.leaveConfrButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    //[self.leaveConfrButton setTintColor:[UIColor whiteColor]];
    [self.leaveConfrButton addTarget:self.confVC action:@selector(hangupAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.leaveConfrButton];
    [self.leaveConfrButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@80);
        make.height.equalTo(@30);
        make.bottom.equalTo(self.view).with.offset(-5);
        make.right.equalTo(self.view).with.offset(-10);
    }];
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
