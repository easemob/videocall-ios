//
//  RoomSettingViewController.m
//  EMiOSVideoCallDemo
//
//  Created by lixiaoming on 2020/2/11.
//  Copyright © 2020 easemob. All rights reserved.
//

#import "RoomSettingViewController.h"
#import "EMDemoOption.h"
#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MessageUI.h>
#import "EMAlertController/EMAlertController.h"
#import "ConferenceViewController.h"
#import "AppDelegate.h"

@interface RoomSettingViewController ()<MFMailComposeViewControllerDelegate>
@property (nonatomic) NSString* logPath;
@property (nonatomic) UIButton* logButton;
@end

@implementation RoomSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupSubview];
}
-(void) setupSubview
{
    //self.title = @"房间设置";
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.logButton = nil;
}

-(void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)_forcePortrait
{
    AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;//允许转成横屏
    appDelegate.curOrientationMask = UIInterfaceOrientationMaskPortrait;
    appDelegate.allowRotation = NO;
    //调用横屏代码

    NSNumber *resetOrientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationUnknown];

    [[UIDevice currentDevice] setValue:resetOrientationTarget forKey:@"orientation"];

    NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];

    [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];

    [UIViewController attemptRotationToDeviceOrientation];
}
- (void)viewWillAppear:(BOOL)animated
{
    [self _forcePortrait];
    [self.navigationController setNavigationBarHidden:YES];
}


#pragma mark - Table View Data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 2) {
        NSInteger count = [EMDemoOption sharedOptions].conference.adminIds.count;
        return count;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    static NSString *cellIdentifier = @"cellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
    cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:
        UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    if(section == 0){
        cell.textLabel.text = @"房间设置";
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        UIButton* button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        //[button setTitle:@"上传日志" forState:UIControlStateNormal];
        button.frame = CGRectMake(5, 5, 40, 40);
        [button setImage:[UIImage imageNamed:@"goback"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:button];
    }else
    if(section == 1) {
        if(row == 0){
            cell.textLabel.text = @"房间名称";
            UILabel * username = [[UILabel alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width - 250, 5, 240, 40)];
            username.text = [EMDemoOption sharedOptions].roomName;
            username.textAlignment = NSTextAlignmentRight;
            [cell addSubview:username];
        }
//        if(row == 2)
//        {
//            cell.textLabel.text = @"主持人";
//            if([EMDemoOption sharedOptions].conference.adminIds.count > 0){
//                UILabel * username = [[UILabel alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width - 250, 10, 250, 40)];
//                if(![[[EMDemoOption sharedOptions].conference.adminIds objectAtIndex:0] isEqualToString:[EMDemoOption sharedOptions].appkey])
//                {
//                username.text = [[[EMDemoOption sharedOptions].conference.adminIds objectAtIndex:0] substringFromIndex:([[EMDemoOption sharedOptions].appkey length]+1)];
//                [cell addSubview:username];
//                }
//            };
//        }
    }
    if(section == 2) {
        if(row < ([EMDemoOption sharedOptions].conference.adminIds.count))
        {
            NSString * adminMemName = [[EMDemoOption sharedOptions].conference.adminIds objectAtIndex:row];
            NSString * myMemName = [NSString stringWithFormat:@"%@_%@",[EMDemoOption sharedOptions].appkey,[EMDemoOption sharedOptions].userid];
            NSString* nickName = adminMemName;
            if([adminMemName isEqualToString:myMemName])
            {
                if( [[EMDemoOption sharedOptions].conference.nickName length] > 0)
                    nickName = [EMDemoOption sharedOptions].conference.nickName;
            }else if(![adminMemName isEqualToString:[EMDemoOption sharedOptions].appkey]) {
                ConferenceViewController* ConfrVC = [self getConfVC];
                if(ConfrVC && ConfrVC.membersDict) {
                    EMCallMember* member = [ConfrVC.membersDict objectForKey:adminMemName];
                    if(member){
                        nickName = member.nickname;
                    }
                }
            }
            if([nickName hasPrefix:[EMDemoOption sharedOptions].appkey] && [nickName length] > [[EMDemoOption sharedOptions].appkey length])
                nickName = [adminMemName substringFromIndex:([[EMDemoOption sharedOptions].appkey length]+1)];
            cell.textLabel.text = nickName;
        }
    }
    if(section == 3) {
        if(row == 0) {
            cell.textLabel.text = @"遇到问题？请上传日志";
            if(self.logButton)
               [self.logButton removeFromSuperview];
            self.logButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [self.logButton  setTitle:@"上传日志" forState:UIControlStateNormal];
            self.logButton.frame = CGRectMake(self.tableView.frame.size.width - 105, 5, 100, 30);
            [self.logButton  addTarget:self action:@selector(sendLogAction) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:self.logButton ];
        }
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0)
        return 1;
    if(section == 1)
        return 10;
    return 30;//section头部高度
}
//section头部视图
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 1)];
    view.backgroundColor = [UIColor clearColor];
    if(section == 2){
        UILabel* lable = [[UILabel alloc] initWithFrame:CGRectMake(10, 2, 80, 25)];
        lable.text = @"主持人";
        if([EMDemoOption sharedOptions].conference.role > EMConferenceRoleAudience) {
            UIButton* button = [UIButton buttonWithType:UIButtonTypeSystem];
            button.frame = CGRectMake( self.view.bounds.size.width-120, 2, 100, 25);
            if([EMDemoOption sharedOptions].conference.role == EMConferenceRoleAdmin) {
                [button setTitle:@"放弃主持人" forState:UIControlStateNormal];
                button.tag = 4000;
            }else if([EMDemoOption sharedOptions].conference.role == EMConferenceRoleSpeaker){
                button.tag = 4001;
                [button setTitle:@"申请主持人" forState:UIControlStateNormal];
            }
            button.titleLabel.textAlignment = NSTextAlignmentRight;
            [button addTarget:self action:@selector(changeRole:) forControlEvents:UIControlEventTouchUpInside];
            [view addSubview:button];
        }
        [view addSubview:lable];
    }
    return view ;
}
//section底部间距
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}
//section底部视图
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

