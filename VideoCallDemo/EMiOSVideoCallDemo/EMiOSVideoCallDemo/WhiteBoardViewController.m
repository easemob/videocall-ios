//
//  WhiteBoardViewController.m
//  EMiOSVideoCallDemo
//
//  Created by lixiaoming on 2020/6/15.
//  Copyright © 2020 easemob. All rights reserved.
//

#import "WhiteBoardViewController.h"
#import "AppDelegate.h"
#import "EMAlertController.h"
#import <WebKit/WebKit.h>

@interface WhiteBoardViewController ()<WKNavigationDelegate>
@property (nonatomic) WKWebView *wkWebView;
@property (nonatomic) EMWhiteboard* wb;
@property (nonatomic) UIButton* backButton;
@property (nonatomic) UIButton* exitButton;
@property (nonatomic) UIButton* interactButton;
@end

@implementation WhiteBoardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupSubviews];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;//允许转成横屏
    appDelegate.allowRotation = YES;
    //调用横屏代码
        
    NSNumber *resetOrientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationUnknown];
       
    [[UIDevice currentDevice] setValue:resetOrientationTarget forKey:@"orientation"];
       
    NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft];
       
    [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
}

-(void)viewWillDisappear:(BOOL)animated
{
    AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;//允许转成横屏
    appDelegate.allowRotation = NO;
    
    NSNumber *resetOrientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationUnknown];
       
    [[UIDevice currentDevice] setValue:resetOrientationTarget forKey:@"orientation"];
       
    NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
       
    [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
}

- (instancetype)initWithWBUrl:(EMWhiteboard*)wb
{
    self = [super init];
    if(self) {
        _wb = wb;
    }
    return self;
}

-(BOOL)isCreator
{
    if(self.wb && [self.wb.roomURL length] > 0) {
        NSArray* array = [self.wb.roomURL componentsSeparatedByString:@"?"];
        if([array count] > 1) {
            NSString* params = [array objectAtIndex:1];
            NSArray* paramsArray = [params componentsSeparatedByString:@"&"];
            for(NSString* param in paramsArray) {
                NSArray* paramArray = [param componentsSeparatedByString:@"="];
                NSString* key = [paramArray objectAtIndex:0];
                if([key isEqualToString:@"isCreater"]) {
                    NSString* value = [paramArray objectAtIndex:1];
                    if([value isEqualToString:@"true"]) {
                        return YES;
                    }
                    break;
                }
            }
        }
    }
    return NO;
}

-(void)setupSubviews
{
    WKWebViewConfiguration *config = [WKWebViewConfiguration new];
    config.preferences = [WKPreferences new];
    config.preferences.minimumFontSize = 10;
    config.preferences.javaScriptEnabled = YES;
    config.preferences.javaScriptCanOpenWindowsAutomatically = NO;
    
    _wkWebView = [[WKWebView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) configuration:config];
    [_wkWebView loadRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_wb.roomURL]]];
    _wkWebView.navigationDelegate = self;
    [self.view addSubview:_wkWebView];
    [self.wkWebView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.backButton.frame = CGRectMake(self.view.bounds.size.width - 100, 50, 40, 40);
    [self.backButton setImage:[UIImage imageNamed:@"wb-back"] forState:UIControlStateNormal];
    [self.backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.backButton];
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view).multipliedBy(1.9);
        make.centerY.equalTo(self.view).multipliedBy(0.2);
        make.width.equalTo(@40);
        make.height.equalTo(@40);
    }];
    
    if([self isCreator]){
        self.exitButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.exitButton.frame = CGRectMake(self.view.bounds.size.width - 100, 50, 40, 40);
        [self.exitButton setImage:[UIImage imageNamed:@"wb-exit"] forState:UIControlStateNormal];
        [self.exitButton addTarget:self action:@selector(exitAction) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.exitButton];
        [self.exitButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view).multipliedBy(1.9);
            make.centerY.equalTo(self.view).multipliedBy(0.5);
            make.width.equalTo(@40);
            make.height.equalTo(@40);
        }];
        
        self.interactButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.interactButton.frame = CGRectMake(self.view.bounds.size.width - 100, 50, 40, 40);
        [self.interactButton setImage:[UIImage imageNamed:@"wb-interact"] forState:UIControlStateNormal];
        [self.interactButton addTarget:self action:@selector(interactAction) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.interactButton];
        [self.interactButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view).multipliedBy(1.9);
            make.centerY.equalTo(self.view).multipliedBy(0.8);
            make.width.equalTo(@40);
            make.height.equalTo(@40);
        }];
    }
}

-(void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    //如果是跳转一个新页面
    if (navigationAction.targetFrame == nil) {
        [_wkWebView loadRequest:navigationAction.request];
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)back
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
}

-(void)interactAction
{
    __weak typeof(self) weakself = self;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *allowInteract = [UIAlertAction actionWithTitle:@"允许白板成员互动" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[[EMClient sharedClient] conferenceManager] updateWhiteboardRoomWithRoomId:weakself.wb.roomId username:[EMClient sharedClient].currentUsername userToken:[EMClient sharedClient].accessUserToken intract:YES allUsers:YES serventIds:nil completion:^(EMError *aError) {
            
        }];
    }];
    [alertController addAction:allowInteract];

    UIAlertAction *forbidInteract = [UIAlertAction actionWithTitle:@"禁止白板成员互动" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[[EMClient sharedClient] conferenceManager] updateWhiteboardRoomWithRoomId:weakself.wb.roomId username:[EMClient sharedClient].currentUsername userToken:[EMClient sharedClient].accessUserToken intract:NO allUsers:YES serventIds:nil completion:^(EMError *aError) {
            
        }];
    }];
    [alertController addAction:forbidInteract];

    [alertController addAction: [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", @"Cancel") style: UIAlertActionStyleCancel handler:nil]];

    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)exitAction
{
    __weak typeof(self) weakself = self;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"退出后将销毁白板,是否继续" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"退出" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[[EMClient sharedClient] conferenceManager] destroyWhiteboardRoomWithUsername:[EMClient sharedClient].currentUsername userToken:[EMClient sharedClient].accessUserToken roomId:self.wb.roomId completion:^(EMError *aError) {
            if(!aError) {
                [[[EMClient sharedClient] conferenceManager] deleteAttributeWithKey:@"whiteBoard" completion:^(EMError *aError) {
                    [self back];
                }];
            }else{
                [EMAlertController showErrorAlert:@"退出失败"];
            }
        }];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
       
    }]];
    [self presentViewController:alert animated:YES completion:nil];
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
