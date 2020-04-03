//
//  AccountSettingViewController.m
//  EMiOSVideoCallDemo
//
//  Created by lixiaoming on 2020/2/10.
//  Copyright © 2020 easemob. All rights reserved.
//

#import "AccountSettingViewController.h"
#import "EMDemoOption.h"
#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MessageUI.h>
#import "EMAlertController/EMAlertController.h"
#import "UIViewController+HUD.h"
#import "XDSDropDownMenu.h"
#import "ProfileViewController.h"

@interface AccountSettingViewController ()<MFMailComposeViewControllerDelegate>

@property (nonatomic) NSString* logPath;
@property (nonatomic) XDSDropDownMenu *sexDropDownMenu;
@property (nonatomic) UIButton* btn;
@end

@implementation AccountSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSubview];
    // Do any additional setup after loading the view.
}

- (void)setupSubview
{
    self.title = @"设置";
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _sexDropDownMenu = [[XDSDropDownMenu alloc] init];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
}

#pragma mark - Table View Data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 2)
        return 3;
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
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = @"设置";
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        UIButton* button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        //[button setTitle:@"上传日志" forState:UIControlStateNormal];
        button.frame = CGRectMake(10, 10, 40, 40);
        [button setImage:[UIImage imageNamed:@"goback"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:button];
    }else
        if(section == 1) {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            if(row == 0){
                [[cell viewWithTag:6000] removeFromSuperview];
                UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(60, 10, 100, 40)];
                label.text = [EMDemoOption sharedOptions].nickName;
                label.tag = 6000;
                [cell addSubview:label];
                
                UIButton* opButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                opButton.frame = CGRectMake(self.tableView.frame.size.width - 40, 10, 40, 40);
                [opButton setTitle:@">" forState:UIControlStateNormal];
                opButton.titleLabel.textAlignment = NSTextAlignmentRight;
                [opButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
                [opButton addTarget:self action:@selector(OperationAction:) forControlEvents:UIControlEventTouchUpInside];
                [cell addSubview:opButton];

                UIImageView *headimageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
                if([[EMDemoOption sharedOptions].headImage length] > 0) {
                    NSString* imageurl = [NSString stringWithFormat:@"https://download-sdk.oss-cn-beijing.aliyuncs.com/downloads/RtcDemo/headImage/%@" ,[EMDemoOption sharedOptions].headImage ];
                    [headimageView sd_setImageWithURL:[NSURL URLWithString:imageurl]];
                }else
                    headimageView.image = [UIImage imageNamed:@"APP"];
                headimageView.contentMode = UIViewContentModeScaleAspectFill;
                [cell addSubview:headimageView];
            }
        }else
            if(section == 2) {
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                if(row == 0) {
                    [[cell viewWithTag:section*10 + row + 10000] removeFromSuperview];
                    cell.textLabel.text = @"加入时打开摄像头";
                    UISwitch*switchControl = [[UISwitch alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width - 65, 10, 50, 40)];
                    switchControl.tag = section*10 + row + 10000;
                    [switchControl addTarget:self action:@selector(cellSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
                    [switchControl setOn:[EMDemoOption sharedOptions].openCamera];
                    [cell.contentView addSubview:switchControl];
                }
                if(row == 1) {
                    [[cell viewWithTag:section*10 + row + 10000] removeFromSuperview];
                    cell.textLabel.text = @"加入时打开麦克风";
                    UISwitch*switchControl = [[UISwitch alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width - 65, 10, 50, 40)];
                    switchControl.tag = section*10 + row + 10000;
                    [switchControl addTarget:self action:@selector(cellSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
                    [switchControl setOn:[EMDemoOption sharedOptions].openMicrophone];
                    [cell.contentView addSubview:switchControl];
                }
                if(row == 2) {
                    [[cell viewWithTag:1000] removeFromSuperview];
                    cell.textLabel.text = @"分辨率";
                    UIButton* button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                    NSString* title = @"720p";
                    switch ([EMDemoOption sharedOptions].resolutionrate) {
                        case ResolutionRate_720p:
                            title = @"720p";
                            break;
                        case ResolutionRate_480p:
                            title = @"480p";
                            break;
                        case ResolutionRate_360p:
                            title = @"360p";
                            break;
                        default:
                            break;
                    }
                    [button setTitle:title forState:UIControlStateNormal];
                    button.tag = 1000;
                    button.frame = CGRectMake(self.tableView.frame.size.width - 70, 10, 70, 40);
                    [button addTarget:self action:@selector(setResolutionAction:) forControlEvents:UIControlEventTouchUpInside];
                    [button addTarget:self action:@selector(hideMenu:) forControlEvents:UIControlEventTouchUpOutside];
                    [cell addSubview:button];
                }
            }else
                if(section == 3) {
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.textLabel.text = @"遇到问题？请上传日志";
                    UIButton* button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                    [button setTitle:@"上传日志" forState:UIControlStateNormal];
                    button.frame = CGRectMake(self.tableView.frame.size.width - 105, 5, 100, 40);
                    [button addTarget:self action:@selector(sendLogAction) forControlEvents:UIControlEventTouchUpInside];
                    [cell addSubview:button];
                }
    
    return cell;
}

-(void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)OperationAction:(UIButton*)button
{
    ProfileViewController* pVC = [[ProfileViewController alloc] init];
    [self.navigationController pushViewController:pVC animated:NO];
}

-(void)setResolutionAction:(UIButton*)button
{
    self.btn = button;
    NSArray *arr = @[@"720p",@"480p",@"360p"];
    CGRect btnFrame = [button.superview convertRect:button.frame toView:self.view];
    _sexDropDownMenu.delegate = self;//代理
    btnFrame.origin.y -= 40;
    if(button.tag == 2000){
        [_sexDropDownMenu hideDropDownMenuWithBtnFrame:btnFrame];
        button.tag = 1000;
        return;
    }
    [_sexDropDownMenu showDropDownMenu:button withButtonFrame:btnFrame arrayOfTitle:arr arrayOfImage:nil animationDirection:@"down"];
    //添加到主视图上
    [self.view addSubview:_sexDropDownMenu];
    
    //将dropDownMenu的tag值设为2000，表示已经打开了dropDownMenu
    button.tag = 2000;
}

-(void)hideMenu:(UIButton*)button
{
    CGRect btnFrame = [button.superview convertRect:button.frame toView:self.view];
    _sexDropDownMenu.delegate = self;//代理
    btnFrame.origin.y -= 40;
    [_sexDropDownMenu hideDropDownMenuWithBtnFrame:btnFrame];
    button.tag = 1000;
    return;
}
    
- (void)setDropDownDelegate:(XDSDropDownMenu *)sender
{
    self.btn.tag = 1000;
    NSString* title = [self.btn currentTitle];
    if([title isEqualToString:@"720p"]){
        [EMDemoOption sharedOptions].resolutionrate = ResolutionRate_720p;
    }
    if([title isEqualToString:@"480p"]){
        [EMDemoOption sharedOptions].resolutionrate = ResolutionRate_480p;
    }
    if([title isEqualToString:@"360p"]){
        [EMDemoOption sharedOptions].resolutionrate = ResolutionRate_360p;
    }
    [[EMDemoOption sharedOptions] archive];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if(_btn && _btn.tag == 2000){
        CGRect btnFrame = [_btn.superview convertRect:_btn.frame toView:self.view];
        btnFrame.origin.y -= 40;
        [_sexDropDownMenu hideDropDownMenuWithBtnFrame:btnFrame];
    }
}

- (void)cellSwitchValueChanged:(UISwitch *)aSwitch
{
    NSInteger tag = aSwitch.tag;
    if (tag == 10000 + 10*2) {
        [EMDemoOption sharedOptions].openCamera = [aSwitch isOn];
    } else if (tag == 1 + 10000 + 10*2) {
        [EMDemoOption sharedOptions].openMicrophone = [aSwitch isOn];
    }
    [[EMDemoOption sharedOptions] archive];
}

// Default is 1 if not implemented
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 15;//section头部高度
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
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
    return 15;
}
//section底部视图
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
    view.backgroundColor = [UIColor clearColor];
    return view;
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
    [self showHudInView:self.view hint:@"获取压缩路径..."];
    __weak typeof(self) weakSelf = self;
    [[EMClient sharedClient] getLogFilesPathWithCompletion:^(NSString *aPath, EMError *aError) {
        [weakSelf hideHud];
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

- (BOOL)textFieldShouldReturn:(UITextField *)aTextfield {
    [aTextfield resignFirstResponder];//关闭键盘
    [EMDemoOption sharedOptions].nickName = aTextfield.text;
    [[EMDemoOption sharedOptions] archive];
    return YES;
}

- (void)clickImage
{
}


-(BOOL)validateString:(NSString*)str
{
    // 编写正则表达式
    NSString *regex = @"^[\u4e00-\u9fa5A-Za-z0-9_-]*$";
    // 创建谓词对象并设定条件表达式
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    // 字符串判断，然后BOOL值
    BOOL result = [predicate evaluateWithObject:str];
    return result;
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
