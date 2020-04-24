//
//  SpeakerListViewController.m
//  EMiOSVideoCallDemo
//
//  Created by lixiaoming on 2020/2/11.
//  Copyright © 2020 easemob. All rights reserved.
//

#import "SpeakerListViewController.h"
#import "EMDemoOption.h"
#import "ConferenceViewController.h"
#import "EMAlertController.h"

@interface UICustomTableViewCell : UITableViewCell
@property (nonatomic) NSString* memName;
@property (nonatomic) BOOL enableVoice;
@end

@implementation UICustomTableViewCell

@end;
static BOOL muteAll = NO;
@interface SpeakerListViewController ()
@property (nonatomic) UIButton* muteAllButton;
@end

@implementation SpeakerListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSubView];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)setupSubView
{
    //self.title = @"主播列表";
}

-(void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    if(section == 0){
        return 1;
    }
    ConferenceViewController* confVC = [self getConfVC];
    if(confVC) {
        NSArray* keys = [confVC.streamItemDict allKeys];
        return keys.count;
    }
    return [EMDemoOption sharedOptions].conference.speakerIds.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    static NSString *cellIdentifier = @"cellID";
    
    UICustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
    cellIdentifier];
    if (cell == nil) {
        cell = [[UICustomTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    if(section == 0) {
        //cell.textLabel.text = @"主播列表";
        
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"主播列表"];
        [str addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:66/255.0 green:66/255.0 blue:66/255.0 alpha:1.0] range:NSMakeRange(0,4)]; //设置字体颜色
        [str addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Arial" size:18] range:NSMakeRange(0, 4)]; //设置字体字号和字体类别
        cell.textLabel.attributedText = str;
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        UIButton* button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        //[button setTitle:@"上传日志" forState:UIControlStateNormal];
        button.frame = CGRectMake(5, 5, 40, 40);
        [button setImage:[UIImage imageNamed:@"goback"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:button];
        if([EMDemoOption sharedOptions].conference.role == EMConferenceRoleAdmin) {
            if(self.muteAllButton)
               [self.muteAllButton removeFromSuperview];
            self.muteAllButton = [UIButton buttonWithType:UIButtonTypeSystem];
            self.muteAllButton.frame = CGRectMake(self.tableView.frame.size.width - 100, 8, 100, 30);
            if(muteAll)
                [self.muteAllButton setTitle:@"解除静音" forState:UIControlStateNormal];
            else
                [self.muteAllButton setTitle:@"全体静音" forState:UIControlStateNormal];
            [self.muteAllButton addTarget:self action:@selector(muteAllAction:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:self.muteAllButton];
        }
    }else
    if(section == 1)
    {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [[cell viewWithTag:20000+row*3] removeFromSuperview];
        [[cell viewWithTag:20000+row*3+1] removeFromSuperview];
        UIImageView* audioImage = [[UIImageView alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width - 100, 8, 30, 30)];
        audioImage.tag = 20000+row*3;
        audioImage.image = [UIImage imageNamed:@"audioclose"];
        UIImageView* videoImage = [[UIImageView alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width - 60, 8, 30, 30)];
        videoImage.tag = 20000+row*3 + 1;
        videoImage.image = [UIImage imageNamed:@"cameraclose"];
        if([EMDemoOption sharedOptions].conference.role == EMConferenceRoleAdmin) {
            UIButton* opButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            opButton.frame = CGRectMake(self.tableView.frame.size.width - 30, 5, 30, 30);
            opButton.tag = 20000+row*3 + 2;
            [opButton setTitle:@">" forState:UIControlStateNormal];
            opButton.titleLabel.textAlignment = NSTextAlignmentRight;
            [opButton addTarget:self action:@selector(OperationAction:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:opButton];
        }
        [cell addSubview:audioImage];
        [cell addSubview:videoImage];
        ConferenceViewController* confVC = [self getConfVC];
        if(confVC) {
            NSArray* keys = [confVC.streamItemDict allKeys];
            EMStreamItem*item = [confVC.streamItemDict objectForKey:keys[row]];
            if(item){
                //cell.textLabel.text = item.videoView.nameLabel.text;
                cell.textLabel.numberOfLines = 0;
                //设置Attachment
                NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
                //使用一张图片作为Attachment数据
                NSString* memName = [NSString stringWithFormat:@"%@_%@",[EMDemoOption sharedOptions].appkey,item.videoView.nameLabel.text];
                if([item.videoView.nameLabel.text isEqualToString:[EMDemoOption sharedOptions].userid]) {
                    NSString* imageurl = [NSString stringWithFormat:@"https://download-sdk.oss-cn-beijing.aliyuncs.com/downloads/RtcDemo/headImage/%@" ,[EMDemoOption sharedOptions].headImage ];
                    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageurl]];
                    attachment.image = [UIImage imageWithData:data];
                }else{
                    EMCallMember*member = [confVC.membersDict objectForKey:memName];
                    if(member){
                        NSData*jsonData = [member.ext dataUsingEncoding:NSUTF8StringEncoding];
                        NSError *jsonError = nil;
                        NSDictionary* extDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&jsonError];
                        if(extDic) {
                            NSString* headImage = [extDic objectForKey:@"headImage"];
                            if([headImage length] > 0) {
                                NSString* imageurl = [NSString stringWithFormat:@"https://download-sdk.oss-cn-beijing.aliyuncs.com/downloads/RtcDemo/headImage/%@" ,headImage];
                                NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageurl]];
                                attachment.image = [UIImage imageWithData:data];
                            }
                        }
                    }
                }
                NSString* showName = item.videoView.nickNameLabel.text;
                if([[EMDemoOption sharedOptions].conference.adminIds count] > 0){
                    if([[EMDemoOption sharedOptions].conference.adminIds containsObject:memName]){
                        showName = [showName stringByAppendingString:@"(主持人)"];
                    }
                }
                cell.memName = memName;
                //这里bounds的x值并不会产生影响
                attachment.bounds = CGRectMake(0, -5, 30, 30);
                
                NSMutableAttributedString * attrubedStr = [[NSMutableAttributedString alloc]initWithString:showName];

                NSAttributedString *string = [NSAttributedString attributedStringWithAttachment:attachment];
                [attrubedStr insertAttributedString:string atIndex:0];

                cell.textLabel.attributedText = attrubedStr;
                if([[EMDemoOption sharedOptions].userid isEqualToString:item.videoView.nameLabel.text] )
                    cell.textLabel.textColor = [UIColor blueColor];
                cell.enableVoice = item.videoView.enableVoice;
                if(item.videoView.enableVideo){
                    videoImage.image = [UIImage imageNamed:@"cameraopen"];
                }
                if(item.videoView.enableVoice){
                    audioImage.image = [UIImage imageNamed:@"audioopen"];
                }
            }
        }else
            cell.textLabel.text = [[[EMDemoOption sharedOptions].conference.speakerIds objectAtIndex:row] substringFromIndex:([[EMDemoOption sharedOptions].appkey length]+1)];
    }
    
    // Configure the cell...
    
    return cell;
}

