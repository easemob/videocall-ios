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
//#define ENABLE_AUDIORECORD

@interface UpdateCDNUrlAlertController : UIAlertController
-(void)textChange:(UITextField*)textField;
@end
@implementation UpdateCDNUrlAlertController

-(void)textChange:(UITextField *)textField
{
    if([self.textFields[0].text length] == 0)
        self.actions[0].enabled = NO;
    else
        self.actions[0].enabled = YES;
}

@end

@interface AccountSettingViewController ()<MFMailComposeViewControllerDelegate>

@property (nonatomic) NSString* logPath;
@property (nonatomic) XDSDropDownMenu *sexDropDownMenu;
@property (nonatomic) XDSDropDownMenu *recordExtDropDownMenu;
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
    _recordExtDropDownMenu = [[XDSDropDownMenu alloc] init];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
}

#pragma mark - Table View Data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 2)
    {
        return 13;
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
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = @"设置";
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        UIButton* button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        //[button setTitle:@"上传日志" forState:UIControlStateNormal];
        button.frame = CGRectMake(5, 5, 40, 40);
        [button setImage:[UIImage imageNamed:@"goback"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:button];
    }else
        if(section == 1) {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            if(row == 0){
                [[cell viewWithTag:6000] removeFromSuperview];
                UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(60, 1, 100, 40)];
                label.text = [EMDemoOption sharedOptions].nickName;
                label.tag = 6000;
                [cell addSubview:label];
                
                UIButton* opButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                opButton.frame = CGRectMake(self.tableView.frame.size.width - 40, 1, 40, 40);
                [opButton setTitle:@">" forState:UIControlStateNormal];
                opButton.titleLabel.textAlignment = NSTextAlignmentRight;
                [opButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
                [opButton addTarget:self action:@selector(OperationAction:) forControlEvents:UIControlEventTouchUpInside];
                [cell addSubview:opButton];

                UIImageView *headimageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 1, 40, 40)];
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
                    UISwitch*switchControl = [[UISwitch alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width - 65, 1, 50, 40)];
                    switchControl.tag = section*10 + row + 10000;
                    [switchControl addTarget:self action:@selector(cellSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
                    [switchControl setOn:[EMDemoOption sharedOptions].openCamera];
                    [cell.contentView addSubview:switchControl];
                }
                if(row == 1) {
                    [[cell viewWithTag:section*10 + row + 10000] removeFromSuperview];
                    cell.textLabel.text = @"加入时打开麦克风";
                    UISwitch*switchControl = [[UISwitch alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width - 65, 1, 50, 40)];
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
                    button.frame = CGRectMake(self.tableView.frame.size.width - 70, 1, 70, 40);
                    [button addTarget:self action:@selector(setResolutionAction:) forControlEvents:UIControlEventTouchUpInside];
                    [button addTarget:self action:@selector(hideMenu:) forControlEvents:UIControlEventTouchUpOutside];
                    [cell addSubview:button];
                }
                if(row == 3) {
                    [[cell viewWithTag:section*10 + row + 10000] removeFromSuperview];
                    cell.textLabel.text = @"使用后置摄像头";
                    UISwitch*switchControl = [[UISwitch alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width - 65, 1, 50, 40)];
                    switchControl.tag = section*10 + row + 10000;
                    [switchControl addTarget:self action:@selector(cellSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
                    [switchControl setOn:[EMDemoOption sharedOptions].isBackCamera];
                    [cell.contentView addSubview:switchControl];
                }
                if(row == 4) {
                    [[cell viewWithTag:section*10 + row + 10000] removeFromSuperview];
                    cell.textLabel.text = @"开启服务端录制";
                    UISwitch*switchControl = [[UISwitch alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width - 65, 1, 50, 40)];
                    switchControl.tag = section*10 + row + 10000;
                    [switchControl addTarget:self action:@selector(cellSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
                    [switchControl setOn:[EMDemoOption sharedOptions].isRecord];
                    [cell.contentView addSubview:switchControl];
                }
                if(row == 5) {
                    [[cell viewWithTag:section*10 + row + 10000] removeFromSuperview];
                    cell.textLabel.text = @"开启录制合流";
                    UISwitch*switchControl = [[UISwitch alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width - 65, 1, 50, 40)];
                    switchControl.tag = section*10 + row + 10000;
                    [switchControl addTarget:self action:@selector(cellSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
                    [switchControl setOn:[EMDemoOption sharedOptions].isMerge];
                    [cell.contentView addSubview:switchControl];
                }
                if(row == 6) {
                    [[cell viewWithTag:section*10 + row + 10000] removeFromSuperview];
                    cell.textLabel.text = @"开启CDN推流";
                    UISwitch*switchControl = [[UISwitch alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width - 65, 1, 50, 40)];
                    switchControl.tag = section*10 + row + 10000;
                    [switchControl addTarget:self action:@selector(cellSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
                    [switchControl setOn:[EMDemoOption sharedOptions].openCDN];
                    [cell.contentView addSubview:switchControl];
                }
                if(row == 7) {
                    cell.textLabel.text = [NSString stringWithFormat:@"cdn推流Url:%@",[EMDemoOption sharedOptions].cdnUrl ];
                    cell.textLabel.numberOfLines = 0;
                    
                    UIButton* opButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                    opButton.frame = CGRectMake(self.tableView.frame.size.width - 40, 1, 40, 40);
                    [opButton setTitle:@">" forState:UIControlStateNormal];
                    opButton.titleLabel.textAlignment = NSTextAlignmentRight;
                    [opButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
                    opButton.enabled = [EMDemoOption sharedOptions].openCDN;
                    [opButton addTarget:self action:@selector(editCDNUrl:) forControlEvents:UIControlEventTouchUpInside];
                    [cell addSubview:opButton];
                }
#ifdef ENABLE_AUDIORECORD
                if(row == 8) {
                    [[cell viewWithTag:section*10 + row + 10000] removeFromSuperview];
                    cell.textLabel.text = @"开启纯音频推流";
                    UISwitch*switchControl = [[UISwitch alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width - 65, 1, 50, 40)];
                    switchControl.tag = section*10 + row + 10000;
                    [switchControl addTarget:self action:@selector(cellSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
                    [switchControl setOn:[EMDemoOption sharedOptions].livePureAudio];
                    switchControl.enabled = [EMDemoOption sharedOptions].openCDN;
                    [cell.contentView addSubview:switchControl];
                }
                if(row == 9) {
                    [[cell viewWithTag:3000] removeFromSuperview];
                    cell.textLabel.text = @"音频格式";
                    UIButton* button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                    NSString* title = @"auto";
                    switch ([EMDemoOption sharedOptions].recordExt) {
                        case RecordExtWAV:
                            title = @"wav";
                            break;
                        case RecordExtMP3:
                            title = @"mp3";
                            break;
                        case RecordExtMP4:
                            title = @"mp4";
                            break;
                        case RecordExtM4A:
                            title = @"m4a";
                            break;
                        case RecordExtAUTO:
                            title = @"auto";
                            break;
                        default:
                            break;
                    }
                    [button setTitle:title forState:UIControlStateNormal];
                    button.tag = 3000;
                    button.frame = CGRectMake(self.tableView.frame.size.width - 70, 1, 70, 40);
                    [button addTarget:self action:@selector(setRecordExtAction:) forControlEvents:UIControlEventTouchUpInside];
                    [button addTarget:self action:@selector(hideRecordExtMenu:) forControlEvents:UIControlEventTouchUpOutside];
                    [cell addSubview:button];
                }
#endif
                if(row == 10) {
                    [[cell viewWithTag:section*10 + row + 10000] removeFromSuperview];
                    cell.textLabel.text = @"沙箱环境";
                    UISwitch*switchControl = [[UISwitch alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width - 65, 1, 50, 40)];
                    switchControl.tag = section*10 + row + 10000;
                    [switchControl addTarget:self action:@selector(cellSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
                    [switchControl setOn:[EMDemoOption sharedOptions].specifyServer];
                    [cell.contentView addSubview:switchControl];
                }
                if(row == 11) {
                    [[cell viewWithTag:section*10 + row + 10000] removeFromSuperview];
                    cell.textLabel.text = @"清晰度优先";
                    UISwitch*switchControl = [[UISwitch alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width - 65, 1, 50, 40)];
                    switchControl.tag = section*10 + row + 10000;
                    [switchControl addTarget:self action:@selector(cellSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
                    [switchControl setOn:[EMDemoOption sharedOptions].isClarityFirst];
                    [cell.contentView addSubview:switchControl];
                }
                if(row == 12) {
                    [[cell viewWithTag:section*10 + row + 10000] removeFromSuperview];
                    cell.textLabel.text = @"以观众加入";
                    UISwitch*switchControl = [[UISwitch alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width - 65, 1, 50, 40)];
                    switchControl.tag = section*10 + row + 10000;
                    [switchControl addTarget:self action:@selector(cellSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
                    [switchControl setOn:[EMDemoOption sharedOptions].isJoinAsAudience];
                    [cell.contentView addSubview:switchControl];
                }
            }else
                if(section == 3) {
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.textLabel.text = @"遇到问题？请上传日志";
                    UIButton* button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                    [button setTitle:@"上传日志" forState:UIControlStateNormal];
                    button.frame = CGRectMake(self.tableView.frame.size.width - 105, 1, 100, 40);
                    [button addTarget:self action:@selector(sendLogAction) forControlEvents:UIControlEventTouchUpInside];
                    [cell addSubview:button];
                }
    
    return cell;
}

-(void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)editCDNUrl:(UIButton*)button
{
    __weak typeof(self) weakself = self;
    UpdateCDNUrlAlertController *alertController = [UpdateCDNUrlAlertController alertControllerWithTitle:@"请输入CDN地址" message:nil preferredStyle:UIAlertControllerStyleAlert];
        //以下方法就可以实现在提示框中输入文本；
        
        //在AlertView中添加一个输入框
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            
            textField.placeholder = @"CDN地址";
            textField.text = [EMDemoOption sharedOptions].cdnUrl;
            //[[NSNotificationCenter defaultCenter] addObserver:alertController selector:@selector(textChange:) name:UITextFieldTextDidChangeNotification object:textField];
        }];
        UIAlertAction* action = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            UITextField *envirnmentNameTextField = alertController.textFields.firstObject;
            
            [EMDemoOption sharedOptions].cdnUrl = envirnmentNameTextField.text;
            [[EMDemoOption sharedOptions] archive];
            [weakself.tableView reloadData];
        }];
        [alertController addAction:action];
        
        //添加一个取消按钮
        [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil]];
        
        //present出AlertView
        [self presentViewController:alertController animated:true completion:nil];
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

-(void)setRecordExtAction:(UIButton*)button
{
    self.btn = button;
    NSArray *arr = @[@"mp3",@"wav",@"m4a",@"mp4",@"auto"];
    CGRect btnFrame = [button.superview convertRect:button.frame toView:self.view];
    btnFrame.origin.y = btnFrame.origin.y - 100;
    _recordExtDropDownMenu.delegate = self;//代理
    btnFrame.origin.y -= 40;
    if(button.tag == 4000){
        [_recordExtDropDownMenu hideDropDownMenuWithBtnFrame:btnFrame];
        button.tag = 3000;
        return;
    }
    [_recordExtDropDownMenu showDropDownMenu:button withButtonFrame:btnFrame arrayOfTitle:arr arrayOfImage:nil animationDirection:@"down"];
    //添加到主视图上
    [self.view addSubview:_recordExtDropDownMenu];
    
    //将dropDownMenu的tag值设为2000，表示已经打开了dropDownMenu
    button.tag = 4000;
}

-(void)hideMenu:(UIButton*)button
{
    CGRect btnFrame = [button.superview convertRect:button.frame toView:self.view];
    _recordExtDropDownMenu.delegate = self;//代理
    btnFrame.origin.y -= 40;
    [_recordExtDropDownMenu hideDropDownMenuWithBtnFrame:btnFrame];
    button.tag = 1000;
    return;
}

-(void)hideRecordExtMenu:(UIButton*)button
{
    CGRect btnFrame = [button.superview convertRect:button.frame toView:self.view];
    _sexDropDownMenu.delegate = self;//代理
    btnFrame.origin.y -= 40;
    [_sexDropDownMenu hideDropDownMenuWithBtnFrame:btnFrame];
    button.tag = 3000;
    return;
}
    
- (void)setDropDownDelegate:(XDSDropDownMenu *)sender
{
    if(sender == self.sexDropDownMenu){
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
    if(sender == self.recordExtDropDownMenu) {
        self.btn.tag = 3000;
        NSString* title = [self.btn currentTitle];
        if([title isEqualToString:@"mp3"]){
            [EMDemoOption sharedOptions].recordExt = RecordExtMP3;
        }
        if([title isEqualToString:@"wav"]){
            [EMDemoOption sharedOptions].recordExt = RecordExtWAV;
        }
        if([title isEqualToString:@"mp4"]){
            [EMDemoOption sharedOptions].recordExt = RecordExtMP4;
        }
        if([title isEqualToString:@"m4a"]){
            [EMDemoOption sharedOptions].recordExt = RecordExtM4A;
        }
        if([title isEqualToString:@"auto"]){
            [EMDemoOption sharedOptions].recordExt = RecordExtAUTO;
        }
        //[[EMDemoOption sharedOptions] archive];
    }
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
    } else if (tag == 3 + 10000 + 10*2) {
        [EMDemoOption sharedOptions].isBackCamera = [aSwitch isOn];
    } else if (tag == 4 + 10000 + 10*2) {
        [EMDemoOption sharedOptions].isRecord = [aSwitch isOn];
        [self.tableView reloadData];
    } else if (tag == 5 + 10000 + 10*2) {
        [EMDemoOption sharedOptions].isMerge = [aSwitch isOn];
        [self.tableView reloadData];
    } else if (tag == 6 + 10000 + 10*2) {
        [EMDemoOption sharedOptions].openCDN = [aSwitch isOn];
        [self.tableView reloadData];
    }else if (tag == 8 + 10000 + 10*2) {
        [EMDemoOption sharedOptions].livePureAudio = [aSwitch isOn];
        [self.tableView reloadData];
    }else if (tag == 10 + 10000 + 10*2 ) {
        [[EMDemoOption sharedOptions] setTheSpecifyServer:[aSwitch isOn]];
        [self.tableView reloadData];
    }else if (tag == 11 + 10000 + 10*2 ) {
        [EMDemoOption sharedOptions].isClarityFirst = [aSwitch isOn];
        [self.tableView reloadData];
    }else if (tag == 12 + 10000 + 10*2 ) {
        [EMDemoOption sharedOptions].isJoinAsAudience = [aSwitch isOn];
        [self.tableView reloadData];
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
#ifndef ENABLE_AUDIORECORD
    if((indexPath.row == 8 || indexPath.row == 9) && indexPath.section == 2)
        return 0;
#endif
    return 40;
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
