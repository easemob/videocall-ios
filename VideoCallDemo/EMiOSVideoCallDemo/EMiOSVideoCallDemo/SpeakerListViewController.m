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

@interface SpeakerListViewController ()

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
    [self.navigationController setNavigationBarHidden:YES];
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
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
    cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:
        UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
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
        [button setImage:[UIImage imageNamed:@"24 ／ icon"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:button];
    }else
    if(section == 1)
    {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UIButton* audioButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        audioButton.frame = CGRectMake(self.tableView.frame.size.width - 100, 5, 40, 40);
        audioButton.tag = 20000+row*2;
        //[audioButton setTitle:@"音频" forState:UIControlStateNormal];
        [audioButton setImage:[UIImage imageNamed:@"编组 8"] forState:UIControlStateNormal];
        UIButton* videoButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        videoButton.frame = CGRectMake(self.tableView.frame.size.width - 50, 5, 40, 40);
        videoButton.tag = 20000+row*2 + 1;
        //[videoButton setTitle:@"视频" forState:UIControlStateNormal];
        [videoButton setImage:[UIImage imageNamed:@"编组 8备份"] forState:UIControlStateNormal];
        //[audioButton addTarget:self action:@selector(audioAction:) forControlEvents:UIControlEventTouchUpInside];
        //[videoButton addTarget:self action:@selector(videoAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:videoButton];
        [cell addSubview:audioButton];
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
                if([[EMDemoOption sharedOptions].conference.adminIds count] > 0){
                    if([[[EMDemoOption sharedOptions].conference.adminIds objectAtIndex:0] isEqualToString:memName]){
                        attachment.image = [UIImage imageNamed:@"admin"];
                    }
                }
                //这里bounds的x值并不会产生影响
                attachment.bounds = CGRectMake(-600, -5, 20, 20);
                NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:item.videoView.nameLabel.text];
                [attributedString appendAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
                cell.textLabel.attributedText = attributedString;
                if(!item.videoView.enableVideo && !item.videoView.enableVoice){
                    videoButton.hidden = YES;
                    audioButton.hidden = YES;
                }else{
                    if(item.videoView.enableVoice && !item.videoView.enableVideo){
                        videoButton.hidden = YES;
                        audioButton.frame = videoButton.frame;
                    }else{
                        if(item.videoView.enableVideo && !item.videoView.enableVoice){
                            audioButton.hidden = YES;
                        }
                    }
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
    NSInteger row = (tag-20000)/2;
    NSInteger section = 2;
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
    NSInteger row = (tag-20000)/2;
    NSInteger section = 2;
    NSIndexPath* path = [NSIndexPath indexPathForRow:row inSection:section];
    UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:path];
    if(cell){
        NSString* memName = cell.textLabel.text;
        if([memName isEqualToString:[EMDemoOption sharedOptions].userid]){
            return;
        }
        NSString* memid = [NSString stringWithFormat:@"%@_%@",[EMDemoOption sharedOptions].appkey,memName ];
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
        return 3;
    return 10;//section头部高度
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
    if(section == 0){
        NSInteger auduinceCount = [EMDemoOption sharedOptions].conference.memberCount - [EMDemoOption sharedOptions].conference.speakerIds.count;
       //UILabel* text = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, self.view.bounds.size.width, 20)];
//        text.textAlignment = NSTextAlignmentCenter;
//        //设置Attachment
//        NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
//        //使用一张图片作为Attachment数据
//        attachment.image = [UIImage imageNamed:@"编组"];
//        //这里bounds的x值并不会产生影响
//        attachment.bounds = CGRectMake(-600, 0, 20, 10);
//        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"当前观众人数：%ld",auduinceCount]];
//        [attributedString appendAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
        //text.attributedText = attributedString;
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
        attachment.image = [UIImage imageNamed:@"编组"];
        //这里bounds的x值并不会产生影响
        attachment.bounds = CGRectMake(-600, -5, 20, 20);
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"当前观众人数：%ld",auduinceCount]];
        [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Arial" size:12] range:NSMakeRange(0, attributedString.mutableString.length)];
        [attributedString appendAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
        testLabel.attributedText = attributedString;
        return testLabel;
    }
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
    view.backgroundColor = [UIColor clearColor];
    return view;
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
