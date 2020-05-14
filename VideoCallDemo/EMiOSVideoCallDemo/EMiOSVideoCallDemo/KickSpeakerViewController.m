//
//  kickSpeakerController.m
//  EMiOSVideoCallDemo
//
//  Created by lixiaoming on 2020/2/13.
//  Copyright © 2020 easemob. All rights reserved.
//

#import "KickSpeakerViewController.h"
#import "ConferenceViewController.h"
#import "EMDemoOption.h"
#import "EMAlertController.h"

@interface UIKickerTableViewCell : UITableViewCell
@property (nonatomic) NSString* memName;
@property (nonatomic) BOOL enableVoice;
@end

@implementation UIKickerTableViewCell

@end;

@interface KickSpeakerViewController ()
@property(nonatomic) UIButton* selectButton;
@property(nonatomic) NSString* speakerName;
@property (nonatomic) NSString* speakerId;
@property (nonatomic) NSMutableDictionary* normalStreams;
@end

@implementation KickSpeakerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _selectButton = nil;
    self.normalStreams = [NSMutableDictionary dictionary];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
        [_normalStreams removeAllObjects];
        for(NSString* key in keys) {
            EMStreamItem*value = [confVC.streamItemDict objectForKey:key];
            if(value && value.stream) {
                if(value.stream.type == EMStreamTypeDesktop)
                    continue;
            }
            [_normalStreams setObject:value forKey:key];
        }
        return _normalStreams.count;
    }
    return [EMDemoOption sharedOptions].conference.speakerIds.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    static NSString *cellIdentifier = @"cellID";
    
    UIKickerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
    cellIdentifier];
    if (cell == nil) {
        cell = [[UIKickerTableViewCell alloc]initWithStyle:
        UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    if(section == 0) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if(row == 0){
            UIButton* cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            cancelButton.frame = CGRectMake(5, 5, 40, 40);
            cancelButton.tag = 30000+row;
            [cancelButton setTitle:@"X" forState:UIControlStateNormal];
            [cancelButton addTarget:self action:@selector(cancelButtonAction) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:cancelButton];
            UIButton* replaceButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            replaceButton.frame = CGRectMake(self.tableView.frame.size.width - 50, 5, 40, 40);
            replaceButton.tag = 30000+row;
            [replaceButton setTitle:@"替换" forState:UIControlStateNormal];
            [replaceButton addTarget:self action:@selector(replaceButtonAction) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:replaceButton];
        }
    }
    if(section == 1)
    {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UIButton *checkbox = [UIButton buttonWithType:UIButtonTypeCustom];
         
        CGRect checkboxRect = CGRectMake(self.tableView.frame.size.width - 50, 5, 40, 40);
        [checkbox setFrame:checkboxRect];
        checkbox.tag = 30000+row;
         
        [checkbox setImage:[UIImage imageNamed:@"cbu.png"] forState:UIControlStateNormal];
        [checkbox setImage:[UIImage imageNamed:@"cbc.png"] forState:UIControlStateSelected];
         
        [checkbox addTarget:self action:@selector(checkboxClick:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:checkbox];
        ConferenceViewController* confVC = [self getConfVC];
        if(confVC) {
            NSArray* keys = [_normalStreams allKeys];
            EMStreamItem*item = [_normalStreams objectForKey:keys[row]];
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
            }
        }else
            cell.textLabel.text = [[[EMDemoOption sharedOptions].conference.speakerIds objectAtIndex:row] substringFromIndex:([[EMDemoOption sharedOptions].appkey length]+1)];
    }
    
    // Configure the cell...
    
    return cell;
    
}

-(ConferenceViewController*) getConfVC
{
    UIViewController* navVC =  [UIApplication sharedApplication].delegate.window.rootViewController;
    UINavigationController*nav = (UINavigationController*)navVC;
    UIViewController*lastVC = [nav.viewControllers lastObject];
    if([lastVC isKindOfClass:[ConferenceViewController class]]){
        ConferenceViewController* confVC = (ConferenceViewController*)lastVC;
        return confVC;
    }
    return nil;
}

-(void)checkboxClick:(UIButton*)checkButton
{
    if(_selectButton){
        [_selectButton setSelected:NO];
    }
    [checkButton setSelected:YES];
    _selectButton = checkButton;
}

-(void)cancelButtonAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)replaceButtonAction
{
    if(self.selectButton){
        ConferenceViewController* confVC = [self getConfVC];
        if(confVC) {
            NSIndexPath* path = [NSIndexPath indexPathForItem:(self.selectButton.tag-30000) inSection:1];
            UIKickerTableViewCell*cell = [self.tableView cellForRowAtIndexPath:path];
            NSString* selectName = cell.memName;
            NSString* memid = [NSString stringWithFormat:@"%@_%@",[EMDemoOption sharedOptions].appkey,[EMDemoOption sharedOptions].userid];
            if([selectName isEqualToString:memid])
            {
                [EMAlertController showErrorAlert:@"不能选择主持人自己"];
                return;
            }
            __weak typeof(self) weakself = self;
            
            [[[EMClient sharedClient] conferenceManager] changeMemberRoleWithConfId:[EMDemoOption sharedOptions].conference.confId memberNames:@[selectName] role:EMConferenceRoleAudience completion:^(EMError *aError) {
                if(aError){
                    [[[EMClient sharedClient] conferenceManager] responseReqSpeaker:[EMDemoOption sharedOptions].conference memId:weakself.speakerId result:1 completion:^(EMError *aError) {
                    }];
                    [EMAlertController showErrorAlert:@"下麦失败"];
                }else
                if(weakself.speakerName){
                    NSString* newmemid = weakself.speakerName;
                    [[[EMClient sharedClient] conferenceManager] changeMemberRoleWithConfId:[EMDemoOption sharedOptions].conference.confId memberNames:@[newmemid] role:EMConferenceRoleSpeaker completion:^(EMError *aError) {
                        if(aError)
                        {
                            [EMAlertController showErrorAlert:@"上麦失败"];
                            [[[EMClient sharedClient] conferenceManager] responseReqSpeaker:[EMDemoOption sharedOptions].conference memId:weakself.speakerId result:1 completion:^(EMError *aError) {
                            }];
                        }else
                        {
                            [[[EMClient sharedClient] conferenceManager] responseReqSpeaker:[EMDemoOption sharedOptions].conference memId:weakself.speakerId result:0 completion:^(EMError *aError) {
                            }];
                            [EMAlertController showSuccessAlert:@"上麦成功"];
                            return;
                        }
                    }];
                }
            }];
        }
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)setNewSpeaker:(NSString*)name memId:(NSString *)memId
{
    _speakerName = [name copy];
    _speakerId = [memId copy];
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
