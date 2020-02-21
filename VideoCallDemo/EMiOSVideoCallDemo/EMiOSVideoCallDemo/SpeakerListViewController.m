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
    self.title = @"主播列表";
    [self.navigationController setNavigationBarHidden:NO];
}
-(void)dealloc
{
    [self.navigationController setNavigationBarHidden:YES];
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
        
        if(row == 0){
            UILabel * description = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, self.view.bounds.size.width, 40)];
            NSInteger auduinceCount = [EMDemoOption sharedOptions].conference.memberCount - [EMDemoOption sharedOptions].conference.speakerIds.count;
            description.text = [NSString stringWithFormat:@"观众人数：%ld",auduinceCount];
            description.textAlignment = NSTextAlignmentCenter;
            [cell addSubview:description];
        }
    }
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
        [audioButton addTarget:self action:@selector(audioAction:) forControlEvents:UIControlEventTouchUpInside];
        [videoButton addTarget:self action:@selector(videoAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:videoButton];
        [cell addSubview:audioButton];
        ConferenceViewController* confVC = [self getConfVC];
        if(confVC) {
            NSArray* keys = [confVC.streamItemDict allKeys];
            EMStreamItem*item = [confVC.streamItemDict objectForKey:keys[row]];
            if(item){
                cell.textLabel.text = item.videoView.nameLabel.text;
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
    NSInteger row = (tag-20000)/2;
    NSInteger section = 1;
    NSIndexPath* path = [NSIndexPath indexPathForRow:row inSection:section];
    UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:path];
    if(cell){
        NSString* memName = cell.textLabel.text;
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
