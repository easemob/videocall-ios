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

@interface AccountSettingViewController ()
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
    self.title = @"个人设置";
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _sexDropDownMenu = [[XDSDropDownMenu alloc] init];

}

#pragma mark - Table View Data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0)
        return 4;
    if(section == 1)
        return 1;
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
    if(section == 0) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if(row == 0){
            UILabel * username = [[UILabel alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width - 200, 10, 200, 40)];
            username.text = [EMDemoOption sharedOptions].userid;
            [cell addSubview:username];
            cell.textLabel.text = @"环信ID:" ;
        }
        if(row == 1) {
            cell.textLabel.text = @"加入时打开摄像头";
            UISwitch*switchControl = [[UISwitch alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width - 65, 10, 50, 40)];
            switchControl.tag = section*10 + row + 10000;
            [switchControl addTarget:self action:@selector(cellSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
            [switchControl setOn:[EMDemoOption sharedOptions].openCamera];
            [cell.contentView addSubview:switchControl];
        }
        if(row == 2) {
            cell.textLabel.text = @"加入时打开麦克风";
            UISwitch*switchControl = [[UISwitch alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width - 65, 10, 50, 40)];
            switchControl.tag = section*10 + row + 10000;
            [switchControl addTarget:self action:@selector(cellSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
            [switchControl setOn:[EMDemoOption sharedOptions].openMicrophone];
            [cell.contentView addSubview:switchControl];
        }
        if(row == 3) {
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
    }
    if(section == 1) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = @"遇到问题";
        UIButton* button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button setTitle:@"上传日志" forState:UIControlStateNormal];
        button.frame = CGRectMake(self.tableView.frame.size.width - 105, 10, 100, 40);
        [button addTarget:self action:@selector(sendLogAction) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:button];
    }
    
    return cell;
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
    if (tag == 1 + 10000) {
        [EMDemoOption sharedOptions].openCamera = [aSwitch isOn];
    } else if (tag == 2 + 10000) {
        [EMDemoOption sharedOptions].openMicrophone = [aSwitch isOn];
    }
    [[EMDemoOption sharedOptions] archive];
}

// Default is 1 if not implemented
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