-(void)audioAction:(UIButton*)button
{
    NSInteger tag = button.tag;
    NSInteger row = (tag-20000)/3;
    NSInteger section = 1;
    NSIndexPath* path = [NSIndexPath indexPathForRow:row inSection:section];
    UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:path];
    if(cell){
        NSString* memName = cell.textLabel.text;
        NSString* memid = [NSString stringWithFormat:@"%@_%@",[EMDemoOption sharedOptions].appkey,memName ];
        UIViewController* parantControler = (UIViewController*)self.parentViewController;
        if([parantControler isKindOfClass:[ConferenceViewController class]]){
            ConferenceViewController* confVC = (ConferenceViewController*)parantControler;
            for(NSString *compKey in confVC.streamItemDict) {
                EMStreamItem* item = [confVC.streamItemDict objectForKey:compKey];
                if(item && item.stream.userName){
                    [[[EMClient sharedClient] conferenceManager] muteRemoteAudio:item.stream.streamId mute:item.stream.enableVoice];
                    break;
                }
            }
        }
    }
}

-(void)videoAction:(UIButton*)button
{
    NSInteger tag = button.tag;
    NSInteger row = (tag-20000)/3;
    NSInteger section = 1;
    NSIndexPath* path = [NSIndexPath indexPathForRow:row inSection:section];
    UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:path];
    if(cell){
        NSString* memName = cell.textLabel.text;
        if([memName isEqualToString:[EMDemoOption sharedOptions].userid]){
            return;
        }
        UIViewController* lastVC =  [self.navigationController.viewControllers objectAtIndex:(self.navigationController.viewControllers.count-2)];
        if([lastVC isKindOfClass:[ConferenceViewController class]]){
            ConferenceViewController* confVC = [self getConfVC];
            if(confVC) {
                for(NSString *compKey in confVC.streamItemDict) {
                    EMStreamItem* item = [confVC.streamItemDict objectForKey:compKey];
                    if(item && item.stream.userName){
                        [[[EMClient sharedClient] conferenceManager] muteRemoteVideo:item.stream.streamId mute:item.stream.enableVideo];
                        break;
                    }
                }
            }
            
        }
    }
}

- (NSString *)getMemIdByMemName:(NSString *)memName
{
    ConferenceViewController* pVC = [self getConfVC];
    if([memName length] > 0 &&pVC) {
        EMCallMember * member = [pVC.membersDict objectForKey:memName];
        if(member) {
            return member.memberId;
        }
    }
    return nil;
}

