//
//  UpdateNicknameViewController.m
//  EMiOSVideoCallDemo
//
//  Created by lixiaoming on 2020/3/18.
//  Copyright © 2020 easemob. All rights reserved.
//

#import "UpdateNicknameViewController.h"
#import "EMDemoOption.h"

@interface UpdateNicknameViewController ()
@property (nonatomic) UIButton* saveButton;
@property (nonatomic) UITextField* nickNameField;
@end

@implementation UpdateNicknameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupViews];
}

- (void)setupViews
{
    UIButton* button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(5, 70, 30, 30);
    [button setImage:[UIImage imageNamed:@"goback"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    UILabel* lable = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2-40, 70, 80, 30)];
    lable.text = @"修改昵称";
    [self.view addSubview:lable];
    
    self.saveButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.saveButton.frame = CGRectMake(self.view.bounds.size.width - 70, 70, 60, 30);
    [self.saveButton setTitle:@"完成" forState:UIControlStateNormal];
    [self.saveButton setTitle:@"完成" forState:UIControlStateDisabled];
    [self.saveButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.saveButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    [self.saveButton addTarget:self action:@selector(saveAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.saveButton];
    
    self.nickNameField = [[UITextField alloc] initWithFrame:CGRectMake(60, 140, self.view.bounds.size.width - 120, 40)];
    self.nickNameField.borderStyle = UITextBorderStyleNone;
    self.nickNameField.text = [EMDemoOption sharedOptions].nickName;
    self.nickNameField.placeholder = @"请输入昵称";
    self.nickNameField.returnKeyType = UIReturnKeyDone;
    self.nickNameField.font = [UIFont systemFontOfSize:17];
    self.nickNameField.rightViewMode = UITextFieldViewModeWhileEditing;
    self.nickNameField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.nickNameField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    self.nickNameField.leftViewMode = UITextFieldViewModeAlways;
    self.nickNameField.layer.cornerRadius = 5;
    self.nickNameField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.nickNameField.tag = 100;
    self.nickNameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChange:) name:UITextFieldTextDidChangeNotification object:self.nickNameField];
    [self.view addSubview:self.nickNameField];
    
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(60, 179, self.view.bounds.size.width - 120, 1)];
    view.layer.backgroundColor = [UIColor colorWithRed:214/255.0 green:214/255.0 blue:214/255.0 alpha:1.0].CGColor;
    [self.view addSubview:view];
}

-(void)backAction
{
    [self.navigationController popViewControllerAnimated:NO];
}

-(void)textChange:(UITextField*)field
{
    if([self.nickNameField.text length] == 0)
        self.saveButton.enabled = NO;
    else
        self.saveButton.enabled = YES;
}

-(void)saveAction
{
    [EMDemoOption sharedOptions].nickName = self.nickNameField.text;
    [[EMDemoOption sharedOptions] archive];
    [self backAction];
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
