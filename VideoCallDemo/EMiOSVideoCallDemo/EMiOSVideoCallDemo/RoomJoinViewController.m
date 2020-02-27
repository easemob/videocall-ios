//
//  RoomJoinViewController.m
//  EMiOSVideoCallDemo
//
//  Created by lixiaoming on 2020/2/10.
//  Copyright © 2020 easemob. All rights reserved.
//

#import "RoomJoinViewController.h"
#import "ConferenceViewController.h"
#import "AccountSettingViewController.h"
#import "EMDemoOption.h"
#import <Hyphenate/EMOptions+PrivateDeploy.h>
static BOOL gIsInitializedSDK = NO;
@interface RoomJoinViewController ()
@property (nonatomic) NSString* roomName;
@property (nonatomic) NSString* password;
@end
static BOOL g_IsLogin = NO;
@implementation RoomJoinViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initSDK];
    [self initDemo];
}
int kHeightStart = 300;
- (void)initDemo {
    CGRect mainBounds = [[UIScreen mainScreen] bounds];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"设置" style:UIBarButtonItemStyleDone target:self action:@selector(settingAction)];
    
    UIImage* image = [UIImage imageNamed:@"Fill 1"];
    self.conferencelogo = [[UIImageView alloc] initWithImage:image];
    self.conferencelogo.frame = CGRectMake(100, 130, mainBounds.size.width-200, 100);
    [self.conferencelogo setContentMode:UIViewContentModeScaleAspectFit];
    [self.view addSubview:self.conferencelogo];
    
    UILabel* lable = [[UILabel alloc] initWithFrame:CGRectMake(100, 230, mainBounds.size.width-200, 40)];
    lable.text = @"环信多人会议";
    lable.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:lable];
    
    self.nameField = [[UITextField alloc] initWithFrame:CGRectMake(60, kHeightStart, mainBounds.size.width - 120, 40)];
    self.nameField.delegate = self;
    self.nameField.borderStyle = UITextBorderStyleNone;
    self.nameField.placeholder = @"请输入房间名称";
    self.nameField.returnKeyType = UIReturnKeyDone;
    self.nameField.font = [UIFont systemFontOfSize:17];
    self.nameField.rightViewMode = UITextFieldViewModeWhileEditing;
    self.nameField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.nameField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    self.nameField.leftViewMode = UITextFieldViewModeAlways;
    self.nameField.layer.cornerRadius = 5;
    self.nameField.layer.borderWidth = 1;
    self.nameField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.nameField.tag = 100;
    self.nameField.keyboardType = UIKeyboardTypeASCIICapable;
    self.nameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [self.nameField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChange:) name:UITextFieldTextDidChangeNotification object:self.nameField];
    [self.view addSubview:self.nameField];
    
    self.pswdField = [[UITextField alloc] initWithFrame:CGRectMake(60, kHeightStart+100, mainBounds.size.width-120, 40)];
    self.pswdField.delegate = self;
    self.pswdField.borderStyle = UITextBorderStyleNone;
    self.pswdField.placeholder = @"请输入房间密码";
    self.pswdField.font = [UIFont systemFontOfSize:17];
    self.pswdField.returnKeyType = UIReturnKeyDone;
    //self.pswdField.secureTextEntry = YES;
    self.pswdField.rightViewMode = UITextFieldViewModeAlways;
    self.pswdField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    self.pswdField.leftViewMode = UITextFieldViewModeAlways;
    self.pswdField.layer.cornerRadius = 5;
    self.pswdField.layer.borderWidth = 1;
    self.pswdField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.pswdField.secureTextEntry = YES;
    self.pswdField.tag = 101;
    //self.pswdField.keyboardType = UIKeyboardTypeASCIICapable;
    self.pswdField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [self.pswdField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChange:) name:UITextFieldTextDidChangeNotification object:self.pswdField];
    [self.view addSubview:self.pswdField];
    
    self.errorLable = [[UILabel alloc] initWithFrame:CGRectMake(60, kHeightStart+150, mainBounds.size.width-120, 60)];
    [self.errorLable setTextColor:[UIColor redColor]];
    self.errorLable.text = @"";
    [self.view addSubview:self.errorLable];
    
    self.joinAsSpeaker = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.joinAsSpeaker.frame = CGRectMake(100, kHeightStart+200, mainBounds.size.width-200, 40);
    self.joinAsSpeaker.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.joinAsSpeaker setTitle:@"以主播身份加入" forState:UIControlStateNormal];
    [self.joinAsSpeaker setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.joinAsSpeaker addTarget:self action:@selector(joinRoomAsSpeakerAction) forControlEvents:UIControlEventTouchUpInside];
    //设置按下状态的颜色
    [self.joinAsSpeaker setTitleColor:[UIColor orangeColor] forState:UIControlStateHighlighted];
    [self.joinAsSpeaker setTitleColor:[UIColor blackColor] forState:UIControlStateDisabled];
    [self.joinAsSpeaker setEnabled:NO];
    self.joinAsSpeaker.layer.borderWidth = 0.5;
    self.joinAsSpeaker.layer.cornerRadius = 10;
    [self.view addSubview:_joinAsSpeaker];
    
    self.joinAsAudience = [UIButton buttonWithType:
    UIButtonTypeRoundedRect];
    [self.joinAsAudience setFrame:CGRectMake(100,kHeightStart+280, mainBounds.size.width-200, 40)];
    self.joinAsAudience.titleLabel.font = [UIFont systemFontOfSize:14];
    // sets title for the button
    [self.joinAsAudience setTitle:@"以观众身份加入" forState:
    UIControlStateNormal];
    [self.joinAsAudience addTarget:self action:@selector(joinAsAudienceAction) forControlEvents:UIControlEventTouchUpInside];
    [self.joinAsAudience setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.joinAsAudience setTitleColor:[UIColor orangeColor] forState:UIControlStateHighlighted];
    [self.joinAsAudience setTitleColor:[UIColor blackColor] forState:UIControlStateDisabled];
    [self.joinAsAudience setTintColor:[UIColor whiteColor]];
    [self.joinAsAudience setEnabled:NO];
    self.joinAsAudience.layer.borderWidth = 0.5;
    self.joinAsAudience.layer.cornerRadius = 10;
    //self.joinAsAudience.backgroundColor = [UIColor blueColor];
    [self.view addSubview:self.joinAsAudience];
}

