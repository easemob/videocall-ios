//
//  ProfileViewController.m
//  EMiOSVideoCallDemo
//
//  Created by lixiaoming on 2020/3/18.
//  Copyright © 2020 easemob. All rights reserved.
//

#import "ProfileViewController.h"
#import "EMDemoOption.h"
#import "UpdateNicknameViewController.h"
#import "SelectHeadImageViewController.h"

@interface UpdateNickNameAlertController : UIAlertController
-(void)textChange:(UITextField*)textField;
@end
@implementation UpdateNickNameAlertController

-(void)textChange:(UITextField *)textField
{
    if([self.textFields[0].text length] == 0)
        self.actions[0].enabled = NO;
    else
        self.actions[0].enabled = YES;
}

@end

@interface ProfileViewController()
@property (nonatomic) UITableView* tableView;
@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupViews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
}

- (void)setupViews
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(5, 70, self.view.bounds.size.width - 10, self.view.bounds.size.height - 70) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

-(void)backAction
{
    [self.navigationController popViewControllerAnimated:NO];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
        return 40;
    return 60;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0)
        return 1;
    return 30;
}

// Default is 1 if not implemented
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    NSString *cellIdentifier = [NSString stringWithFormat:@"cellid_%ld_%ld",section,row ];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
    cellIdentifier];
    if (cell)
    {
        [cell removeFromSuperview];
    }
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:
        UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    if(section == 0){
        UIButton* button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        button.frame = CGRectMake(5, 5, 30, 30);
        [button setImage:[UIImage imageNamed:@"goback"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:button];
        
        cell.textLabel.text = @"我的资料";
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    }
    if(section == 1){
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = @"头像";
        
        UIImageView *headimageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 80, 10, 40, 40)];
        if([[EMDemoOption sharedOptions].headImage length] > 0) {
            NSString* imageurl = [NSString stringWithFormat:@"https://download-sdk.oss-cn-beijing.aliyuncs.com/downloads/RtcDemo/headImage/%@" ,[EMDemoOption sharedOptions].headImage ];
            [headimageView sd_setImageWithURL:[NSURL URLWithString:imageurl]];
        }else
            headimageView.image = [UIImage imageNamed:@"APP"];
        headimageView.contentMode = UIViewContentModeScaleAspectFill;
        [cell addSubview:headimageView];
        
        UIButton* opButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        opButton.frame = CGRectMake(self.view.frame.size.width - 40, 10, 40, 40);
        [opButton setTitle:@">" forState:UIControlStateNormal];
        opButton.titleLabel.textAlignment = NSTextAlignmentRight;
        opButton.tag = 5000;
        [opButton addTarget:self action:@selector(OperationAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:opButton];
    }
    if(section == 2) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [[cell viewWithTag:6000] removeFromSuperview];
        cell.textLabel.text = @"我的昵称";
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 140, 10, 100, 40)];
        label.text = [EMDemoOption sharedOptions].nickName;
        label.textAlignment = NSTextAlignmentRight;
        label.tag = 6000;
        [cell addSubview:label];
        
        UIButton* opButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        opButton.frame = CGRectMake(self.view.frame.size.width - 40, 10, 40, 40);
        [opButton setTitle:@">" forState:UIControlStateNormal];
        opButton.titleLabel.textAlignment = NSTextAlignmentRight;
        opButton.tag = 5001;
        [opButton addTarget:self action:@selector(OperationAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:opButton];
        
    }
    return cell;
}

-(void)OperationAction:(UIButton*)button
{
    if(button.tag == 5000)
    {
        SelectHeadImageViewController* selectHIVC = [[SelectHeadImageViewController alloc] init];
        [self.navigationController pushViewController:selectHIVC animated:NO];
    }
    if(button.tag == 5001)
    {
        //UpdateNicknameViewController* uVC = [[UpdateNicknameViewController alloc] init];
        //[self.navigationController pushViewController:uVC animated:NO];
        __weak typeof(self) weakself = self;
        UpdateNickNameAlertController *alertController = [UpdateNickNameAlertController alertControllerWithTitle:@"请输入昵称" message:nil preferredStyle:UIAlertControllerStyleAlert];
            //以下方法就可以实现在提示框中输入文本；
            
            //在AlertView中添加一个输入框
            [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                
                textField.placeholder = @"昵称";
                textField.text = [EMDemoOption sharedOptions].nickName;
                [[NSNotificationCenter defaultCenter] addObserver:alertController selector:@selector(textChange:) name:UITextFieldTextDidChangeNotification object:textField];
            }];
            UIAlertAction* action = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                UITextField *envirnmentNameTextField = alertController.textFields.firstObject;
                
                [EMDemoOption sharedOptions].nickName = envirnmentNameTextField.text;
                [[EMDemoOption sharedOptions] archive];
                [weakself.tableView reloadData];
            }];
            [alertController addAction:action];
            
            //添加一个取消按钮
            [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil]];
            
            //present出AlertView
            [self presentViewController:alertController animated:true completion:nil];
    }
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
