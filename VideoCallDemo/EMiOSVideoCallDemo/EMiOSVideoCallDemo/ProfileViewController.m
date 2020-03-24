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
    UIButton* button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(5, 70, 30, 30);
    [button setImage:[UIImage imageNamed:@"goback"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    UILabel* lable = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2-40, 70, 80, 30)];
    lable.text = @"我的资料";
    [self.view addSubview:lable];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(5, 100, self.view.bounds.size.width - 10, self.view.bounds.size.height - 100) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
}

-(void)backAction
{
    [self.navigationController popViewControllerAnimated:NO];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

// Default is 1 if not implemented
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
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
        cell.textLabel.text = @"头像";
        
        UIImageView *headimageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 80, 0, 40, 40)];
        if([[EMDemoOption sharedOptions].headImage length] > 0) {
            NSString* imageurl = [NSString stringWithFormat:@"https://download-sdk.oss-cn-beijing.aliyuncs.com/downloads/RtcDemo/headImage/%@" ,[EMDemoOption sharedOptions].headImage ];
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageurl]];
            headimageView.image = [[UIImage alloc] initWithData:data];
        }else
            headimageView.image = [UIImage imageNamed:@"APP"];
        headimageView.contentMode = UIViewContentModeScaleAspectFill;
        [cell addSubview:headimageView];
        
        UIButton* opButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        opButton.frame = CGRectMake(self.view.frame.size.width - 40, 5, 30, 30);
        [opButton setTitle:@">" forState:UIControlStateNormal];
        opButton.titleLabel.textAlignment = NSTextAlignmentRight;
        opButton.tag = 5000;
        [opButton addTarget:self action:@selector(OperationAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:opButton];
    }
    if(section == 1) {
        [[cell viewWithTag:6000] removeFromSuperview];
        cell.textLabel.text = @"我的昵称";
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 140, 2, 100, 35)];
        label.text = [EMDemoOption sharedOptions].nickName;
        label.textAlignment = NSTextAlignmentRight;
        label.tag = 6000;
        [cell addSubview:label];
        
        UIButton* opButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        opButton.frame = CGRectMake(self.view.frame.size.width - 40, 5, 30, 30);
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
        UpdateNicknameViewController* uVC = [[UpdateNicknameViewController alloc] init];
        [self.navigationController pushViewController:uVC animated:NO];
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
