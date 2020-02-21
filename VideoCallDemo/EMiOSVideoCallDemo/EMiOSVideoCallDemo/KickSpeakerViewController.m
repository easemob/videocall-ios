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

@interface KickSpeakerViewController ()
@property(nonatomic) UIButton* selectButton;
@property(nonatomic) NSString* speakerName;
@end

@implementation KickSpeakerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _selectButton = nil;
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
        long row = self.selectButton.tag - 30000;
        ConferenceViewController* confVC = [self getConfVC];
        if(confVC) {
            NSArray* keys = [confVC.streamItemDict allKeys];
            EMStreamItem*item = [confVC.streamItemDict objectForKey:keys[row]];
            if(item){
                if([self.speakerName isEqualToString:[EMDemoOption sharedOptions].userid])
                {
                    [EMAlertController showErrorAlert:@"不能选择管理员自己"];
                    return;
                }
                __weak typeof(self) weakself = self;
                NSString* memid = [NSString stringWithFormat:@"%@_%@",[EMDemoOption sharedOptions].appkey,weakself.speakerName];
                [[[EMClient sharedClient] conferenceManager] changeMemberRoleWithConfId:[EMDemoOption sharedOptions].conference.confId memberNames:@[memid] role:EMConferenceRoleAudience completion:^(EMError *aError) {
                    if(aError){
                    }
                    if(weakself.speakerName){
                        
                        [[[EMClient sharedClient] conferenceManager] changeMemberRoleWithConfId:[EMDemoOption sharedOptions].conference.confId memberNames:@[memid] role:EMConferenceRoleSpeaker completion:^(EMError *aError) {
                            
                        }];
                    }
                }];
            }
        }
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)setNewSpeaker:(NSString*)name
{
    _speakerName = [name copy];
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