-(void)initSDK
{
    if (!gIsInitializedSDK) {
        gIsInitializedSDK = YES;
        EMDemoOption* option = [EMDemoOption sharedOptions];
        EMOptions *options = [EMOptions optionsWithAppkey:option.appkey];
        options.enableConsoleLog = YES;
        if(option.specifyServer)
        {
            options.enableDnsConfig = NO;
            options.chatPort = option.chatPort;
            options.chatServer = option.chatServer;
            options.restServer = option.restServer;
        }
        [[EMClient sharedClient] initializeSDKWithOptions:options];
        [self autoLogin];
    }
}

-(void)autoLogin
{
    EMDemoOption* option = [EMDemoOption sharedOptions];
    __weak typeof(self) weakself = self;
        
    if([option.userid length] == 0){
            NSString* uuid = [NSUUID UUID].UUIDString;
            NSString*pwd = @"123456";
            uuid = [uuid stringByReplacingOccurrencesOfString:@"-" withString:@""];
            uuid = [uuid substringToIndex:16];
            [[EMClient sharedClient] registerWithUsername:uuid password:pwd completion:^(NSString *aUsername, EMError *aError) {
                if(!aError){
                    option.userid = uuid;
                    option.pswd = pwd;
                    [option archive];
                    [[EMClient sharedClient] loginWithUsername:option.userid password:option.pswd completion:^(NSString *aUsername, EMError *aError) {
                        if(!aError){
                            [weakself initManager];
                            g_IsLogin = YES;
                        }
                    }];
                }
            }];
        }else
            //[[EMClient sharedClient] loginWithUsername:@"jwfan" password:@"jwfan" completion:^(NSString *aUsername, EMError *aError) {
            [[EMClient sharedClient] loginWithUsername:option.userid password:option.pswd completion:^(NSString *aUsername, EMError *aError) {
                if(!aError){
                    [weakself initManager];
                    g_IsLogin = YES;
                }
            }];
}

-(void) initManager
{
    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].conferenceManager addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].conferenceManager enableStatistics:YES];
}

