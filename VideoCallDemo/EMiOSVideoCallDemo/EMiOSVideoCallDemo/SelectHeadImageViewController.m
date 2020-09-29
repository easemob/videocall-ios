//
//  SelectHeadImageViewController.m
//  EMiOSVideoCallDemo
//
//  Created by lixiaoming on 2020/3/18.
//  Copyright © 2020 easemob. All rights reserved.
//

#import "SelectHeadImageViewController.h"
#import "EMDemoOption.h"

@interface SelectHeadImageViewController ()
@property (nonatomic) UITableView* tableView;
@property (nonatomic) UIButton* saveButton;
@property(nonatomic) UIButton* selectButton;
@end

@implementation SelectHeadImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupViews];
}

-(void)backAction
{
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)setupViews
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(5, 5, self.view.bounds.size.width - 10, self.view.bounds.size.height) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)saveAction
{
    if(_selectButton)
    {
        NSInteger row = _selectButton.tag - 30000;
        NSArray* headImages = [[EMDemoOption sharedOptions].headImageDic allValues];
        [EMDemoOption sharedOptions].headImage = [headImages objectAtIndex:row];
        [[EMDemoOption sharedOptions] archive];
        [self backAction];
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0)
        return 1;;
    return [[EMDemoOption sharedOptions].headImageDic count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
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
        UIButton* button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        button.frame = CGRectMake(5, 5, 30, 30);
        [button setImage:[UIImage imageNamed:@"goback"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:button];
        cell.textLabel.text = @"选择头像";
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        self.saveButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.saveButton.frame = CGRectMake(self.view.bounds.size.width - 50, 5, 50, 30);
        [self.saveButton setTitle:@"完成" forState:UIControlStateNormal];
        [self.saveButton setTitle:@"完成" forState:UIControlStateDisabled];
        [self.saveButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [self.saveButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        [self.saveButton addTarget:self action:@selector(saveAction) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:self.saveButton];
    }
    if(section == 1)
    {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UIImageView *headimageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 10, 40, 40)];
        NSArray* headImages = [[EMDemoOption sharedOptions].headImageDic allValues];
        if([[EMDemoOption sharedOptions].headImage length] > 0) {
            NSString* imageurl = [NSString stringWithFormat:@"https://download-sdk.oss-cn-beijing.aliyuncs.com/downloads/RtcDemo/headImage/%@" ,headImages[row]];
            [headimageView sd_setImageWithURL:[NSURL URLWithString:imageurl]];
        }else
            headimageView.image = [UIImage imageNamed:@"APP"];
        headimageView.contentMode = UIViewContentModeScaleAspectFill;
        [cell addSubview:headimageView];

        UIButton *checkbox = [UIButton buttonWithType:UIButtonTypeCustom];
         
        CGRect checkboxRect = CGRectMake(self.tableView.frame.size.width - 50, 10, 40, 40);
        [checkbox setFrame:checkboxRect];
        checkbox.tag = 30000+row;
         
        [checkbox setImage:[UIImage imageNamed:@"cbu.png"] forState:UIControlStateNormal];
        [checkbox setImage:[UIImage imageNamed:@"cbc.png"] forState:UIControlStateSelected];
        
        if([[EMDemoOption sharedOptions].headImage isEqualToString:[headImages objectAtIndex:row]]) {
            _selectButton = checkbox;
            [_selectButton setSelected:YES];
        }
         
        [checkbox addTarget:self action:@selector(checkboxClick:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:checkbox];
    }
    
    // Configure the cell...
    
    return cell;
    
}

-(void)checkboxClick:(UIButton*)checkButton
{
    if(_selectButton){
        [_selectButton setSelected:NO];
    }
    [checkButton setSelected:YES];
    _selectButton = checkButton;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
        return 40;
    return 60;
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
