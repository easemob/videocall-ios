//
//  MoreOptionViewController.m
//  EMiOSVideoCallDemo
//
//  Created by lixiaoming on 2020/9/15.
//  Copyright © 2020 easemob. All rights reserved.
//

#import "MoreOptionViewController.h"
#import "ConferenceViewController.h"
#import "EMDemoOption.h"

@interface MoreOptionViewController ()

@end

@implementation MoreOptionViewController

- (instancetype)initWithConfVC:(UIViewController*)confVC
{
    self = [super init];
    if(self) {
        _confVC = confVC;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupSubViews];
}

-(void)setupSubViews
{
    self.view.backgroundColor = [UIColor blackColor];
    self.settingButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.settingButton.frame = CGRectMake(20, 10, 30, 30);
    //[self.settingButton setTitle:@"设置" forState:UIControlStateNormal];
    [self.settingButton setImage:[UIImage imageNamed:@"setting"] forState:UIControlStateNormal];
    [self.settingButton addTarget:self.confVC action:@selector(settingAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.settingButton setTintColor:[UIColor whiteColor]];
    [self.view addSubview:self.settingButton];
    self.settingLable = [[UILabel alloc] initWithFrame:CGRectMake(15, 40, 40, 30)];
    self.settingLable.textAlignment = NSTextAlignmentCenter;
    self.settingLable.textColor = [UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1.0];
    [self.settingLable setFont:[UIFont fontWithName:@"Arial" size:10]];
    self.settingLable.text = @"设置";
    [self.view addSubview:self.settingLable];
    
    self.inviteButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.inviteButton.frame = CGRectMake(80, 10, 30, 30);
    [self.inviteButton setTintColor:[UIColor whiteColor]];
    [self.view addSubview:self.inviteButton];
    [self.inviteButton setImage:[UIImage imageNamed:@"invite"] forState:UIControlStateNormal];
    [self.inviteButton addTarget:self.confVC action:@selector(inviteAction) forControlEvents:UIControlEventTouchUpInside];
    self.inviteLable = [[UILabel alloc] initWithFrame:CGRectMake(73, 40, 40, 30)];
    self.inviteLable.textAlignment = NSTextAlignmentCenter;
    self.inviteLable.textColor = [UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1.0];
    [self.inviteLable setFont:[UIFont fontWithName:@"Arial" size:10]];
    self.inviteLable.text = @"邀请";
    [self.view addSubview:self.inviteLable];
    
    self.roleButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.roleButton.frame = CGRectMake(140, 10, 30, 30);
    EMConferenceRole currole = [EMDemoOption sharedOptions].conference.role;
    self.roleLable = [[UILabel alloc] initWithFrame:CGRectMake(133, 40, 40, 30)];
    self.roleLable.textAlignment = NSTextAlignmentCenter;
    self.roleLable.textColor = [UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1.0];
    [self.roleLable setFont:[UIFont fontWithName:@"Arial" size:10]];
    if(currole == EMConferenceRoleAudience)
    {
        [self.roleButton setImage:[UIImage imageNamed:@"上麦"] forState:UIControlStateNormal];
        [self.roleButton setTintColor:[UIColor whiteColor]];
        self.roleLable.text = @"上麦";
    }
    else
    {
        [self.roleButton setImage:[UIImage imageNamed:@"下麦"] forState:UIControlStateNormal];
        [self.roleButton setTintColor:[UIColor redColor]];
        self.roleLable.text = @"下麦";
    }
    self.roleButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.roleButton addTarget:self.confVC action:@selector(roleChangeAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.roleButton];
    [self.view addSubview:self.roleLable];
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