-(void)settingAction
{
    AccountSettingViewController* settingViewController = [[AccountSettingViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [self.navigationController pushViewController:settingViewController animated:YES];
}

-(void)textChange:(UITextField*)field {
    _roomName = self.nameField.text;
    _password = self.pswdField.text;
    if([_roomName length] > 0 && [_password length] > 0)
    {
        [self.joinAsSpeaker setEnabled:YES];
        [self.joinAsAudience setEnabled:YES];
    }
    else{
        [self.joinAsSpeaker setEnabled:NO];
        [self.joinAsAudience setEnabled:NO];
    }
}

- (void)joinRoomAsSpeakerAction
{
    self.joinAsSpeaker.enabled = NO;
    self.joinAsAudience.enabled = NO;
    self.errorLable.text = @"";
    [self _joinWithRole:EMConferenceRoleSpeaker];
}

- (void)_joinWithRole:(EMConferenceRole)role
{
    if(!g_IsLogin){
        self.errorLable.text = @"当前尚未登录";
        [self autoLogin];
        self.joinAsSpeaker.enabled = YES;
        self.joinAsAudience.enabled = YES;
        return;
    }
    NSString* roomName = self.nameField.text;
    NSString* pswd = self.pswdField.text;
    if([roomName length] < 3){
        self.errorLable.text = @"房间名称不能少于3位";
        self.joinAsSpeaker.enabled = YES;
        self.joinAsAudience.enabled = YES;
        return;
    }
    if(![self validateString:roomName])
    {
        self.errorLable.text = @"房间名称不符合规范";
        self.joinAsSpeaker.enabled = YES;
        self.joinAsAudience.enabled = YES;
        return;
    }
    if([pswd length] < 3 || [pswd length] > 18){
        self.errorLable.text = @"房间密码应在3位到18位之间";
        self.joinAsSpeaker.enabled = YES;
        self.joinAsAudience.enabled = YES;
        return;
    }
    if(![self validateString:pswd])
    {
        self.errorLable.text = @"房间密码仅允许中英文";
        self.joinAsSpeaker.enabled = YES;
        self.joinAsAudience.enabled = YES;
        return;
    }
    __weak typeof(self) weakself = self;
    void (^block)(EMCallConference *aCall, EMError *aError) = ^(EMCallConference *aCall, EMError *aError) {
        if (aError) {
            if(aError.code == EMErrorInvalidPassword){
                weakself.errorLable.text = @"密码错误";
            }
            if(aError.code == EMErrorCallSpeakerFull){
                UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"" message:@"主播人数已满，以观众身份进入" preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
                    //响应事件
                    [weakself joinAsAudienceAction];
                }];
                UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                    //响应事件
                    return;
                }];

                [alert addAction:defaultAction];
                [alert addAction:cancelAction];
                [self presentViewController:alert animated:YES completion:nil];
            }
            self.joinAsSpeaker.enabled = YES;
            self.joinAsAudience.enabled = YES;
            return ;
        }
        [EMDemoOption sharedOptions].conference = aCall;
        [EMDemoOption sharedOptions].roomName = roomName;
        [EMDemoOption sharedOptions].roomPswd = pswd;
       
        ConferenceViewController* conferenceViewControler = [[ConferenceViewController alloc] initWithConfence:aCall role:role];
        [weakself.navigationController pushViewController:conferenceViewControler animated:NO];
        self.joinAsSpeaker.enabled = YES;
        self.joinAsAudience.enabled = YES;
    };
    [[[EMClient sharedClient] conferenceManager] joinRoom:roomName password:pswd role:role completion:block];
}

- (void)joinAsAudienceAction
{
    self.joinAsSpeaker.enabled = NO;
    self.joinAsAudience.enabled = NO;
    self.errorLable.text = @"";
    [self _joinWithRole:EMConferenceRoleAudience];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)textFieldDidChange:(UITextField *)textField
{
    NSString *toBeString = textField.text;
    if([toBeString length] == 0)
        return;
    
    int kmaxLength = 18;//设置最大输入值
    
    if([toBeString length] > kmaxLength){
        if(textField.tag == 100)
            textField.text = _roomName;
    }
    if(![self validateString:toBeString])
    {
        if(textField.tag == 100)
            textField.text = _roomName;
        else if(textField.tag == 101)
            textField.text = _password;
    }
}

-(BOOL)validateString:(NSString*)str
{
    // 编写正则表达式，验证mobilePhone是否为手机号码
    NSString *regex = @"^[\u4e00-\u9fa5A-Za-z0-9_-]+$";
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