// Default is 1 if not implemented
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:
  (NSInteger)section{
    return @"";
}
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:
  (NSInteger)section{
    return @"";
}

- (NSString *)getAdminId
{
    NSString *adminName = [[EMDemoOption sharedOptions].conference.adminIds objectAtIndex:0];
    ConferenceViewController* pVC = [self getConfVC];
    if([adminName length] > 0 &&pVC) {
        EMCallMember * member = [pVC.membersDict objectForKey:adminName];
        if(member) {
            return member.memberId;
        }
    }
    return nil;
}

- (void)changeRole:(UIButton*)button
{
    if(button.tag == 4000){
        if([[EMDemoOption sharedOptions].conference.adminIds count] == 1) {
            [EMAlertController showErrorAlert:@"您是唯一主持人，禁止放弃主持人"];
            return;
        }
        NSString* memId = [NSString stringWithFormat:@"%@_%@",[EMDemoOption sharedOptions].appkey,[EMDemoOption sharedOptions].userid ];
        [[[EMClient sharedClient] conferenceManager] changeMemberRoleWithConfId:[EMDemoOption sharedOptions].conference.confId memberNames:@[memId] role:EMConferenceRoleSpeaker completion:^(EMError *aError){
            if(aError){
                // 操作失败
                [EMAlertController showErrorAlert:@"操作失败"];
            }
            [[[EMClient sharedClient] conferenceManager] getConference:[EMDemoOption sharedOptions].conference.confId password:[EMDemoOption sharedOptions].roomPswd completion:^(EMCallConference *aCall, EMError *aError) {
                [EMDemoOption sharedOptions].conference.adminIds = [aCall.adminIds copy];
                [EMDemoOption sharedOptions].conference.memberCount = aCall.memberCount;
                [EMDemoOption sharedOptions].conference.speakerIds = [aCall.speakerIds copy];
                [EMDemoOption sharedOptions].conference.audiencesCount = aCall.audiencesCount;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                    ConferenceViewController* confrVC = [self getConfVC];
                    if(confrVC)
                       [confrVC updateAdminView];
                });
                
            }];
        }];
    }else{
        NSString* adminId = [self getAdminId];
        if([adminId length] > 0) {
            [[[EMClient sharedClient] conferenceManager] requestTobeAdmin:[EMDemoOption sharedOptions].conference adminId:adminId completion:^(EMError *aError) {
                if(!aError){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [EMAlertController showInfoAlert:@"主持人申请已提交，请等待主持人审核"];
                    });
                }
            }];
        }
    }
}

- (void)sendLogAction
{
    if ([MFMailComposeViewController canSendMail] == false) {
        [EMAlertController showErrorAlert:@"系统邮箱未设置"];
        return;
    }
    
    EMError *error = nil;
    //[self showHudInView:self.view hint:@"获取压缩路径..."];
    __weak typeof(self) weakSelf = self;
    [[EMClient sharedClient] getLogFilesPathWithCompletion:^(NSString *aPath, EMError *aError) {
        //[weakSelf hideHud];
        if (error) {
            return ;
        }
        
        weakSelf.logPath = aPath;
        MFMailComposeViewController *mailCompose = [[MFMailComposeViewController alloc] init];
        if(mailCompose) {
            //设置代理
            [mailCompose setMailComposeDelegate:self];
            //设置邮件主题
            [mailCompose setSubject:@"这是Log文件"];
            //设置邮件内容
            NSString *emailBody = @"测试发送log压缩文件";
            [mailCompose setMessageBody:emailBody isHTML:NO];
            
            //设置邮件附件{mimeType:文件格式|fileName:文件名}
            NSData *pData = [[NSData alloc] initWithContentsOfFile:aPath];
            NSString *type = [aPath pathExtension];
            NSString *name = [aPath lastPathComponent];
            [mailCompose addAttachmentData:pData mimeType:type fileName:name];
            
            //设置邮件视图在当前视图上显示方式
            [self presentViewController:mailCompose animated:YES completion:nil];
        }
    }];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(nullable NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            [EMAlertController showInfoAlert:@"邮件发送取消"];
            break;
        case MFMailComposeResultSaved:
            [EMAlertController showSuccessAlert:@"邮件保存成功"];
            break;
        case MFMailComposeResultSent:
            [EMAlertController showSuccessAlert:@"邮件发送成功"];
            break;
        case MFMailComposeResultFailed:
            [EMAlertController showErrorAlert:@"邮件发送失败"];
            break;
        default:
            break;
    }
    
    [[NSFileManager defaultManager] removeItemAtPath:self.logPath error:nil];
    self.logPath = nil;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(ConferenceViewController*) getConfVC
{
    UIViewController* lastVC =  [self.navigationController.viewControllers objectAtIndex:(self.navigationController.viewControllers.count-2)];
    if([lastVC isKindOfClass:[ConferenceViewController class]]){
        ConferenceViewController* confVC = (ConferenceViewController*)lastVC;
        return confVC;
    }
    return nil;
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
