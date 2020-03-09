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

@interface RoomSettingViewController ()<MFMailComposeViewControllerDelegate>
@property (nonatomic) NSString* logPath;
@end

@implementation RoomSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupSubview];
    [self.navigationController setNavigationBarHidden:YES];
}
-(void) setupSubview
{
    [self.navigationController setNavigationBarHidden:NO];
    //self.title = @"房间设置";
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.navigationController setNavigationBarHidden:YES];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO];
}


-(void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Table View Data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 1)
        return 3;
    else
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
            UILabel * username = [[UILabel alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width - 250, 10, 250, 40)];
            username.text = [EMDemoOption sharedOptions].roomName;
            [cell addSubview:username];
        }
        if(row == 1)
        {
            cell.textLabel.text = @"房间密码";
            UILabel * username = [[UILabel alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width - 250, 10, 250, 40)];
            username.text = [EMDemoOption sharedOptions].roomPswd;
            [cell addSubview:username];
        }
        if(row == 2)
        {
            cell.textLabel.text = @"管理员";
            if([EMDemoOption sharedOptions].conference.adminIds.count > 0){
                UILabel * username = [[UILabel alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width - 250, 10, 250, 40)];
                if(![[[EMDemoOption sharedOptions].conference.adminIds objectAtIndex:0] isEqualToString:[EMDemoOption sharedOptions].appkey])
                {
                username.text = [[[EMDemoOption sharedOptions].conference.adminIds objectAtIndex:0] substringFromIndex:([[EMDemoOption sharedOptions].appkey length]+1)];
                [cell addSubview:username];
                }
            };
        }
    }
    if(section == 2) {
        if(row == 0) {
            cell.textLabel.text = @"遇到问题";
            UIButton* button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [button setTitle:@"上传日志" forState:UIControlStateNormal];
            button.frame = CGRectMake(self.tableView.frame.size.width - 105, 10, 100, 40);
            [button addTarget:self action:@selector(sendLogAction) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:button];
        }
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0)
        return 1;
    return 30;//section头部高度
}
//section头部视图
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
view.backgroundColor = [UIColor clearColor];
return view ;
}
//section底部间距
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 30;
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
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:
  (NSInteger)section{
    return @"";
}
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:
  (NSInteger)section{
    return @"";
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