-(void)OperationAction:(UIButton*)button
{
    NSInteger tag = button.tag;
    NSInteger row = (tag-20000)/3;
    NSInteger section = 1;
    NSIndexPath* path = [NSIndexPath indexPathForRow:row inSection:section];
    UICustomTableViewCell* cell = [self.tableView cellForRowAtIndexPath:path];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    NSString* showName = @"解除静音";
    if(cell.enableVoice)
        showName = @"静音";
    UIAlertAction *muteAudio = [UIAlertAction actionWithTitle:showName style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString * actions = @"unmute";
        if(cell.enableVoice)
            actions = @"mute";
        if([cell.memName isEqualToString:[NSString stringWithFormat:@"%@_%@",[EMDemoOption sharedOptions].appkey,[EMDemoOption sharedOptions].userid]]) {
            [[[EMClient sharedClient] conferenceManager] updateConference:[EMDemoOption sharedOptions].conference isMute:cell.enableVoice];
        }else {
            NSString *memId = [self getMemIdByMemName:cell.memName];
            if([memId length] > 0)
               [[[EMClient sharedClient] conferenceManager] setMuteMember:[EMDemoOption sharedOptions].conference memId:memId mute:cell.enableVoice completion:^(EMError *aError) {
                   if(aError) {
                       [EMAlertController showErrorAlert:@"操作失败"];
                   }
            }];
        }
    }];
    [alertController addAction:muteAudio];

    if(cell && [cell.memName length] > 0 && ![[EMDemoOption sharedOptions].conference.adminIds containsObject:cell.memName]) {
        UIAlertAction *setAdminAction = [UIAlertAction actionWithTitle:@"设为主持人" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[[EMClient sharedClient] conferenceManager] changeMemberRoleWithConfId:[EMDemoOption sharedOptions].conference.confId memberNames:@[cell.memName] role:EMConferenceRoleAdmin completion:^(EMError *aError) {
                if(aError) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [EMAlertController  showErrorAlert:@"操作失败"];
                    });
                }
            }];
        }];
        [alertController addAction:setAdminAction];
        
        UIAlertAction *kickMemberAction = [UIAlertAction actionWithTitle:@"移出会议" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[[EMClient sharedClient] conferenceManager] kickMemberWithConfId:[EMDemoOption sharedOptions].conference.confId memberNames:@[cell.memName] completion:^(EMError *aError) {
                if(aError) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [EMAlertController  showErrorAlert:@"操作失败"];
                    });
                }
            }];
        }];
        [alertController addAction:kickMemberAction];
    }

    [alertController addAction: [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", @"Cancel") style: UIAlertActionStyleCancel handler:nil]];

    [self presentViewController:alertController animated:YES completion:nil];
}

-(ConferenceViewController*) getConfVC
{
    UIViewController* lastVC =  [self.navigationController.viewControllers objectAtIndex:(self.navigationController.viewControllers.count-2)];
    if([lastVC isKindOfClass:[ConferenceViewController class]]){
        ConferenceViewController* confVC = (ConferenceViewController*)lastVC;
        return confVC;
    }
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0)
        return 1;
    if(section == 1)
        return 30;
    return 10;//section头部高度
}
//section头部视图
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(section == 1){
        NSInteger auduinceCount = [EMDemoOption sharedOptions].conference.memberCount - [EMDemoOption sharedOptions].conference.speakerIds.count;
        //创建一个普通的Label
        UILabel *testLabel = [[UILabel alloc] init];
        //中央对齐
        testLabel.textAlignment = NSTextAlignmentCenter;
        testLabel.numberOfLines = 0;
        testLabel.frame = CGRectMake(0, 0, self.view.frame.size.width, 30);
        [self.view addSubview:testLabel];
        
        //设置Attachment
        NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
        //使用一张图片作为Attachment数据
        attachment.image = [UIImage imageNamed:@"hot"];
        //这里bounds的x值并不会产生影响
        attachment.bounds = CGRectMake(-600, -5, 20, 20);
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"当前观众人数：%ld ",auduinceCount]];
        [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Arial" size:12] range:NSMakeRange(0, attributedString.mutableString.length)];
        [attributedString appendAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
        testLabel.attributedText = attributedString;
        return testLabel;
    }
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
    view.backgroundColor = [UIColor clearColor];
    return view ;
}
//section底部间距
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if(section == 0 && !muteAll)
        return 1;
    return 30;
}
//section底部视图
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if(section == 0 && muteAll){
        UILabel* text = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 1)];
        text.text = @"当前处于全体静音状态";
        text.textColor = [UIColor whiteColor];
        text.font = [UIFont systemFontOfSize:12];
        text.textAlignment = NSTextAlignmentCenter;
        text.backgroundColor = [UIColor redColor];
        return text;
    }
    
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 1)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

-(void)muteAllAction:(UIButton*)button
{
    NSString* title = button.titleLabel.text;
    if([title isEqualToString:@"全体静音"]) {
        muteAll = YES;
        [self setMuteAll:YES];
        [self.tableView reloadData];
    }else{
        muteAll = NO;
        [self setMuteAll:NO];
        [self.tableView reloadData];
    }
}

- (void)setMuteAll:(BOOL)mute
{
    [[[EMClient sharedClient] conferenceManager] muteAll:muteAll completion:^(EMError *aError) {
        if(aError) {
            [EMAlertController showErrorAlert:@"操作失败"];
        }
    }];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
