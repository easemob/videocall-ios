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
@property (nonatomic) UILabel* downloadAppLable;
@property (nonatomic) UILabel* roomNameLable;
@property (nonatomic) UILabel* roomPswdLable;
@property (nonatomic) UIButton* exitButton;
@property (nonatomic) UIButton* cpInviteMsgButton;
@end

@implementation InviteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupSubViews];
}

- (void)setupSubViews {
    [self.view setBackgroundColor:[UIColor whiteColor]];
    _downloadAppLable = [[UILabel alloc] init];
    [self.view addSubview:_downloadAppLable];
    [_downloadAppLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@10);
        make.left.equalTo(self.view);
        make.width.equalTo(self.view);
        make.height.equalTo(@50);
    }];
    NSString* text = @"App下载地址：http://www.easemob.com/download/app/meetingdemo";
    _downloadAppLable.numberOfLines = 0;
    _downloadAppLable.text = text;
    
    _roomNameLable = [[UILabel alloc] init];
    [self.view addSubview:_roomNameLable];
    [_roomNameLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.downloadAppLable.mas_bottom);
        make.left.equalTo(self.view);
        make.width.equalTo(self.view);
        make.height.equalTo(@30);
    }];
    text = [NSString stringWithFormat:@"房间名称：%@",[EMDemoOption sharedOptions].roomName];
    _roomNameLable.text = text;
    
    _roomPswdLable = [[UILabel alloc] init];
    [self.view addSubview:_roomPswdLable];
    [_roomPswdLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.roomNameLable.mas_bottom);
        make.left.equalTo(self.view);
        make.width.equalTo(self.view);
        make.height.equalTo(@30);
    }];
    text = [NSString stringWithFormat:@"房间密码：%@",[EMDemoOption sharedOptions].roomPswd];
    _roomPswdLable.text = text;
    
    _exitButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_exitButton setTitle:@"退出" forState:UIControlStateNormal];
    [self.view addSubview:_exitButton];
    [_exitButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view);
        make.height.equalTo(@30);
        make.bottom.equalTo(self.view);
        make.left.equalTo(self.view);
    }];
    [_exitButton addTarget:self action:@selector(exitAction) forControlEvents:UIControlEventTouchUpInside];
    
    _cpInviteMsgButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_cpInviteMsgButton setTitle:@"复制邀请信息" forState:UIControlStateNormal];
    [self.view addSubview:_cpInviteMsgButton];
    [_cpInviteMsgButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view);
        make.height.equalTo(@30);
        make.bottom.equalTo(self.exitButton.mas_top);
        make.left.equalTo(self.view);
    }];
    [_cpInviteMsgButton addTarget:self action:@selector(copyInviteMsgAction) forControlEvents:UIControlEventTouchUpInside];
}

- (void)exitAction
{
    [self willMoveToParentViewController:nil];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

- (void)copyInviteMsgAction
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = [[_downloadAppLable.text stringByAppendingFormat:@"\n%@",_roomNameLable.text] stringByAppendingFormat:@"\n%@",_roomPswdLable.text];
    NSLog(@"pastestring:%@",pasteboard.string);
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
