//
//  InviteViewController.m
//  EMiOSVideoCallDemo
//
//  Created by lixiaoming on 2020/9/14.
//  Copyright © 2020 easemob. All rights reserved.
//

#import "InviteViewController.h"
#import "EMDemoOption.h"

@interface InviteViewController ()
@property (nonatomic) UILabel* inviteMessage;
@property (nonatomic) UIButton* exitButton;
@end

@implementation InviteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupSubViews];
}

- (void)setupSubViews {
    [self.view setBackgroundColor:[UIColor whiteColor]];
    _inviteMessage = [[UILabel alloc] init];
    [self.view addSubview:_inviteMessage];
    [_inviteMessage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.width.equalTo(self.view);
        make.height.equalTo(self.view).with.multipliedBy(0.5);
    }];
    NSString* text = [NSString stringWithFormat:@"App下载地址：http://www.easemob.com/download/app/meetingdemo \r\n房间名称：%@ \r\n房间密码：%@",[EMDemoOption sharedOptions].roomName,[EMDemoOption sharedOptions].roomPswd];
    _inviteMessage.numberOfLines = 0;
    _inviteMessage.text = text;
    
    _exitButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_exitButton setTitle:@"退出" forState:UIControlStateNormal];
    [self.view addSubview:_exitButton];
    [_exitButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view);
        make.height.equalTo(self.view).with.multipliedBy(0.25);
        make.bottom.equalTo(self.view);
        make.left.equalTo(self.view);
    }];
    [_exitButton addTarget:self action:@selector(exitAction) forControlEvents:UIControlEventTouchUpInside];
}

- (void)exitAction
{
    [self willMoveToParentViewController:nil];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
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
