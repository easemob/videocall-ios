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
    self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.9];
    
    self.roleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.roleButton.frame = CGRectMake(20, 10, 40, 40);
    EMConferenceRole currole = [EMDemoOption sharedOptions].conference.role;
    self.roleLable = [[UILabel alloc] initWithFrame:CGRectMake(20, 40, 40, 30)];
    self.roleLable.textAlignment = NSTextAlignmentCenter;
    self.roleLable.textColor = [UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1.0];
    [self.roleLable setFont:[UIFont fontWithName:@"Arial" size:10]];
    if(currole == EMConferenceRoleAudience)
    {
        [self.roleButton setImage:[UIImage imageNamed:@"上麦"] forState:UIControlStateNormal];
        self.roleLable.text = @"上麦";
    }
    else
    {
        [self.roleButton setImage:[UIImage imageNamed:@"下麦"] forState:UIControlStateNormal];
        self.roleLable.text = @"下麦";
    }
    self.roleButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.roleButton addTarget:self.confVC action:@selector(roleChangeAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.roleButton];
    [self.view addSubview:self.roleLable];
    
    self.inviteButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.inviteButton.frame = CGRectMake(80, 10, 40, 40);
    [self.inviteButton setTintColor:[UIColor whiteColor]];
    [self.view addSubview:self.inviteButton];
    [self.inviteButton setImage:[UIImage imageNamed:@"邀请"] forState:UIControlStateNormal];
    [self.inviteButton addTarget:self.confVC action:@selector(inviteAction) forControlEvents:UIControlEventTouchUpInside];
    self.inviteLable = [[UILabel alloc] initWithFrame:CGRectMake(80, 40, 40, 30)];
    self.inviteLable.textAlignment = NSTextAlignmentCenter;
    self.inviteLable.textColor = [UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1.0];
    [self.inviteLable setFont:[UIFont fontWithName:@"Arial" size:10]];
    self.inviteLable.text = @"邀请";
    [self.view addSubview:self.inviteLable];
    
    
    self.settingButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.settingButton.frame = CGRectMake(140, 10, 40, 40);
    //[self.settingButton setTitle:@"设置" forState:UIControlStateNormal];
    [self.settingButton setImage:[UIImage imageNamed:@"设置"] forState:UIControlStateNormal];
    [self.settingButton addTarget:self.confVC action:@selector(settingAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.settingButton setTintColor:[UIColor whiteColor]];
    [self.view addSubview:self.settingButton];
    self.settingLable = [[UILabel alloc] initWithFrame:CGRectMake(140, 40, 40, 30)];
    self.settingLable.textAlignment = NSTextAlignmentCenter;
    self.settingLable.textColor = [UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1.0];
    [self.settingLable setFont:[UIFont fontWithName:@"Arial" size:10]];
    self.settingLable.text = @"设置";
    [self.view addSubview:self.settingLable];
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
